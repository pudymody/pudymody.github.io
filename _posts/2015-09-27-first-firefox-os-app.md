---
title: Making our first Firefox OS App (NoCrop)
---

**I've currently made a submission to the firefox marketplace, so whenever its available i will post the link here**

During the last months, there is a new trending type of images at least in my social networks. What are they about? They are square photos, with the main photo centered, and in the background the same image blurred. Dont get it? Here you have an example

![Example](http://i.imgur.com/MhiKn7K.png)

How and why are they made?

This is because Instagram used to not allowed photos that werent squared size, so they have to edit them. How? My friends told me that they use an app called [NoCrop](https://play.google.com/store/apps/details?id=com.nbdapps.nocrop&hl=es_419) which is available for Android and iOS, so i thought ¿Can this be made with web technologies so i can use it almost everywhere?. Well, i started a personal hackaton to do it, and i could also practice some Firefox OS apps development.

The first step was to download the [Firefox Developer Edition](https://www.mozilla.org/es-AR/firefox/developer/) which came with the Firefox OS simulator. If you dont know how to configure it, you can google it, there are lots of tutorials.

Now we begin developing our app. First we need to create a folder and inside it a file called *manifest.webapp* with the following content

{% highlight  json %}
{
  "version": "0.1.0",
  "name": "NoCrop",
  "description": "NoCrop version for Firefox OS",
  "launch_path": "/index.html",
  "icons": {
    "16": "/icons/icon16x16.png",
    "48": "/icons/icon48x48.png",
    "60": "/icons/icon60x60.png",
    "128": "/icons/icon128x128.png"
  },
  "developer": {
    "name": "Your name",
    "url": "http://example.com"
  },
  "type": "privileged",
  "permissions": {
    "device-storage:pictures":{ "access": "readwrite" }
  }
}
{% endhighlight  %}
The keys version, name, description, launch_path, icons and developer i think are self-explained. We need to set our type to priviliged because we are going to use de Storage apis which currently are only available to priviliged apps. Inside our permissions key we are setting that we want access to read and write to our pictures storage.

Now we need to create our launch_path file, so we create our index.html file.
{% highlight  html %}
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,user-scalable=no,initial-scale=1">
    <title>NoCrop</title>
    <link rel="stylesheet" href="/css/style.css">
    <script src="/js/app.js" defer></script>
  </head>
  <body>
    Please, select your image.
  </body>
</html>
{% endhighlight  %}

As defined before, we have to create our style and app files. First we are going to make a folder called css and inside it a file called *style.css* in which we are going to put our styles
{% highlight  css %}
body {
	display: flex;
	flex-direction: column;
	text-align: center;
	justify-content: center;
	height: 100vh;
	margin: 0;
}

body.is-success {
	background:  #2ECC40;
}

body.is-wrong {
	background: #FF4136;
}
{% endhighlight  %}
Nothing strange, just some basic styling.

Here is where the magic starts, first we create a folder called js, and inside it our app.js file

Inside it we are going to put our *[StackBlur](http://www.quasimondo.com/StackBlurForCanvas/StackBlurDemo.html)* dependency, but we need to make a little change.
Look for the line which says *function stackBlurCanvasRGB*, after that, there is a line where it declares a var called canvas, you have to change its value to *id*
{% highlight  js %}
var canvas  = id;
{% endhighlight  %}
We have to do this, so we can blur a canvas passing its dom object, and not its ID.

From now on, we are going to make a lot use of Promises, so if you dont know you must read [this article](http://www.html5rocks.com/en/tutorials/es6/promises/?redirect_from_locale=es)

FirefoxOS allows us to launch "WebActivies" which launches an action and let another app handle it, we are going to make one which let us select an image, no matter what app the user wants to use. And to prevent callback-hell we are going to "promisify" it
{% highlight  js %}
function pickPromised(){
	return new Promise(function(resolve, reject){
		var activity = new MozActivity({
			name: "pick",
			data: {
				type: "image/*"
			}
		});

		activity.onsuccess = function() {
			resolve(this.result);
		};

		activity.onerror = function() {
			reject(this.error);
		};
	});
}

{% endhighlight  %}
First we declare a function called pickPrmoised which returns a promise. Inside our promise, we create a new activity which calls the pick action allowing it only select images. And resolve the promise depending its result

The next function is one which takes a blob image, and return a Image object because we need to get its width and height to do some math fun.
{% highlight  js %}
function blobToImg( url ){
	return new Promise(function( resolve, reject ){
		var src = URL.createObjectURL( url ),

			img = new Image;
			img.src = src;

			img.onload = function(){
				resolve(this);
			}

			img.onerror = function(){
				reject(this);
			}

	});
}
{% endhighlight  %}
Again it returns a promise, in which we are going to convert our blob to a string available to use as a src object. Then we create a new image, set its src and resolve our promise according to the result.

If you are tired or dont feel well, come back later, because here is where we are going to do all the math crazy stuff.

{% highlight  js %}
function imgToCanvas( img ){
	var width = img.width,
		height = img.height,
		size = Math.max(width, height),
		x,y;

		$Canvas = document.createElement('canvas');
		$Canvas.width = size;
		$Canvas.height = size;

		var $Context = $Canvas.getContext('2d');

		var finalHeight, finalWidth,
			bgX, bgY,
			imgRatio = ( width / height );

		if( width > height ){
			x = 0;
			y = (size / 2) - (height / 2);

			finalHeight = size;
			finalWidth = (size * imgRatio);
		}else{
			y = 0;
			x = (size / 2) - (width / 2);

			finalWidth = size;
			finalHeight = (size / imgRatio);
		}

		bgX = Math.abs((finalWidth - size) / 2) * -1;
		bgY = Math.abs((finalHeight - size) / 2) * -1;

		$Context.drawImage( img, bgX, bgY, finalWidth, finalHeight );
		stackBlurCanvasRGB($Canvas, 0, 0, size, size, 15)

		$Context.drawImage( img, x, y );
		URL.revokeObjectURL( img.src );
		delete img;

		return $Canvas;
}
{% endhighlight  %}

* First we define a function called imgToCanvas which takes the image object as argument.
* Then we define some variables with its width, height, and the size we are going to square. Because we dont want to cut the image, we need to get the maximum number.
* Now we create a new canvas and set its width and height to be square, and we get its 2d context so we have the drawing apis.
* We also need to define the final height and width of the background image, its offset to be centered, and the image ratio to resize keeping it.

Here comes some of the magic

* If the width is greater than the height it means that we have to center it vertically, so we set our x value to 0 ( beginning ) and our y value to half the canvas size minus half the image size ( thats the math begin centering block things ). It also means that the bg has to fulfill the height, so we set it as the canvas height, and we use the aspect ratio to keep it nice.
* If the height is greater than the width, its almost the same, but the other way round.

Now to center the background, we need to take the size which is outside the canvas ( offcanvas ) and center that piece. Because the drawing function takes the offset from left, to right, that amount we need it as a negative number, so we take the absolute number and the product by -1

Having all of math things, we need to draw the image. After drawing it, we need to blurry it ( we havent drawn the main image yet, just the background). Here im using a 15 radius, but you can change it, or modify the app to let the radius be dinamic.

After making the background, we need to draw our image. We also free memory from our src-object from the blob, and delete the image. And return our canvas element.


We are almost there, now we need to save this canvas to an image. First we need to convert our canvas to a blob object, so we are going to make a function for that.
{% highlight  js %}
function canvasToFile( canvas ){
	return new Promise(function( resolve, reject ){
		canvas.toBlob(function( blob ){
			resolve(blob);
		});
	});
}
{% endhighlight  %}
This function takes a canvas, object and return the toBlob method as a promise. Nothing strange to explain here.

Now we have our blob object, but we need to save it. Functions to the rescue
{% highlight  js %}
function saveFile( file ){
	return new Promise(function( resolve, reject ){
		var store = navigator.getDeviceStorage("pictures"),
			save = store.add(file);

		save.onsuccess = function () {
			resolve(this);
		}

		save.onerror = function () {
			reject(this.error);
		}
	});
}
{% endhighlight  %}
I guess that you already know that this function takes the file as an argument and return a promise. Inside it we first get the *pictures* storage and assign it to a variable. Then we call the *add* method to save our file to the storage. And then we resolve our promise according to its result.

We have every part of our app, now we need to create a function to chain everything.
{% highlight  js %}
function pickImage(){
	pickPromised()
		.then( e => e.blob )
		.then( blobToImg )
		.then( imgToCanvas )
		.then( canvasToFile )
		.then( saveFile )
		.then( e => alert('Success') )
		.catch( e => alert(e) );
}
{% endhighlight  %}
It first called our pickPromised method, then using arrow functions to keep the syntax clean we return the blob property form the selected file, And call our chain of functions. If everything was ok, we alert a successful message, otherwise we alert the error.

Great, now we have everything, but we need to call our pickImage function, so we listen for click events and call it.
{% highlight  js %}
document.body.addEventListener('click', pickImage, false);
{% endhighlight  %}

Now, before picking our image, we need to stop listening for our click event, to prevent double image submit. So before our pickPromised call, we remove the listener
{% highlight  js %}
	document.body.removeEventListener('click', pickImage);
{% endhighlight  %}

And inside our success callback, we are going to change the background and the text of the body. The same for the error callback
{% highlight  js %}
	.then( saveFile )
	.then( e => { document.body.classList.add('is-success'); document.body.innerHTML = 'Success, see it inside your gallery'; } )
	.catch( e => { document.body.classList.add('is-wrong'); document.body.innerHTML = 'Something went wrong' } );
{% endhighlight  %}

We're done, now you can test it inside the simulator or if you have a FirefoxOS cellphone inside it.


With this post i want to show how easy is to build apps for this platform and how web technologies are approaching towards native apps.

You can also read the source code [here](https://github.com/pudymody/NoCrop-fxos)
