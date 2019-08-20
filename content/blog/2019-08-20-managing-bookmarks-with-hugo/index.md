---
title: Managing my bookmarks with Hugo
date: 2019-08-20
---

## Intro
In my attempt to ditch google out of my life, i have been using Firefox for about a year (*few months after the [Firefox Quantum release](https://blog.mozilla.org/blog/2017/11/introducing-firefox-quantum/) which was on November 14, 2017*), but i always had my Chrome profile and settings *just-in-case*. Until now. After this year using it, i found out that i could live without my Chrome data, so i decided to finally delete it. But its difficult to delete your 8 years old collection of bookmarks like that. After curating and peeking around them, i found out that most of them were just a collection of interesting links,articles or webapps. So i decided to save them for historical reasons here. The first logical step is to curate them, remove all sensitive links, remove duplicates and try to fix or delete broken links.

> As you can see, i have made this account 8 year ago, thats waaay older than i though
![Image showing the creation date of google account: 25/5/11](account_age.png)

## Curating
After some googling i found [this Chrome extension](https://chrome.google.com/webstore/detail/bookmarks-clean-up/oncbjlgldmiagjophlhobkogeladjijl) which does exactly that, find duplicate links in my bookmarks, and check for errors. I only have to run it, and do some googling to fix some broken links.

## Exporting and parsing
To do this, first i use the native google chrome export function, which is found in the [builtin bookmark manager](chrome://bookmarks/). This gives you a list of your bookmarks in an html file. Here i had three options:

* Use it that way or in a markdown file
* Convert it to a csv file
* Convert it to a yaml/toml
* Convert it to a json file

The last three options is because Hugo is able to read and use that formats in template files. In my opinion the best option here is a json file, because it allows me in the future to write some serverless functions to manage them. And almost all languages have a JSON reader library. For this task, i opened the file in a browser and run the following snippet in the console.

```js
function parseDt( el ){
	let obj = {};
	if( el.firstElementChild.tagName == "H3" ){
		let objContent = [...el.children[1].children].filter( e => e.tagName == "DT" ).map( parseDt );
		obj = {
			links: objContent.filter( e => e.type == "link" ),
			type: "folder",
			name: el.firstElementChild.textContent,
			folders: objContent.filter( e => e.type == "folder")
		}
	}else{
		let a = el.firstElementChild;
		obj.name = a.textContent;
		obj.href = a.href;
		obj.type = "link"
	}
	return obj;
}

copy(parseDt( document.querySelector("dt") ));
```

Yes, devtools have the *copy* function, and given a js object will stringify by default its content and copy the output. Awesome feature! This will give me the following JSON scheme:

```json
Entry {
	name: "Name of the entry",
	type: "link|folder",
}

Entry[type=link] {
	name: "Name of the link",
	type: "link",
	href: "URL of the bookmark"
}

Entry[type=folder] {
	name: "Name of the folder",
	type: "folder",
	links[]: "Collection of links in this folder",
	folders[]: "Collection of subfolders in this folder"
}
```

## Showing them
Now the only remaining task is to show them. For this, first im going to create a folder called *data* in the root of my hugo website. This is the folder where hugo reads my data files by default. Inside it, i created the *bookmarks.json* file with the contents copied from the console. This data is only available through templates or custom shortcodes, to appear, i have to create a custom template. This could be done creating the following file *layouts/_default/bookmarks.html*. Now, this is only a template layout, we have to create the content file to let hugo know that we want to use it. To do that, we create *content/bookmarks.md* and in the front matter, we define that we want to use the layout we have just created. That is done adding the following front matter to the *bookmarks.md* file.

```markdown
---
title: "Bookmarks"
layout: "bookmarks"
---
```

Finally, the layout content. Our json file is an array of *Entry[type=folder]*, and given the recursive nature of our collection, the best way to show them is first define the template for a single entry, and then reuse it. To do that, we are going to use what in Hugo its called a *partial*, thats a html file which can be reused and its able to recieve some data. We create the following file *layouts/partials/bookmark_entry.html* and put this inside its content:

```html
<ul>
	<li><h3>{{ .name }}</h3></li>
	<ul>
		{{ range .links }}
			<li><a href="{{.href}}" target="_blank" rel="nofollow">{{.name}}</a></li>
		{{ end }}
	</ul>
	{{ range .folders }}
		{{ partial "bookmark_entry.html" . }}
	{{ end }}
</ul>
```
This partial its going to be used for every entry of type folder. We define an unordered list, the first item its going to be the folder name. Inside this list, we are going to make another one, with all our links. ```{{ range .links }}``` its the syntax used in Hugo template engine to iterate over a collection. And finally we iterate over our folders and use the same logic. *Note here that we arent creating a new list, because our partial already does that when its called.*

Finally, inside our *layouts/_default/bookmarks.html* we have to access our data file. This is done automagically by Hugo and its available inside the *$.Site.Data.filename* variable. We only need to iterate and render it.

```
{{ range $.Site.Data.bookmarks }}
	{{ partial "bookmark_entry.html" . }}
{{ end }}
```

## Final
And thats everything, as you can see its not too difficult to do this. And with the power of serverless functions, or even with the power of a normal server, you can make your own bookmark manager. If you can see mines, [here they are](/bookmarks/)