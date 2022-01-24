---
title: Making images with an excel file
date: 2016-09-07
issueId: 27
---

The other day, i was with a friend and after a few beers, the idea of resizing every cell to a 1x1 pixel size in an excel file and styling its background to match a pixel in an image came out. Loving to make apps and script without any sense, i decided to make a web app who would do it. So this post is going to be about its making.

You can use it right now from your browser [here](https://pudymody.github.io/image-to-excel-grid/) and this is what you get using the classical lenna image (*i like showing the final product first*)
![Example](http://i.imgur.com/NznlVm1.jpg)

In this post we're going to use the following Apis, you only need to know the basics

* [WebWorkers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers)
* [Promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
* [Canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API)

First of all, we are going to make an input to select our image, and include our js file and a little modified version of [JS-xlsx](https://github.com/SheetJS/js-xlsx)

```html
<label for="file" class="btn btn--upload">
	<input type="file" id="file">
	Please, select your image.
</label>
<script src="app.js" charset="utf-8"></script>
<script src="xlsx.core.min.js" charset="utf-8"></script>
```

Now, in our app.js file, first we are going to get a reference to our input and create a new instance of our WebWorker

```js
var $file = document.querySelector('input');
var imageWorker = new Worker('worker.js');
```

Then we are going to listen for the *change* event in our input, get its first file, and call our *makeCanvas* function which will return a *promise* with a canvas with the image drawn on it. Then we are going to pass the imageData of our canvas into our WebWorker

```js
function makeCanvas( file ){
	return new Promise(function( resolve, reject ){
		var url = URL.createObjectURL(file);
		var img = new Image();
		img.onload = function(){
			var canvas = document.createElement('canvas');
				canvas.width = this.width;
				canvas.height = this.height;

			var ctx = canvas.getContext('2d');
			ctx.drawImage( this, 0, 0 );
			URL.revokeObjectURL( this.src );
			resolve(canvas);
		};
		img.onerror = reject;
		img.src = url;
	});
}

$file.addEventListener('change', function(e){
	document.body.classList.add('is-loading');
	var file = e.target.files[0];
	makeCanvas(file)
		.then(function( canvas ){
			var imageData = canvas.getContext('2d').getImageData(0,0, canvas.width, canvas.height );
			imageWorker.postMessage(imageData);
		})
		.catch(console.error);
});
```

## WebWorker code
Now here is where all the magic happens, first we need to create a new file called *worker.js*. There we are going to make two functions which will help us convert colors from rgb to hex and import our *js-xlsx* file

```js
importScripts("xlsx.core.min.js");
function componentToHex(c) {
    var hex = c.toString(16);
    return hex.length == 1 ? "0" + hex : hex;
}

function rgbToHex(r, g, b) {
    return componentToHex(r) + componentToHex(g) + componentToHex(b);
}
```

Then we are going to attach a function to be executed everytime we get data into our webworker.

```js
self.onmessage = function(){}
```

**The following code is going to be inside in our *onmessage* function, i've stripped it to explain it piece by piece**

First of all, we get our imageData passed, which is a flatten array, and convert it to an array of objects with its rgba values separated
```js
var data = e.data;
var parsed = { height : data.height, width : data.width, data : [] };
for( var i = 0, l = data.data.length; i < l; i+=4){
	parsed.data.push({
		r : data.data[i],
		g : data.data[i+1],
		b : data.data[i+2],
		a : data.data[i+3]
	});
}
```

Now we need to make our spreadsheet object. To do this, first we are going to figure out in wich row and column we are. Then we convert this to a valid cell id, and set it as the key in our object and its value to a style with our pixel color as background. The "official" version of js-xlsx doesnt allow custom styles to be set, so i have to use [protobi's version](https://github.com/protobi/js-xlsx)
```js
var dataFile = parsed.data.reduce(function( prev, current, index ){
	var currentRow = Math.floor(index / parsed.width);
	var currentColumn = index % (parsed.width);

	var id = XLSX.utils.encode_cell({ c: currentColumn , r: currentRow});
	prev[id] = {
		t : 's',
		v : "",
		s : {
			fill : {
				patternType : "solid",
				fgColor : { rgb: rgbToHex(current.r, current.g, current.b) },
				width: 2
			}
		}
	};

	return prev;
}, {});
```

Now we need to set our range of cells, and set the column width to be 1px. As neither of two allow us to set our row height, i have to edit the file and set it manually, so no step for this. We also need to make our workbook object, which is going to be written.
```js
dataFile["!ref"] = XLSX.utils.encode_range({
	s : { c: 0, r: 0},
	e : { c: data.width - 1, r: data.height - 1},
});

dataFile["!cols"] = [];
for( var i = 0; i < data.width; i++){
	dataFile["!cols"].push({
		wpx : 1
	});
}

var wb = {
	SheetNames : ["Image"],
	Sheets : {
		"Image" : dataFile
	}
};
```

Finally, we write our wokbook, create a blob for it and a url which is going to be passed to our main thread.
```js
function s2ab(s) {
  var buf = new ArrayBuffer(s.length);
  var view = new Uint8Array(buf);
  for (var i=0; i!=s.length; ++i) view[i] = s.charCodeAt(i) & 0xFF;
  return buf;
}

var wbout = XLSX.write(wb, {bookType:'xlsx', bookSST:true, type: 'binary'});
var blob = new Blob([s2ab(wbout)], {type : "application/octet-stream"});
var url = URL.createObjectURL(blob);
postMessage(url);
```

Our final step is to handle our data back from the worker so in our app.js file we need to listen for the onmessage event. What we are only doing here is creating a new *a* tag with the url to our workbook's blob and appending it to the body.
```js
imageWorker.onmessage = function(e){
	var a = document.createElement('a');
		a.download = "image.xlsx";
		a.href = e.data;
		a.innerText = "Download image";
		a.className = "btn btn--download";
	document.body.appendChild(a);
	document.body.classList.remove('is-loading');
};
```

And thats all the magic you need to know!

*PD: Yes, i know i could use Service Workers to make it a fully operational web app, but thats not the point of the post*

*PD II: Yes, i also know that i could use webworkers in previous posts, but i dont know why i didnt*
