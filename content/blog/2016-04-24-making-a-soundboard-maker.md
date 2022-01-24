---
title: Making a soundboard maker
date: 2016-04-24
issueId: 26
---

The title is a little "metaish" *(making a maker)*, isnt it?. Nevermind, this all started because with my friends we are use to play the sound when you level up in the [MuOnline](https://en.wikipedia.org/wiki/Mu_Online) game whenever someone of us did something stupid. One friday night, i was so bored that i made a [little soundboard](https://pudymody.github.io/argenmu-soundboard/) with sounds of the game, you can read the [source](https://github.com/pudymody/argenmu-soundboard) but if you are going to read this post, you will see it here. The next day, when i showed it to my friends, they went crazy, the wanted to make soundboards for everything you could think of. The first thing that came to my mind was "Why dont i make an app to make soundboards? I bet the web can do that". Another boring night and i came up with this app which im going to explain in this post. If you just want to use the app, [here you have](https://pudymody.github.io/soundboard-maker/)

# Guide
This post is going to be divided in different sections.

1. Maker code
	0. Dependencies
	1. Getting  the dropped files
	2. Making a reusable component to handle the name and category of the file
	3. Generating the file
	4. Making the web offline first

2. Soundboard code
	0. Playing the selected sound
	1. Making the soundboard offline first

## Maker code

### 1. Dependencies
For the visual design, im going to use [Material Design Lite](https://getmdl.io) *(im not going to explain the html and css used, if you want to know about it, visit the mdl docs)*, an [extra-extra small pubsub implementation](https://github.com/dciccale/xxspubsub) to handle the events and [JSZip](https://stuk.github.io/jszip/) to make the final zip file with the soundboard code.

### 2. Getting the dropped files
To get the dropped files, first of all we have to make an element where files will be dropped, in our case is a div with the class *drop__container* and add the following js.

```html
	<div class="drop__container"></div>
```

```js
var dropZone = document.querySelector('.drop__container');
	dropZone.addEventListener('dragenter', function handleDragEnter( evt ){
		evt.target.classList.add('drop__container--success');
	});

	dropZone.addEventListener('dragleave', function handleDragLeave( evt ){
		evt.target.classList.remove('drop__container--success');
	});

	dropZone.addEventListener('dragover', function handleDragOver( evt ){
		evt.stopPropagation();
		evt.preventDefault();
		evt.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
	});

	dropZone.addEventListener('drop', function handleDrop( evt ){
		evt.stopPropagation();
		evt.preventDefault();
		evt.target.classList.remove('drop__container--success');

		var droppedFiles = evt.dataTransfer.files,
			files = [],
			i = 0, l = droppedFiles.length;

		for( ; i < l; i++){
			files.push( droppedFiles[i].name );
		}

		XXSPubSub.publish('drop.add', [files]);

	}, false);
```

In the first line, we get a reference to our DOM object using the querySelector function and then we attach drag and drop events.

In the *dragenter* and *dragleave*, we only toggle a class to let the user know that he can drop the files (it turns the div into green).

In the *dragover* we need to stop the browser from doing the default action when you drag the files, so we are able to handle it ourselves, and we also define the cursor which will be used.

In the *drop* event is where all the magic happens. First, we stop the browser from handling the files, (usually tries to open it and fallbacks to download it), we loop through each dropped file and add the name to an array. Finally we publish an event with our PubSub implementation, with our filenames as the data.

### 3. Making a reusable component to handle the name and category of the file
This is just beacuse i dont want to use any framework, but you could use whatever you want, angular, jquery, react, o whatever framework is the hot topic at the moment you are reading this.

```js
function Sound( data ){
	this.data = data;
	this._buildDOM();
}

Sound.prototype = {
	data : {},
	$ : {},

	_buildDOM : function(){

		var inputOuter = document.createElement('div');
			inputOuter.className = "mdl-cell mdl-cell--12-col mdl-textfield mdl-js-textfield";

		var name = document.createElement('input');
			name.type = 'text';
			name.className = "mdl-textfield__input";
			name.placeholder = 'Name of the sound';
			name.required = true;
			name.addEventListener('blur', function(evt){
				this.data.name = evt.target.value;
			}.bind(this));

		var nameOuter = inputOuter.cloneNode();
			nameOuter.appendChild(name);

		var category = document.createElement('input');
			category.type = 'text';
			category.className = "mdl-textfield__input";
			category.placeholder = 'Category of the sound';
			category.required = true;
			category.addEventListener('blur', function(evt){
				this.data.category = evt.target.value;
			}.bind(this));

		var categoryOuter = inputOuter.cloneNode();
			categoryOuter.appendChild(category);

		var title = document.createElement('span');
			title.className = 'mdl-cell mdl-cell--12-col';
			title.innerText = this.data.file;

		var wrapper = document.createElement('li');
			wrapper.className = 'mdl-list__item mdl-grid';
			wrapper.appendChild(title);
			wrapper.appendChild(nameOuter);
			wrapper.appendChild(categoryOuter);

		this.$.name = name;
		this.$.category = category;
		this.$.wrapper = wrapper;
	},

	getDOMNode : function(){
		return this.$.wrapper;
	},

	getJSON : function(){
		return this.data;
	}
};

```

*You could easily make it an ES6 class (indeed i think its the best idea, but i wanted to give some fallback without any transpiler)*

First of all, we define a "class" for our sound object which gets some data and save it internally and then it calls the *_buildDOM* function which will construct our representation in the dom.

**_buildDOM:** It just create a bunch of inputs and divs, and stores them in its *$* variable for future reuse. The main thing inside this function its that we listen for the *blur* events in our inputs and updates our internal data to the new values.

**getDOMNode:** It only returns our main DOM object so we can add it wherever we want.

**getJSON:** I think its self-explained, but it return our data object

### 4. Generating the file
Until now, we have the reusable sound element, and the dropped files event, but they arent tie, so we are going to do that.

```js
var App = {
	_sounds : [],
	$ : {},
	init : function( files ){
		this._buildDOM();
		this._bindEvents();
	},

	addFiles : function( files ){
		files.forEach(function(item){
			var song = new Sound({ file : item });
			this._sounds.push( song );
			this.$.list.appendChild( song.getDOMNode() );
		}.bind(this));
	},

	_buildDOM : function(){
		this.$.form = document.querySelector('.wrapper');
		this.$.name = document.getElementById('appName');
		this.$.list = this.$.form.querySelector('.item-list');
	},

	_bindEvents : function(){

		XXSPubSub.subscribe('drop.add', this.addFiles.bind(this));
		XXSPubSub.subscribe('app.build', this.create.bind(this));

		this.$.form.addEventListener('submit', function( e ){
			e.preventDefault();
			XXSPubSub.publish('app.build');
		});
	},

	create : function(){

		// get files
		var files = this._sounds.map(function( sound ){
			return sound.getJSON();
		});

		// create first service worker
		var sw = this._generateSW( files );

		// make an object with the sounds grouped by category
		var categories = files.reduce(function( prev, current ){
			current.category = current.category.trim().toLowerCase();
			if( !prev.hasOwnProperty( current.category ) ){
				prev[ current.category ] = [];
			}

			prev[ current.category ].push( current );

			return prev;
		}, {});

		// make tabs and containers in index
		var index = this._generateIndex({ name : this.$.name.value, files : categories });

		// make zip
		var zip = new JSZip();
			zip.file("sw.js", sw);
			zip.file("index.html", index);

			zip.file("material.min.js", "material.min.js file content");
			zip.file("material.min.css", "material.min.css file content");

		zip.generateAsync({type:"blob"}).then(function(content){
			var a = document.createElement('a');
				a.download = 'soundboard.zip';
				a.href = URL.createObjectURL(content);
				a.click();
		});
	},
};

App.init();
```

First of all we make an App object with our entire app logic. The *_sounds* property will hold our sounds objects and the *$* will hold references to our DOM objects.

The *init* function its our starting point, what make the app run. First, it calls the *_buildDOM* function, which only gets references of DOM objects of the main form, the input with our app name, and the ul where we are going to store our sounds objects and saves them. It also calls the *_bindEvents* function, which subscribes to the *drop.add* event with the *addFiles* function, and to *app.build* with the *create* function. And whenever the main form is submited, it publish to the *app.build* event.

**addFiles:** Its a function which will be called whenever the user drops a file. It gets the list of dropped file names, loop through each one, creates a new *Sound* object, saves it to the *_sounds* internal property, gets its DOM representation and append it to the list we saved before in our *_buildDOM* function.

**create:** This is were the final file is generated. First, we get every representation as object of our saved sounds objects. Then we call our *_generateSW* function giving this data, which will return an string representing our soundboard service worker. Im not going to explain that function beacuse its just a lot of strings and arrays concatenating. Then we make a new object with our sounds grouped by categories, and call our *_generateIndex*, similar to the *_generateSW* function. Im grouping into categories, because we are going to make a tab for everyone. Then we create a new instance of JSZip, add our index and service worker files, and our MDL css and js. Then we call the *generateAsync* function which resolves to a promise, with the blob of our file. When the promise resolves, we create an url for our blob, add it to an "invisible" anchor tag, set our download file name, and click it. This to user translates to the file being downloaded.

### 5.Making the web offline first
To make the web offline first, we are going to use the current hot topic, Service workers. The worker its documented itself, and its based in the one from [CSSTricks](https://css-tricks.com/serviceworker-for-offline/), so you can read the source or read more in his blog post.

## Soundboard code

### Playing the selected sound
To do this, we are going to use a technique called event delegation. This is, we listen for every click in the document, and if we meet a certain criteria, we fire certain callback. You can read more about this technique in [this awesome post](http://codepen.io/32bitkid/post/understanding-delegated-javascript-events)

```js
var playAudio = (function(){
	var $AUDIO = document.getElementsByTagName('audio')[0];
	return function( url ){
		if( !$AUDIO.paused ){
			$AUDIO.pause();
		}
		$AUDIO.src = url;
		$AUDIO.play();
	}
}());
document.addEventListener('click', function(e){
	if( e.target.dataset.hasOwnProperty('url') ){
		playAudio('sounds/' + e.target.dataset.url);
		return;
	}
}, false);
```
What we are doing here in the playAudio variable is calling a self executing fuction, which returns a function, that plays the given url audio. And we listen for every click in the document, and when the target has the data-url attribute, we play that url.

### Making the soundboard offline first
This is the same as before, you can read the source of the previous one, or read the blog post.
