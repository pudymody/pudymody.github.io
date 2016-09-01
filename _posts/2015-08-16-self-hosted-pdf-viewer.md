---
title: Self hosted pdf viewer like issuu
layout: post
date: 2015-08-16
---

In this post we are going to write a command line program which generates a version of the pdf viewer of [Issuu](http://issuu.com/). [Here](https://pudymody.github.io/Isu) you can see an example.

First of all you need [NodeJS](http://nodejs.org/), i think there are a lot of posts teaching you how to install it.
Then we need to install [GraphicsMagick](http://www.graphicsmagick.org/), under windows this is done by an installer, on linux i think you have to add some repositories, but you could google that, there are lots of results. And under mac you could use [Homebrew](http://brew.sh/)

Then you need to be sure that *gm* is available in your path, you could check that by opening a console terminal a writing *gm*

You also have to install the [Ghostscript pdf interpreter](http://ghostscript.com/download/gsdnld.html) in the same way.

If you want to use it before reading how i made it, you can install it and read the [docs](https://www.npmjs.com/package/isu)
{% highlight sh %}
npm install -g isu
{% endhighlight  %}

Finished installing system dependencies, we begin doing our magic. First we need to start an empty project within a new folder with the command *npm init* and following the steps.
After that you have to install the [GraphicsMagick binding for nodejs](http://aheckmann.github.io/gm/) with the following command *npm install gm --save*

Now create a new file called *index.js* with the following text

{% highlight js %}
var	gm = require('gm');

gm('./1.pdf')
	.density(150,150)
	.quality(100)
	.out('+adjoin')
	.write('./%02d.jpg', function(err){
		if( err ){
			console.log("Error: ", err);
		}
	});
{% endhighlight  %}

Currently what this does its:
* First, it loads the GraphicksMagick bindings
* Loads the file 1.pdf which its in the same folder
* Sets the density reading to 150dpi
* Sets the output quality to 100%
* Sets the adjoin arguments so everypage its converted to its own file
* Writes the file to a file called *page.png* and in case there are some error, logs it to the console

Great! now we have our pdf file converted to a batch of png files, but this isnt useful if we couldnt pass as an argument our file and without our html/js/css viewer, so lets do this by steps.

First, passing our file as an argument. For this task i will use the [yargs](https://www.npmjs.com/package/yargs) package, so lets install it *npm install yargs --save*

Now we have to load our library like this, and also the filesystem apis to check if the passed file exists
{% highlight js %}
var argv = require('yargs').argv,
	fs = require('fs');
{% endhighlight  %}

Before converting our files, we have to check if the passed *file* arguments its a valid file, in case it isnt, we show a message in our console and stop the execution. Here i used the sync version of exists beacuse as a one-call command i think there isnt any performance issue in this case.

{% highlight js %}
if( !argv.file || !fs.existsSync(argv.file) ){
	console.log('The file ' + argv.file + ' isnt a valid file');
	process.exit(1);
}
{% endhighlight  %}

And we also have to replace our gm function with our passed file
{% highlight js %}
gm(argv.file)
{% endhighlight  %}

For better organization we'll create a new folder called *dist* where we are going to store our finished page, and inside this we are going to create another one called *imgs* to store our pdf images.
{% highlight js %}
fs.mkdirSync('./dist');
fs.mkdirSync('./dist/imgs');
{% endhighlight  %}

We have to change our write function to write our files inside this new folder
{% highlight js %}
.write('./dist/imgs/%02d.png', function(err){
	if( err ){
		console.log("Error writing file: ", err);
	}
});
{% endhighlight  %}
Now we can call our app with the following way *node index --file=1.pdf*

Aaaand, we have finished with the process of preparing our file, now we have to move to the viewer. First we are going to create a new folder called tpls where we are going to store our templates files which we are going to compile with jade. So we have to install the [jade module](https://www.npmjs.com/package/jade) with *npm install jade --save* and load it to our app
{% highlight js %}
var jade = require('jade');
{% endhighlight  %}

Inside our tpls folder we are going to create a new file called *index.jade* with the following simple structure
{% highlight jade %}
doctype html
html(lang="en")
head
	meta(charset="UTF-8")
	meta(name="viewport", content="width=device-width, user-scalable=no")
	link(rel="stylesheet", href="style.css")
	title= fileName
body
{% endhighlight  %}
And one called *style.css* with our stylesheet, in which we are going to put the [normalize.css](https://necolas.github.io/normalize.css/) library and a body background color at the end of the file. We also have to set the font size of the body to 0 to get rid of an annoying whitespace down the image. And to finish with the body, we want our pages to be centered in the screen, so we need to add our text-align;
{% highlight css %}
body {
	background-color: #111111;
	font-size: 0;
	text-align: center;
}
{% endhighlight  %}

Now we need to add the styles of every page, to do this we are going to create a class called *page*. Every page should cover the entire height and dont be wider than half the screen ( 2 pages per view ), so first, we need to add our height which will be 100vh, a new unit which represents 100 percent of our viewport *(you can read more [here](https://css-tricks.com/viewport-sized-typography/))* and set our max width to half the width viewport
{% highlight css %}
.page {
	height: 100vh;
	max-width: 50vw;
}
{% endhighlight  %}

After that, we need our body to dont wrap our white spaces, so every page is aligned one next to the other, and we also need to hide our overflowing content.
{% highlight css %}
body {
	background-color: #111111;
	font-size: 0;
	text-align: center;
	white-space: nowrap;
	overflow: hidden;
}
{% endhighlight  %}

Now we need to create a section which will store our pages, in the cover and in the back, it will have only one page and the other will have two pages. This section should cover the entire screen, so we are going to use the magic of viewport units, and should be placed one next to each other, so we need them to be inline block items
{% highlight css %}
.section {
  width: 100vw;
  height: 100vh;
  display: inline-block;
}
{% endhighlight  %}

To prepare our file, we need to know how many pages we had converted, so after all files are written we need to read our dir and pass the file list with our file name and our cover ( first page) and back (last page) to our new template so it knows how to make the structure, and write that parsed template to our file inside our *dist* folder. Also we need to group our files by groups of 2. To do this we are going to use a function called chunk. So we need to rewrite our write function from our *index.js* file
{% highlight js %}
.write('./dist/imgs/%02d.jpg', function(err){
	if( err ){
		console.log("Error writing file: ", err);
		process.exit(1);
	}

	fs.readdir('./dist/imgs', function(err, data){
		if( err ){
			console.log("Error reading files: ", err);
			process.exit(1);
		}

		var cover = data.shift(),
			back = data.pop();

		data = chunk(data, 2);

		var html = jade.renderFile('./tpls/index.jade', { fileName : argv.file, cover : cover, back : back,  pages : data });
		fs.writeFileSync('./dist/index.html', html);
	});
});
{% endhighlight  %}

You also have to add the chunk function to the same file
{% highlight js %}
function chunk (arr, len) {

	var chunks = [],
		i = 0,
		n = arr.length;

	while (i < n) {
		chunks.push(arr.slice(i, i += len));
	}

	return chunks;
}
{% endhighlight  %}

And our new template looks like this.
{% highlight jade %}
doctype html
html(lang="en")
	head
		meta(charset="UTF-8")
		meta(name="viewport", content="width=device-width, user-scalable=no")
		link(rel="stylesheet", href="style.css")
		title= fileName
	body
		.section
			img.page(src="imgs/#{cover}")

		each group in pages
			.section
				each page in group
					img.page(src="imgs/#{page}")

		.section
			img.page(src="imgs/#{back}")
{% endhighlight  %}

What are we doing here? First we create a section with our cover page. Then we loop through each group of pages and create a section for that group. Inside each group we loop through its pages and add them. After that, we create our section for our back page.

If you now open our dist file, you will see that everything its unstyled and broken, thats because we havent copy our style file from our tpls folder to our dist folder, so we are going to do this after we write the index file. You will be saying **Hey i've read the docs and node dont have a method to copy files** and i know, thats why we are going to install a new module called [fs-extra](https://www.npmjs.com/package/fs-extra) which solves this problem and a lot more. *npm install --save fs-extra*. We need to replace our current system apis with this new ones.
{% highlight js %}
fs = require('fs-extra');
{% endhighlight  %}

And with this module, we dont need to create our two folder alone, we could create them with just one call. Awesome! So we get rid of those two mkdirSync calls and replace them with this one.
{% highlight js %}
fs.mkdirsSync('./dist/imgs');
{% endhighlight  %}

And after our function which writes our index file we add
{% highlight js %}
fs.copySync('./tpls/style.css', './dist/style.css');
{% endhighlight  %}

Now we have everything working, but HEY i cant change pages/i can only read the first one. Take it easy boy, step by step, now we are going to create inside our tpl folder a new file called *app.js* in which we are going to handle this kind of things.

First we are going to create an object called App to store everything we need.

Inside it we are going to create a property called *_currentPage* which will handle our current page.

Next we are going to get the total of sections inside our property *_totalPages*

Now we are creating a method called go to go to the page given by the param, we need to check that its a valid page. If its a valid page, we set our _currentPage to the given and we "move" our body element with css3 transform to show our current page.

The next method is the "next" which checks that there is still more pages to see, and if there are, it moves one pages

And the following the "prev" which do the same but with previous pages

Our *app.js* file now looks like this. We need to add it to the end of the jade file, and copy it like we did with the style file
{% highlight js %}
var App = {
	_currentPage : 0,
	_totalPages : document.querySelectorAll('.section'),

	go : function( page ){
		if( typeof page == 'undefined' || page < 0 || page > this._totalPages.length - 1 ){
			console.error('Invalid page');
			return;
		}

		this._currentPage = page;
		document.body.style.transform = "translate3d( "+ (page*100*-1) +"%,0,0)";
	},

	next : function(){
		if( this._currentPage + 1 > this._totalPages.length - 1 ){
			return false;
		}

		this.go( this._currentPage++ );
	},

	prev : function(){
		if( this._currentPage - 1 < 0 ){
			return false;
		}

		this.go( this._currentPage-- );
	}
}
{% endhighlight  %}

If you are a developer and like moving through pages with the console now you can use it, but hey! we want a finished product for the final user, so now we need two things, navigate through pages with our keyboard and our mouse.

For our keyboard we are going to listen for the keyup event on the document, and if its the left or the right we are going to move pages.

For the keyboard we are going to listen for the mouseup event, and if the press was in the left half, we go backwards, and if it was in the right half, we go to the next

So the only things we have to add to the end of the app.js file is this:
{% highlight js %}
document.addEventListener('keyup', function(e){
	var keys = { 37 : 'prev', 39 : 'next' };

	if( !keys[ e.keyCode ]  ){
		return false;
	}

	App[ keys[ e.keyCode] ]();
}, false);

document.addEventListener('mouseup', function(e){
	var pos = e.clientX,
		halfScreen = document.body.clientWidth / 2;

	if( pos > halfScreen ){
		App.next();
	}else{
		App.prev();
	}
}, false);
{% endhighlight  %}

"Its not moving when we change pages" Thats beacuse i forgot to add the transition property to the body element. Sorry :)
{% highlight css %}
body {
	background-color: #111111;
	font-size: 0;
	text-align: center;
	white-space: nowrap;
	overflow: hidden;
	transition: transform 1s;
}
{% endhighlight  %}

We need to show in which page the user is, so to do this, we need to add to our jade template a div with the class .paginator and add it some css.
{% highlight css %}
.paginator {
  position: fixed;
  bottom: 10px;
  left: 10px;
  background-color: rgba(0, 0, 0, 0.8);
  color: #FFF;
  font-size: 1rem;
  z-index: 1;
  padding: 8px 16px;
  border: 1px solid #333;
  border-radius: 3px;
}
{% endhighlight  %}

Also we need to wrap our sections inside a div with the class wrapper, and pass the transition declaration from our body to the wrapper class
{% highlight  jade %}
doctype html
html(lang="en")
	head
		meta(charset="UTF-8")
		meta(name="viewport", content="width=device-width, user-scalable=no")
		link(rel="stylesheet", href="style.css")
		title= fileName
	body
		.wrapper
			.section
				img.page(src="imgs/#{cover}")

			each group in pages
				.section
					each page in group
						img.page(src="imgs/#{page}")

			.section
				img.page(src="imgs/#{back}")

		.paginator
		script(src="app.js")
{% endhighlight  %}
{% highlight  css %}
.wrapper {
  transition: transform 1s;
}
{% endhighlight  %}

And because now everything its wrapped, we dont need to move the body, we need to move the wrapper, so we create a new property with our wrapper dom element, and update our go function. We also get the paginator and update it in the go function. And we need to update the paginator when the app is open.
{% highlight  js %}
var App = {
	_wrapper : document.querySelector('.wrapper'),
	_paginator : document.querySelector('.paginator'),

	go : function( page ){
		this._paginator.innerHTML = (this._currentPage + 1) + " of " + this._totalPages.length;
		this._wrapper.style.transform = "translate3d( "+ (page*100*-1) +"%,0,0)";
	}
};
App._paginator.innerHTML = (App._currentPage + 1) + " of " + App._totalPages.length;
{% endhighlight  %}

Now everything is working YEEY!!!. But i want to use this as a global module. Dont worry, we only need to make some changes.  First, we need to require the paths apis, and then we need to change the three calls to the files inside the tpl folder to this
{% highlight  js %}
var path = require('path');

var html = jade.renderFile(path.join(__dirname, 'tpls', 'index.jade'), { fileName : argv.file, cover : cover, back : back,  pages : data });
fs.copySync(path.join(__dirname, 'tpls', 'style.css'), './dist/style.css');
fs.copySync(path.join(__dirname, 'tpls', 'app.js'), './dist/app.js');
{% endhighlight  %}
