---
title: "Towards an indie web: Twitter"
date: 2019-09-09
toc: true
issueId: 32
---

# Intro
As i said in my [previous post](/blog/2019-08-20-managing-bookmarks-with-hugo/) im trying to reown my data and have everything here, under my own domain. After doing it for my browsing experience (bookmarks, history, passwords) changing Google Chrome for Mozilla Firefox, now was time for my social accounts. After some googling i found the [IndieWeb](https://indieweb.org/) project, and i mostly think this is what i want. It even have an [awesome wiki](https://indieweb.org/Getting_Started) to help you with this task. Following the [twitter guide](https://indieweb.org/Twitter) i had some problems, thats why im writing this "updated and alternative" guide. Maybe that one works just fine for you, but its always nice to have more content on the topic.

# Exporting my data
My first logical thought was to use the Twitter Archive functionality as the guide says. This give me a zip file with all my data in a json format and all my images. Trying to parse it, i found out that this werent json files, but js files, with some variable declaration at the top. Nothing difficult to stripe out. After reviewing some of the data, i also found out that retweets i made were truncated to some number of characters, failing its own task of having an archive of my data. Along that, i have some images from my retweets and others not, failing again. After some googling i found out that this is my twitter *data*, and not my twitter **archive**, something that internet claims to be a real copy of my twitter profile. Looking again in my account settings i couldnt find the option to download my twitter archive, only my data. Some people claim that using incognito mode, or some outdated browsers (IE 11) they could export it, but this wasnt my case. Other people seems to have the same problem, thats one of the reasons why im writing this.

This is an example of the tweet.js file, the one which holds all your timeline. You can also see things like *"retweeted" : false* when this is clearly a retweet.
```js
window.YTD.tweet.part0 = [{
	"retweeted" : false,
	"source" : "<a href=\"https://mobile.twitter.com\" rel=\"nofollow\">Twitter Web App</a>",
	"entities" : {
		"hashtags" : [ ],
		"symbols" : [ ],
		"user_mentions" : [{
			"name" : "Scott Hanselman",
			"screen_name" : "shanselman",
			"indices" : [ "3", "14" ],
			"id_str" : "5676102",
			"id" : "5676102"
		}],
		"urls" : [{
			"url" : "https://t.co/aXbntDW1US",
			"expanded_url" : "https://www.hanselman.com/blog/OpenSourceArtificialPancreasesWillBecomeTheNewStandardOfCareForDiabetesIn2019.aspx",
			"display_url" : "hanselman.com/blog/OpenSourc…",
			"indices" : [ "108", "131" ]
		}]
	},
	"display_text_range" : [ "0", "140" ],
	"favorite_count" : "0",
	"id_str" : "1121419075316482049",
	"truncated" : false,
	"retweet_count" : "0",
	"id" : "1121419075316482049",
	"possibly_sensitive" : false,
	"created_at" : "Thu Apr 25 14:21:57 +0000 2019",
	"favorited" : false,
	"full_text" : "RT @shanselman: Open Source Artificial Pancreases will become the new standard of care for Diabetes in 2019 https://t.co/aXbntDW1US #diabet…",
	"lang" : "en"
}]
```

## Understanding twitter web api
As the twitter data doesnt work for me, and i cant get my twitter archive, i decided to scrape it from twitter client itself. **To follow the details of how i made the scrapper, i assume you know some js or some general programming knowledge.** Some fiddling with the Devtools network panel and i found out that every request to twitter api, needs the three following headers present: *authorization*, *x-guest-token*, *x-csrf-token*. More fiddling logged with different accounts, and as a guest user, i found that the authorization header is always the same. The other two headers are values that are stored in a cookie. Having said that, our first task is to get this values from the cookies, and make a function to request a url with this headers. **All this code is going to be executed in the devtools console in Firefox Nightly 70.0a1 (2019-08-31). We are going to use some ES6 features, but it should work in any other modern browser and it shouldnt be difficult to port if you know JS**

```js
let parsedCookies = Object.fromEntries(
	document.cookie.split(";").map( c => [
		c.substring(0,c.indexOf("=")).trim(),
		c.substr(c.indexOf("=")+1).trim()
	])
);
```

This snippet lets us have an object called parsedCookies, with the cookie names as the keys, and their value with the cookie content. *cookie* is an object of the *document* object which returns us a string with all our cookies with the format *key=value* separated by the character ";". Calling the split method, allows us to convert the string into an array of the parts that are separated by the given character, in this case ";". That way we would have an array where each element would represent a single cookie and they would be in the format *key=value*. The map method let us run a function over each element of the array, and return all in a single array. The one we use here, returns the following array [key,value] for each element in the original array, the one that split give us. This give us in the end, an array, where each element is an array of two elements, first, the cookie name, and second the cookie value. And after all this processing, we call the Object.fromEntries method, which takes an array of elements of the type [key,value] and gives us an object. If you know Object.entries, this is the inverse. I think this is understood better with an example.

```js
// Suppose our document.cookie is equal to "PREF=f1=50000000&f5=30000; wide=1"


document.cookie.split(";");
// [ "PREF=f1=50000000&f5=30000", " wide=1" ]

document.cookie.split(";").map( c => [
	c.substring(0,c.indexOf("=")).trim(),
	c.substr(c.indexOf("=")+1).trim()
])
//[ [ "PREF", "f1=50000000&f5=30000" ], [ "wide", "1" ] ]

Object.fromEntries(
	document.cookie.split(";").map( c => [
		c.substring(0,c.indexOf("=")).trim(),
		c.substr(c.indexOf("=")+1).trim()
	])
);
// { PREF: "f1=50000000&f5=30000", wide: "1" }
```

This code isnt tested in extense, probably have a lot of edge cases that fail, but for our purpose it works just fine. Now we are able to make our function to request a url with this data. To do this we are going to use the fetch api. We are also assuming that parsedCookies is defined because we ran the previous snippet.

```js
function get(url){
	return fetch(url, {
		"credentials": "include",
		"headers": {
			"authorization": "Bearer AAAAAAAAAAAAAAAAAAAAANRILgAAAAAAnNwIzUejRCOuH5E6I8xnZz4puTs%3D1Zv7ttfk8LF81IUq16cHjhLTvJu4FA33AGWWjCpTnA",
			"x-guest-token": parsedCookies.gt,
			"x-csrf-token": parsedCookies.ct0
		},
		"referrer": "https://mobile.twitter.com/",
		"method": "GET",
		"mode": "cors"
	})
}
```

Next we need our userID, to get them, we are not going to parse anything, we will use some third party web, because the ones i found are dead simple, you put your username and they give you the id. The ones i found that work are: [http://gettwitterid.com/](http://gettwitterid.com/) and [https://tweeterid.com/](https://tweeterid.com/)

We have our user id, we can make request as if we were twitter, the only thing left is to understand how the timeline is constructed. More feedling with the devtools and we found out that the first request with a tweet response is made to this url *https://api.twitter.com/2/timeline/profile/1046076458.json?......* Inspecting its response, we found out that it have two main fields, *globalObjects* and *timeline*. globalObjects, its a kind of database, it contains all of the tweet and user data, all by single entries. I think this is an awesome design decision, because whenever you refer to some of its items, you only have to store its id, and then you can query this globalObjects content. The other field, timeline, has an array of intructions with items to show. Jackpot, this is the one we are going to use to reconstruct our timeline. *I know this because i have already done it, and inside the globalObjects we have more data than the needed. For example, for one of my retweets, we have my retweet and the original tweet, so we cant use that, as we would have repeated content.*. Each instruction have an *entryID* field which tell us what to do. The ones i could found and decipher are:

* tweet-ID: Shows the tweet with the given id
* whoToFollow-XXXX: Its the block which suggest you accounts to follow
* cursor-XXXX: Its the one used when we want to navigate the content. AKA pagination.

The last one its very important because without it, we wouldnt be able to query for older tweets. I think we have most of the terrain cover, lets make a function which receives a cursor, and makes our query, returning the response.

```js
let userID = "YOUR_USER_ID";
function query(cursor){
	let url = "https://api.twitter.com/2/timeline/profile/"+userID+".json?include_profile_interstitial_type=1&include_blocking=1&include_blocked_by=1&include_followed_by=1&include_want_retweets=1&include_mute_edge=1&include_can_dm=1&include_can_media_tag=1&skip_status=1&cards_platform=Web-12&include_cards=1&include_composer_source=true&include_ext_alt_text=true&include_reply_count=1&tweet_mode=extended&include_entities=true&include_user_entities=true&include_ext_media_color=true&include_ext_media_availability=true&send_error_codes=true&include_tweet_replies=true&userId=1046076458&count=20&ext=mediaStats%2ChighlightedLabel%2CcameraMoment";
	if( cursor !== undefined ){
		url += "&cursor=" + cursor;
	}
	return get(url)
		.then( r => r.json() );
}
```

If we ran ```await query()``` in the console we will see that the data is coming fine. Now me have to make a function which calls this function with the appropiate cursor until we reach the end.

```js
async function queryAll(){
	let currCursor = undefined;
	let newCursor = undefined;
	let data = [];

	do {
		currCursor = newCursor;
		let r = await query(currCursor)
		data.push( r );
		newCursor = r.timeline.instructions[0].addEntries.entries.find( i => i.entryId.indexOf("cursor-bottom") > -1 ).content.operation.cursor.value;
	}while( currCursor !== newCursor );

	return data;
}
```
We declare the function as async so we can use the await syntax and make the code easier to read. First we define three variables, currCursor and newCursor will allow us to traverse the pagination. We need to store the current AND next, because when we reach the end, it still give us a collection with top and bottom cursors. That way if we found that the cursors hasnt changed, we know we reached the end. Data will be an array where we are going to put our response objects. We loop while the cursors hadnt change, make the request, store its response and update the new cursor. When we finish querying, we return our data. If we run this, we will find that it works, but it returns us an array with the different responses, and thats right what we have done, but wouldnt it be much better if it was a single big object?. To do that, we are going to merge every object in the array into a single one. My first attempt was to use Object.assign, but this isnt deep and it is not possible to do it deep. So im going to use the [deepmerge utility](https://github.com/TehShrike/deepmerge) found in [David Wash's blog](https://davidwalsh.name/javascript-deep-merge). We only need to change the ```return data``` line with ```return deepmerge.all(data)```. If we look inside the timeline property, we would see that all our instructions are there, but still it isnt easy to traverse, the best would be to have an array of entry objects. To do this we are going to use the reduce method, im not going to explain how it works, but you can read [this amazing post](https://css-tricks.com/an-illustrated-and-musical-guide-to-map-reduce-and-filter-array-methods/). We also are going to sort it, and we need to only get the ones that are tweets. In other words, filter everything that doesnt have a *tweet-ID* as entryId field.

```js
let data = await queryAll();
data.timeline = data.timeline.instructions
	.reduce((prev,curr) => prev.concat(curr.addEntries.entries), [])
	.sort( (a,b) => b.sortIndex - a.sortIndex )
	.filter( i => i.entryId.indexOf("tweet-") > -1 );
```

We are almost there, the only thing remaining is to replace every entry with just its tweet id. To do this we are going to use the map method, and retrieve its id from within the entry.

```js
let data = await queryAll();
data.timeline = data.timeline.instructions
	.reduce((prev,curr) => prev.concat(curr.addEntries.entries), [])
	.sort( (a,b) => b.sortIndex - a.sortIndex )
	.filter( i => i.entryId.indexOf("tweet-") > -1 )

	// this is the new line
	.map( i => i.content.item.content.tweet.id )
```

Now we have all the data needed in a nice format. We are ready to start working towards downloading and parsing it.

## Parsing our data
As i said before, currently in our object we have a lot of extra data, and our timeline its just a collection of ids. We still need to parse it, and download its attachments whenever they have. Although if you only needed to have some kind of raw database with all the data of your twitter, now its a good point to do whatever you want with it. The first thing, is to map our ids to the object itself, to do this we are going to use the map method as before. After that, we need to filter out the ones that we couldnt get. This shouldnt happen, but for a reason i still dont get, it happened with my profile ¯\_(ツ)_/¯.

```js
let data = await queryAll();
data.timeline = data.timeline.instructions
	.reduce((prev,curr) => prev.concat(curr.addEntries.entries), [])
	.sort( (a,b) => b.sortIndex - a.sortIndex )
	.filter( i => i.entryId.indexOf("tweet-") > -1 )
	.map( i => i.content.item.content.tweet.id )

	// this are the new lines
	.map( id => data.globalObjects.tweets[id] )
	.filter( tw => tw );
```

Next we are going to check if its a retweet, if this is true, we are going to replace its *entities*, *full_text* and *user_id_str* with the ones from the original tweet, so we can show the real tweet. When we check if its a retweet, we also need to check if it has the retweet id field, because if you retweet your own tweets, it wont be present.
```js
let data = await queryAll();
data.timeline = data.timeline.instructions
	.reduce((prev,curr) => prev.concat(curr.addEntries.entries), [])
	.sort( (a,b) => b.sortIndex - a.sortIndex )
	.filter( i => i.entryId.indexOf("tweet-") > -1 )
	.map( i => i.content.item.content.tweet.id )
	.map( id => data.globalObjects.tweets[id] )
	.filter( tw => tw )

	// this are the new lines
	.map( tw => {
		if( tw.retweeted && tw.retweeted_status_id_str ){
			let r = data.globalObjects.tweets[ tw.retweeted_status_id_str ];
			tw.entities = r.entities;
			tw.full_text = r.full_text;
			tw.user_id_str = r.user_id_str;
			tw.in_reply_to_status_id_str = r.in_reply_to_status_id_str;
			tw.in_reply_to_screen_name = r.in_reply_to_screen_name;
		}

		return tw;
	})
```

The next step is to get the user data, this is done in a similar way, we map each object, and extract the user data from the *globalObjects* object using the *user_id_str* field. Thats why we replaced it before, so now we can get the data of the owner of the original tweet.
```js
let data = await queryAll();
data.timeline = data.timeline.instructions
	.reduce((prev,curr) => prev.concat(curr.addEntries.entries), [])
	.sort( (a,b) => b.sortIndex - a.sortIndex )
	.filter( i => i.entryId.indexOf("tweet-") > -1 )
	.map( i => i.content.item.content.tweet.id )
	.map( id => data.globalObjects.tweets[id] )
	.filter( tw => tw )
	.map( tw => {
		if( tw.retweeted && tw.retweeted_status_id_str ){
			let r = data.globalObjects.tweets[ tw.retweeted_status_id_str ];
			tw.entities = r.entities;
			tw.full_text = r.full_text;
			tw.user_id_str = r.user_id_str;
		}

		return tw;
	})

	// this are the new lines
	.map( tw => {
		tw.user = data.globalObjects.users[ tw.user_id_str ];
		return tw;
	})
```

We are almost there, at least the data is finally in a readable format. If you only wanted to get a slightly better than the raw json, you could stop reading now. The following steps are used to expand links so they arent in the *t.co* format but in the real url, and getting the media links in an array for future use.

As im going to export this to markdown files, im going to replace the urls with the appropiate format, but you could make it in whatever format you like. To do this, im going again to use the map function, and check inside the entities field, for a url prescense, in case it exists, its going to provide us with the text that its used in the tweet, and with the real url. We only want to replace one with the other. To do that, append the following line to the neverending chain of methods we have been extending.

```js
.map( tw => {
	if( tw.entities.hasOwnProperty("urls") ){
		for( let link of tw.entities.urls ){
			tw.full_text = tw.full_text.replace( link.url, "["+link.expanded_url+"]("+link.expanded_url+")")
		}
	}

	return tw;
})
```

For the media in each tweet, we are going to do something similar, but in this case, we are going to remove the link from the text itself, and add a new field with all the links of the images. As before, add the following line to the chain.
```js
.map( tw => {
	if( tw.entities.hasOwnProperty("media") ){
		tw.media = [];
		for( let img of tw.entities.media ){
			tw.full_text = tw.full_text.replace( img.url, "");
			tw.media.push( img.media_url_https );
		}
	}

	return tw;
})
```

And for the final touch, and this is just personal preference, we are going to just get the data i want. Said in other way, delete everything that we dont need. Append the following to the train, and we finally will have a json with our twitter archive. This is even still black magic for me, if you want to read something to try to understand it, i recommend [this post](https://codeburst.io/es6-destructuring-the-complete-guide-7f842d08b98f), as its the one i used to write this piece of the code.
```js
.map( ({created_at, full_text, id_str, media,user:{name,screen_name,id_str:id_str_user}, retweeted, retweeted_status_id_str,in_reply_to_status_id_str,in_reply_to_screen_name, user_id_str}) => {
	return {created_at, full_text, id_str, media,user:{name,screen_name,id_str_user}, retweeted, retweeted_status_id_str,in_reply_to_status_id_str,in_reply_to_screen_name, user_id_str}
});
```

## Downloading my data
*But, you lied to me! This is just a json object, we dont have the images, we havent even downloaded the file* its probably what you are thinking, and you are right. That its what we are going to do now. The first step its to get an array with all the media links. For this, we are going to use the already known map and filter functions. We get every *media* field of every tweet, filter the ones that are undefined, and call a new ES6 method called *flat* which takes an array of arrays, and makes a single array with all its elements.

```js
let images = data.timeline.map( tw => tw.media ).filter( url => url ).flat();
```

Now we have everything we need to make our twitter archive, one of the main topics of this post. As the archive consist of a json file with all the twitter text, and several images, the best option in my opinion is to make a zip file with them. For this task, im going to use the [JSZip](https://stuk.github.io/jszip/) library. Although i started trying to make this script as self-contained as possible, its impossible to write my own zip file when we have this excellent library, and we also already used another library, although that was pretty short.

First of all, we are going to create an instace of a zip file and add our json data inside a file called *data.json*
```js
var zip = new JSZip();
zip.file("data.json", JSON.stringify(data.timeline) );
```

Now we need to download each file of our images array, and add them to the zip file. For this task, we are going to loop through each entry in the array, make a request which will return an arraybuffer of its content. You can think of this arraybuffer as the raw binary data of the image. And then add it to the zip file using the same name that it had.
```js
for( let img of images ){
	let res = await fetch(img).then( r => r.arrayBuffer() );
	let name = img.substr( img.lastIndexOf("/") + 1 );
	zip.file( "images/" + name, res, { binary: true, createFolders : true } )
}
```

Now the only thing left to do, is to download this zip file.
```js
zip.generateAsync({type:"blob"})
	.then(function(content) {
		let url = URL.createObjectURL(content);
		window.location = url;
	});
```

## Thoughts about this part
You may be wandering why i decided to do this instead of using any of the thousands tools that already exists. All of them requires that you setup some kind of server, or you give them access to your account, to do who knows what. This way i know what im doing with my profile data. I decided to go with the "console-way" because i dont have too many tweets (226) so it shouldnt be, and wasnt, a problem. What i really liked about this, its that the twitter api its very clean and easy to follow, i almost didnt have any problem understanding it. As all apis should be, the user is happy, and the devs have an easy to use source of data. If you didnt understood this part, but still want to try it for yourself, you can go to the [repository](https://github.com/pudymody/twitter_exporter) where its everything in a single file with instructions to use it.

# Consuming my data
Now that i have my twitter data, its time to show it in my own site. As i said in previous posts, this website is built with Hugo, the way i show it will be dependant to this static site generator. But i think you will probably get some cool ideas to reuse for your site. The first thing we need to do, is set the 4 different types of *"stream actions"* that you can do. They are: A post, a repost, and a reply. (*I will do likes in the future, but for now lets go with this ones.*) At least those are the three that i will be using, but nothing says that in the future i wont use more. To do this, i will make a file for each actions, inside a new section. Another option would be to make everything inside a json file and then do something like i did with the bookmarks, but with this way (files) i could paginate, or assign items to different tags o that kind of things. Lets begin creating a new section, thanks to hugo this is as simple as creating a new folder called *stream* inside the *content* folder. Now lets define the frontmatter that every action will have. We can even define our own fields inside the frontmatter, thats one of the points that make this so powerful for me. Post and repost will have the following fields in common:

```yaml
date: "Creation date"
layout: "post (more of this in a moment)"
syndicateUrl: ["array of links where this action is also published, mostly its alternative in twitter"]
media: ["array of image links"]
inReplyTo: "URL to which we are replying"
```
But reposts will also have the following fields.
```yaml
authorName: "Name of the user who made original post"
authorUrl: "Link to the profile of the user who made the original post"
originalPost: "Link to the post being reposted"
```

And for the content, it will have a markdown version of the tweet, or post, or reply, or whatever it represents.

To generate this file, i used the following script, running in nodejs, im not going to explain how it works, but you can use it if you want.
```js
const fsProm = require("fs").promises;
const data = require("./data.json");

data.map( tw => {
	tw.frontMatter = {
		date: tw.created_at,
		layout: "post",
		syndicateUrl: ["https://twitter.com/pudymody/status/" + tw.id_str],
		media: tw.media || []
	}

	tw.frontMatter.media = tw.frontMatter.media.map(url => "/static/stream/" + url.substr( url.lastIndexOf("/") + 1 ));

	return tw;
}).map( tw => {
	if( tw.retweeted ){
		tw.frontMatter.authorName = tw.user.name;
		tw.frontMatter.authorUrl = "https://twitter.com/" + tw.user.screen_name;
		tw.frontMatter.originalPost = "https://twitter.com/"+ tw.user.screen_name +"/status/" + tw.retweeted_status_id_str;
	}

	return tw;
}).forEach(async function(item){
	let name = item.id_str + ".md";
	if( item.retweeted ){
		name = "rt_" + name;
	}

	let content = "---\n";
	for( let entry in item.frontMatter ){
		content += entry + ": ";
		if( Array.isArray(item.frontMatter[entry]) ){
			content += JSON.stringify(item.frontMatter[entry] );
		}else{
			content += "\""+item.frontMatter[entry]+"\"";
		}

		content += "\n";
	}
	content += "---\n";
	content += item.full_text;

	await fsProm.writeFile(name, content );
})
```

## Showing my content
Now that i have extracted my twitter archive, and i have created the files to show it in my website, its time to create its templates. Thanks to hugo [template lookup order](https://gohugo.io/templates/lookup-order/) i can create only templates that affects the new section. For this, under the *layouts*  folder we are going to create a new one called *stream*, and inside it, we are going to create 4 files named: *list.html*, *single.html* and *tpl_post.html*. The first one is used when we are listing all the content inside the stream section, AKA viewing the stream. The second one, is used when we are vieweing a single action/post. The last one, is made by me, and is going to be used to render the different kind of actions. This is where the *layout* field in the front matter is useful.

```html
{{ partial "header.html" . }}
<h1>{{ .Title }}</h1>
<section class="h-feed">

{{ .Content }}

{{ range .Paginator.Pages }}
  {{ .Render (printf "tpl_%s" .Params.layout) }}
{{ end }}
<ul class="paginator">
  <li><a {{ if .Paginator.HasPrev }}href="{{ .Paginator.Prev.URL }}"{{ end }}>< Previous</a></li>
  <li>{{.Paginator.PageNumber}}/{{.Paginator.TotalPages}}</li>
  <li><a {{ if .Paginator.HasNext }}href="{{ .Paginator.Next.URL }}"{{ end }}>Next ></a></li>
</ul>
</section>
{{ partial "footer.html" . }}
```

This is the *list.html* file, but the *single.html* is practically the same but without the range and the paginator. The first and last partial are global to all the pages, and is where the head tags and footer content its defined. Then comes the title and content of the stream section as itself, but as we dont have any *_index.md* file inside, this will print nothing. Then we loop through the Paginator variable, this is a special variable that Hugo makes for us, which allows us to just display a chunk of all the pages. I make this decision, because i think you dont want to download 200 tweets, when you only want to read the last 10. Either way, you still can go to the next page and read all.```{{ .Render (printf "tpl_%s" .Params.layout) }}``` is where all the magic happens. The render function allows us to, as the name says, render a chunk of html given by the second parameter. Printf, its the classical function, but if you dont know what it does, think of it as a way to make templates and replace text inside a string. With this execution we are generating the string "tpl_VALUE_OF_LAYOUT". **This is NOT a good practice in general**, but as i manage the only possible values of layouts, this is no problem at all. The template for each content is where all the nice things happens. After that, there is the markup for the paginator.

```html
<div class="h-entry">
	{{ if isset .Params "originalpost" }}
		<!-- SVG icon of repost -->
	{{ else }}
		<!-- SVG icon of pen -->
	{{end}}

	<div class="h-entry__content">
		{{ if isset .Params "originalpost" }}
			RT <a href="{{.Params.originalPost}}" rel="nofollow" target="_blank" class="u-repost-of">post</a> by <a href="{{.Params.authorUrl}}" class="p-author h-card" rel="nofollow" target="_blank" >{{.Params.authorName}}</a><br>
		{{ end }}
		<a href="{{ .Permalink }}" class="dt-published u-url">{{.Date.Format "January 2, 2006" }}</a>
		{{ if isset .Params "inreplyto" }}
			- In reply of <a href="{{.Params.inreplyto}}" rel="nofollow" target="_blank" >this post</a>
		{{ end }}
		{{ if isset .Params "syndicateurl" }}
			- Also in:
			{{ range .Params.syndicateurl}}
				{{ $url := urls.Parse . }}
				<a href="{{.}}" class="u-syndication" target="_blank" >{{ $url.Host }}</a>
			{{end}}
		{{ end }}

		<span class="e-content">{{ .Content }}</span>

		{{ if isset .Params "media" }}
			{{ range .Params.media }}
				<a href="{{.}}" class="h-entry__media u-photo"><img src="{{.}}" alt=""></a>
			{{end}}
		{{ end }}
	</div>
</div>
<hr>
```

The first *if* is to check if its a repost, or an original post, to show the correct icon. Inside the content itself, first we check if its a repost, if thats right we show a text informing it, with the original post, and the author of it. then we check if it is a reply, and show a link to what we are replying to. After that, we check if we have url of the same content on other websites and show them. The content itself, and finally we show all the images in the post. **One thing to note is that although we write the fields like inReplyTo, when we use them, we need to lowercase it. I lost around 1 hour because of this. Yes, 1 hour, im not smart.**. All the "voodoo magic" of indieweb microformats its done throught the classes u-\*, or p-\*. I followed the [wiki](http://microformats.org/wiki/h-entry) which is very clear and simple to read.

## Thoughts
As you can see, when we already have all the data, showing it in our own site its not a difficult task. And thats thanks to the power of Hugo. We only created a new file for each post and three templates and everything its done, i think thats an excellent workflow for the user of the app. And at this point, we are almost finishing, at least with syncing our twitter with our website, so both can start from the same point. Next we are going to make that whenever you post something, it will be post in the other place.

# Keeping synced
We have a common ground where our website and twitter have the same data. The next step its to somehow sync them whenever you post something. You could do whats called **POSSE** AKA **Post own site, syndicate elsewhere** or the other alternative **PESOS** AKA **Post elsewehere syndicate own site**. In my case, *PESOS* its the way to go. I don want everything that i post on my site to be posted on twitter, but i DO want everything posted on twitter to be on my site. My first thought was to go with the [twitter activities api](https://developer.twitter.com/en/products/accounts-and-users/account-activity-api.html) which allows you to register a webhook for every action the user makes. But when i tried to apply for it, it requested my cellphone number, and thats a NO-NO from me. Luckily, at the time of writing this part, i have got accepted to the [Github actions beta](https://github.com/features/actions) which lets you run actions on a cronjob, so thats what we are going to do.

## Creating the github action
First of all, lets have a basic understanding of how github actions works. When an events happens, (a push, a pull request, an issue comment, a manual triggered event, a cronjob and many more), it runs whats called a *workflow*. This is a process made of *jobs*. Every job is a collection of actions or commands. What i have found, is that most jobs are just a collection of already made actions, and little to no custom commands. But for this case, we need our own action, which will pull new tweets. Thats right, our action will only pull new tweets, pushing them to the server or running it, are task which will be handled by the workflow. Our actions could be run inside a Docker image, or with NodeJS. As we dont need an specific environment, we are going to use the nodejs option. Im not going to explain all the code, but only what i think its relevant to the context of github actions. If you want, you can read it all [here](https://github.com/pudymody/action_twitter-poll/blob/master/index.js). (And even make a pull request if you find something that could be improved or fixed :) )

```js
const fs = require("fs");
const path = require("path");
const yaml = require("js-yaml");
const got = require("got");
```

First we begin including our dependencies. To make http request, we are going to use the awesome [got](https://github.com/sindresorhus/got), and for creating our yaml frontmatter, we are going to use [js-yaml](https://github.com/nodeca/js-yaml). I havent used it before, but it worked and didnt seem too bloated.

```js
const BASE = process.env.INPUT_BASE;
const IMAGE_PATH = process.env.INPUT_IMAGE_PATH;
const TOKEN = process.env.INPUT_TOKEN;
const USER = process.env.INPUT_USER;
const COUNT = process.env.INPUT_COUNT;
```

Next we define some constants. As you can see all are being set in the environment variables. This is because within an action, you can define a set of *inputs*. This is a map of variables that people can set in their workflow and they will be set as environment variables. So if anyone wants to use this actions, they will only need to set this params in their workflow.

* BASE: Where we are going to put our content files.
* IMAGE_PATH: Where we are going to put the images.
* TOKEN: Our twitter bearer token.
* USER: The user to fetch twitters from
* COUNT: How many tweets to get.

How we keep track of the latest fetched tweet its done in the following way. As you cant modify an environment variable, because the next time its called it will be reseted, i opted for having a file called *LAST_TWEET* in the root of the repository with the id of the last tweet. Simple and clean.

Finally, we need our *action.yaml* file, the one that have all the action metadata, you could think of this file as the package.json of actions.
```yaml
name: 'Twitter-Poller'
description: 'Poll for new tweets and write them to a hugo content file.'
author: 'pudymody'
inputs:
  base:
    description: 'Path where to write content files. Relative to content folder.'
    required: false
    default: './content'
  image_path:
    description: 'Path where to write images of content files. Relative to static folder.'
    required: false
    default: './static/stream'
  token:
    description: 'Twitter token to use the api'
    required: true
  user:
    description: 'Twitter user where to get data'
    required: true
  count:
    description: 'How many tweets to get'
    required: false
    default: 50
runs:
  using: 'node12'
  main: 'index.js'
```
As you can see, inside the *inputs* field, we can define our input variables, and make them required or assign them a default value. Under the runs section, we define our main function and which environment to use. In this case its node version 12.

**One important thing to note its that currently there isn an official way to run npm install inside an action itself without touching the main workflow. Because of this i decided to bundle the node_modules folder. This is a terrible idea, but its the only solution i found at the moment.**

## Defining our workflow
Now its time to finally make the workflow which will run the previous defined action. To do this, we need to create a file in our repository called *.github/workflows/workflow_name.yaml*. In our case, we are going to create the *.github/workflows/twitter.yaml*. Inside it we need to put the following content.
```yaml
name: Tweet sync
on:
  schedule:
  - cron: 0 0 * * 1

jobs:
  build:
    name: Poll
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - uses: pudymody/action_twitter-poll@master
        with:
          base: "./"
          image_path: "./"
          token: ${{ secrets.TWITTER_TOKEN }}
          user: "pudymody"
          count: 10
      - run: git config user.name "$GITHUB_ACTOR"
      - run: git config user.email "$GITHUB_ACTOR@users.noreply.github.com"
      - run: git checkout master
      - run: git add .
      - run: git commit -m "deployed via Publish Action 🎩 for $GITHUB_SHA"
      - run: git push "https://$ACCESS_TOKEN@github.com/$GITHUB_REPOSITORY.git" master
        env:
          ACCESS_TOKEN: ${{ secrets.ACCESS_TOKEN }}
```

The first field its the name of the workflow itself. Then we have the *on* field, this is where we define our events that triggers this workflow. In this case its a cronjob that will be run every monday at 00:00. As i rarely tweet, once a week seems to me a reasonable span of time. Here is where you can define different events, like the push,pull or the [other availables](https://help.github.com/en/articles/events-that-trigger-workflows).

Finally we get to the juicy part, the jobs list. This is the list of different jobs that will be run. The two first fields, *name* and *runs-on* are data to the job itself, the name it has, and the environment it will run on. This could be Mac, Windows or Linux machines. If you want to read about the specs, you can do it [here](https://help.github.com/en/articles/virtual-environments-for-github-actions).

And then comes the *steps*, thats a collection of actions or commands that makes this workflow. If you want to use an action already defined in another repo, use the *uses* key with the following format *{owner}/{repo}@ref*.  Using the *with* field, you could pass a map of different inputs. In this case they are the ones that we defined before.

You will notice that in the token field, we are using a special variable called **secrets**. This is a variable where you can store sensitive secrets to use in workflows and expose them. This is the place where you are going to store TOKENS that have the same permissions as passwords, or other secret keys that you want to keep eyes out. You define them inside the *Secrets* section in the settings of your repo. The commands also have a [list](https://help.github.com/en/articles/virtual-environments-for-github-actions#environment-variables) of environment variables already defined.

Now our workflow does the following things:

1. First uses the checkout action from the official github account. This checkouts the repo so you can use its content. Note here that the @master corresponds to the version of the action, and not the branch we are checking out.
2. We run our previously defined action.
3. Setup our git user with the correct name and email. As this is a virtual machine, we arent logged as ourself.
4. actions/checkout gets us a detached git, so we need to return to the master branch.
5. Basic git actions to add and commit.
6. Finally we push our content. We are using an access_token, which you can get at [your settings page](https://github.com/settings/tokens). This token its the same as a password, so be aware what you do with it.

# Final thoughts
After writing this post, i found out that the way i exported my data was a terrible idea. I tried to export a timeline with around 6000 tweets, and it crashed my chrome instance. But i also found out that with the token that the webclient has, you can use the twitter api, and that would have been a better way to approach things, but i found it a little late. I also cant believe what an amazing product Github Actions is, with little code, and a pair of files in my repository, i have a full system running without any problem. Thats the kind of workflow i want in my tools. Great work Github. The next steps in my way to an indieweb will be recieving whats called a [webmention](https://indieweb.org/webmention) and saving/showing the replies and likes of my post that i recieve in twitter.
