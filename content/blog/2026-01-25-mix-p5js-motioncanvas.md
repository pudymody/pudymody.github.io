---
title: "A mix between p5.js and MotionCanvas"
date: 2026-01-25
issueId: 146
---

> This is mostly a copy and paste from the real [index page](https://pudymody.github.io/experiment-animation-engine/) of the project.

---

> If you already know what this is all about or just want to see the editor and start playing you can go directly to the [editor](https://pudymody.github.io/experiment-animation-engine/editor.html)
> If source code is more of your thing, its available on [github](https://github.com/pudymody/experiment-animation-engine).

## Intro

Some time ago i tried to start toying around with making some of those beautiful programming/math videos you see on internet. Like the ones from [3blue1brown](https://www.youtube.com/@3blue1brown), [Freya Holmér](https://www.youtube.com/@acegikmo) or [Sebastian Lague](https://www.youtube.com/@SebastianLague). I tried the big names in the space, [Motion Canvas](https://motioncanvas.io/), [Manim](https://www.manim.community/) and [p5.js](https://p5js.org/) but none of them checked all the items in my list.

Both Motion Canvas and Manim made you download a lot of dependencies and build some others just to start playing around. Manim has an online playground but is just a Jupyter notebook that takes a while to start. Here is where i believe p5 wins. Along its lovely and open comunity, you can just browse to the [p5.js editor](https://editor.p5js.org/) and start playing. The problem is that p5 its geared towards _interactive experiences_ where i wanted more of a _keyframe animations_ like the others.

The easiness of p5 (or something in those lines) and the paradigm of Motion Canvas and Manim. That was the goal. First i started doing [some things with lua and rust](https://github.com/pudymody/experiment-animation-engine-rust-) in an attempt to have a single binary file and dont have to build and download a lot of dependencies. Then i lost motivation and didnt like lua that much, it was just beacuse it's the default standard for embedded languages. Then i tried some more with javascript + rust but at this point i thought _Why not do it fully in the browser?_. It turns out you can export video using something like [mediabunny](https://mediabunny.dev/).

This is what was born out of this journey. Its still in an alpha/beta state. Lots of things missing and probably lots of edge cases i missed. And thats without counting the bugs.

But you can have something like this made entirely in the browser. You can read and play around in the [full editor](https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Fcircle_draw.js). Or you can continue reading for some details and documentation.

{{< rawhtml >}}
<iframe src="https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Fcircle_draw.js&amp;layout=full" style="width: 100%;border: none;max-width: 960px;aspect-ratio: 16/9;display: block;"></iframe>
{{< /rawhtml >}}

## Getting Started

Animations are defined in _Scenes_. A Scene is nothing more than a .js file with a default exported class that matches the following interface.

- instance.width: Width of the resulting animation
- instance.height: Height of the resulting animation
- instance.endTime: Duration in milliseconds of the resulting animation
- instance.currentTime: Current time in milliseconds. This is set by the player or exporter.
- async instance.setup(): Asyncronous function that will setup the animation. More of this later
- instance.draw(ctx): Draw function that will receive a [CanvasRenderingContext2D](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D) object and should draw the animation.

Lets create a very basic one that will run for 1 second and print the current time in the center of the screen of size 1920x1920 pixels.

{{< rawhtml >}}
<iframe src="https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Fscene_barebones.js" style="width: 100%;border: none;max-width: 960px;aspect-ratio: 16/9;display: block;"></iframe>
{{< /rawhtml >}}

Now lets try to make one that will do the following: Move a circle from left to right in the span of 1 second. Wait for one second. Move the same circle from top to bottom in the span of 1 second.

{{< rawhtml >}}
<iframe src="https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Fscene_barebones2.js" style="width: 100%;border: none;max-width: 960px;aspect-ratio: 16/9;display: block;"></iframe>
{{< /rawhtml >}}

As you can see from the code, we are not winning nothing over p5 or motion canvas with this. Here is where our first abstraction enters the game. _DefaultScene_. It allows you to have some default things that eases you common tasks.

First of all it defaults to a canvas of 1920x1080 with white background. If you dont like it, you can override the _width, height, background_ properties in the constructor.

It also has some basic functions to handle animations timelines

- this.wait(ms): Waits for the amount of milliseconds updating the endTime acordingly
- this.play(\[frames\]): It will play all the frames in parallel at the current time and wait for all to finish
- this.play(frame): It will play the frame at the current time and wait for it to finish

A frame is nothing more than an object with the _at_ property that sets when the animation should start playing, and a _endTime_ property that returns when the animation finishes.

The scene also has the capability of adding custom _widgets_. They are nothing more that objects with a _update(t)_ and _draw(ctx)_ methods. Update will be called each time a new frame is requested with the wanted time. And draw will be called to draw it to the canvas.

Along this it also provides basic widgets implementations to create: [Circle](https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Fcircle.js), [Polygon](https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Fpolygon.js), [Rectangle](https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Frectangle.js), [Image](https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Fimage.js), [Text](https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Ftext.js)

All property from this objects allows you to call a _to_ method that will return a _frame_ object that plays nicely with the play method.

Or you could set them to an object that implements the following interface. If you have a single function you can call the [TimelineFunction](https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Fanimation_function.js)

- obj.update(t): Updates the property accordly to the given time.
- obj.value: Returns the last computed value

Now lets see again the animation from the beginning where i think it provides an example of all these things:

{{< rawhtml >}}
<iframe src="https://pudymody.github.io/experiment-animation-engine/editor.html?url=demo%2Fcircle_draw.js" style="width: 100%;border: none;max-width: 960px;aspect-ratio: 16/9;display: block;"></iframe>
{{< /rawhtml >}}

## TODO

There are a lot of things to do currently, here is just a few of them that i have in mind to do eventually. If i dont lose motivation again. This arent in priority order.

*   Better documentation, obviously. Currently the only way to discover things is navigating the code. Luckily it isnt obfuscated and its rather small.
*   Render math equations. Probably a smaller subset, something like typst or ascii math.
*   Render highlighted code.
*   Better demos.
*   Autocompletion for the provided engine/sdk. This will probably force me to use something like monaco instead of codemirror. But i want the dependency list to be as lean as possible.
*   Improve error messages and the ux in general.
*   Some kind of path object to draw svgs or animate things along a defined path.
