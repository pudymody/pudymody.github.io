---
title: "Fully responsive CSS only slide system"
date: 2022-10-14
issueId: 96
---

# Intro
This is something that i wanted to do for a long time, and finally with [css container queries](https://developer.chrome.com/blog/cq-polyfill/) i think its possible to do a fully responsive slide system with only css and no javascript. Or at least, not for displaying. I will use it to parse markdown to html.

In this post i will try to break some of the things that made this possible, and some tricks that i found along the road.

# Sliding
First of all, we need to make slides *slidable*. (its that even a word?). For this, i will use [CSS scroll snap](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Scroll_Snap) feature. I think of slides as a vertical carousel. Each slide will be a *&#60;section&#62;* tag which will be snapable. There are a lot of tutorials online about this, the ones i read are: [CSS-Only Carousel](https://css-tricks.com/css-only-carousel/) and [Building a Stories component](https://web.dev/building-a-stories-component/). Here im also using the [aspect-ratio](https://developer.mozilla.org/en-US/docs/Web/CSS/aspect-ratio) property to define its size.

```html
<main>
	<section>My slide 1</section>
	<section>My slide 2</section>
	<section>My slide 3</section>
	<section>My slide 4</section>
</main>
```

```css
main {
	width: 640px;
	aspect-ratio: 16/9;
	scroll-snap-type: y mandatory;
	overflow-y: auto;
}

section {
	scroll-snap-align: center;
	width: 100%;
	aspect-ratio: 16/9;
}
```

{{< rawhtml >}}
<style>
#demo1 {
	max-width: 100%;
	width: 640px;
	aspect-ratio: 16/9;
	overflow-y: auto;
	scroll-snap-type: y mandatory;
	border:1px solid;
	margin:0 auto;
}

#demo1 > section {
	scroll-snap-align: center;
	width: 100%;
	aspect-ratio: 16/9;
	background: #fff;
}

main[no-scrollbar]::-webkit-scrollbar {
	display: none;
}

main[no-scrollbar]{
	scrollbar-width: none;
}
</style>
<main id="demo1">
<section>My slide 1</section>
	<section>My slide 2</section>
	<section>My slide 3</section>
	<section>My slide 4</section>
</main>
{{< /rawhtml >}}

If your browser supports it, whenever you scroll in the demo above, you should advance per slide, and not be in between two.

I will also add the [overscroll-behavior](https://developer.mozilla.org/es/docs/Web/CSS/overscroll-behavior) property to trap scrolling and prevent the outer page from scrolling if im in the first or last slide. And the [scrollbar-gutter](https://developer.mozilla.org/en-US/docs/Web/CSS/scrollbar-gutter) one to reserve space for the scrollbar.
```css
main {
	/* ... */
	overscroll-behavior-y: contain;
	scrollbar-gutter: auto;
	/* ... */
}
```

# Removing scrollbar
Now for personal preference, i want to have the possibility to remove the scrollbar if i want. For this, i will use the [scrollbar-width](https://developer.mozilla.org/en-US/docs/Web/CSS/scrollbar-width) (only available in firefox) and the [::-webkit-scrollbar](https://developer.mozilla.org/en-US/docs/Web/CSS/::-webkit-scrollbar) pseudo-element whenever my *main* tag has the *no-scrollbar* attribute.

```css
main[no-scrollbar]::-webkit-scrollbar {
	display: none;
}

main[no-scrollbar]{
	scrollbar-width: none;
}
```

# Fluid Typography
Here comes the juicy part. I will follow [Easy Fluid Typography With clamp() Using Sass Functions](https://www.smashingmagazine.com/2022/10/fluid-typography-clamp-sass-functions/) with some changes to make it fully contained.

The problem with this solution, is that it depends on the *vw* unit, making it responsible around the viewport width, and not the element. Here is where container queries comes to the rescue. They allow us to use the *cqw* unit to reference the container width, and not the viewport.

Lets begin defining our element as a container element. We could use *container-type: inline-size*, but we need measurement in both direction for something that we will do in the future. I started this way, and lost too much time until i realized that if you use *inline-size* your height measurements are incorrect. Because we are using the *aspect-ratio* property, we wont have any problem that our element doesnt have a defined fixed size.
```css
main {
	container-type: size;
	container-name: slide-container;
	min-width: 320px;
}
```

Now, to the typography part. As there are a lot of moving parts, im using [css variables](https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties) (although they are called *custom properties*) to try to put some order and extensibility.
```css
main {
	/* Sizes are designed to be in a 1024px canvas */
	/* 1920px */
	--_max-scaler: 1.875;

	/* 320px */
	--_min-scaler: 0.3125;

	--h1-size: 72;
	--h1-size__min: calc( var(--h1-size) * var(--_min-scaler));
	--h1-size__max: calc( var(--h1-size) * var(--_max-scaler));
	/* 1200 = 1920px - 320px in pt */
	--h1-size__fluid-slope: calc( (var(--h1-size__max) - var(--h1-size__min)) / 1200 );
	/* 240 = 320px in pt */
	--h1-size__fluid-intercept: calc( var(--h1-size__min) - (var(--h1-size__fluid-slope) * 240));
	/* cqw to use container inline size, instead of viewport */
	--h1-size__fluid: calc( (var(--h1-size__fluid-slope) * 100 * 1cqw) + (var(--h1-size__fluid-intercept) * 1pt));
}
```

The slides will be designed in a 1024px width canvas size, and be displayed in a space from 320px to 1920px.

The *--_min-scaler* and *--_max-scaler* are the ratios needed to convert some value in a 1024 canvas to a 320 or 1920 one.

*--h1-size* is the size of a h1 tag in a 1024px canvas. Its expressed in *pt*, but we need to define it unitless because when we use [calc](https://developer.mozilla.org/en-US/docs/Web/CSS/calc), at least one of the members needs to be a number.

The *--h1-size__min* and *--h1-size__max* are the sizes of a h1 in a 320 or 1920 canvas (linearly interpolated).

The *--h1-size__fluid-slope*, *--h1-size__fluid-intercept* and *--h1-size__fluid* are the same thing as in the Smashing Magazine article. 1200 is the diference in viewports size expressed in pts. Same for 240. The *\* 1pt* is needed to convert the number to a length.

Because everything is a custom property, if we want to change the size of an h1 tag, we only need to update the property, and everything will react accordingly.

Now we do the same for h2, single text, and some padding values, and we have a fluid typography and spacing system that scales with the size of the element where its embedded.


# Free container size
With this, we already have a fully responsive slide system. But there is one more thing we could do, and i think its the cherry on the top. What if we allow the container to be whatever size it wants to be, and we scale the slides to fit inside it. Like [object-fit](https://developer.mozilla.org/en-US/docs/Web/CSS/object-fit) but for our html-elements-slides.

This is i think the most difficult part, at least for me. This is why im writing this post, to try to order my thoughts and findings about this part.

First of all, we need to change the structure of our slides. We need to wrap them inside a div and make the section fill all the available space. Also center its contents and remove its *aspect-ratio* property, as we are going to scale them ourselves.

```css
section {
	width: 100%;
	height: 100%;
	display: grid;
	place-items: center;
	/* aspect-ratio: 16/9; */
}
```

```html
<main>
	<section><div class="wrapper">My slide 1</div></section>
	<section><div class="wrapper">My slide 2</div></section>
	<section><div class="wrapper">My slide 3</div></section>
	<section><div class="wrapper">My slide 4</div></section>
</main>
```

For our wrapper class, we need the following, which im going to try to explain as best as i can.
```css
.wrapper {
	height: calc((var(--_is-height) * 100) + (var(--_is-width) * (9*100/16)));
	width: calc((var(--_is-width) * 100) + (var(--_is-height) * (16*100/9)));
}
```

First of all, *--_is-width* and *--_is-height* are defined as following in *main*
```css
main {
	--_is-height: clamp(0cqh,((100cqw * 9) - (100cqh * 16)) * 100,1cqh);
	--_is-width: clamp(0cqw,((100cqw * 9) - (100cqh * 16)) * -100,1cqw);
}
```

They all came from [this stackoverflow answer](https://stackoverflow.com/a/6565988) which explains how to fit an image inside a container with a different aspect ratio.

```
ratio_image = width_image / height_image
ratio_screen = width_screen / height_screen

if ( ratio_screen > ratio_image ){
	width_image = width_image * height_screen / height_image
} else {
	height_image = height_image * width_screen / width_image
}
```

First of all, we want to check that *ratio_screen > ratio_image*, which could be rewritten as following.
{{< rawhtml >}}
<svg xmlns:xlink="http://www.w3.org/1999/xlink" style="height: 3rem; margin: 0 auto;" viewBox="0 -1404.34 14374.556 2325.226"><g stroke="#000" stroke-width="0" transform="scale(1 -1)"><path stroke="none" d="M120 220h6374v60H120z"/><g transform="translate(324 676)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#a"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#b" x="721"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#c" x="1071"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#d" x="1599"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#e" x="1965"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#f" x="2546"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#g" x="3051"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#h" x="3525"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#i" x="3963"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#j" x="4419"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#j" x="4890"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#k" x="5361"/></g><g transform="translate(180 -686)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#e"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#j" x="581"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#b" x="1052"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#l" x="1402"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#e" x="1887"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#d" x="2468"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#f" x="2834"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#g" x="3339"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#h" x="3813"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#i" x="4251"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#j" x="4707"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#j" x="5178"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#k" x="5649"/></g><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#m" x="6891"/><g><path stroke="none" d="M8071 220h6182v60H8071z"/><g transform="translate(8275 680)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#a"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#b" x="721"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#c" x="1071"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#d" x="1599"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#e" x="1965"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#f" x="2546"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#b" x="3051"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#n" x="3401"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#o" x="4284"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#l" x="4818"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#j" x="5303"/></g><g transform="translate(8131 -686)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#e"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#j" x="581"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#b" x="1052"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#l" x="1402"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#e" x="1887"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#d" x="2468"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#f" x="2834"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#b" x="3339"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#n" x="3689"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#o" x="4572"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#l" x="5106"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#j" x="5591"/></g></g></g><defs><path id="b" stroke-width="10" d="M184 600q0 24 19 42t44 19q18 0 30-12t13-30q0-23-20-42t-44-20q-15 0-28 10t-14 33ZM21 287q0 8 9 31t24 51 44 51 60 22q39 0 65-23t27-62q0-17-14-56t-40-105-42-113q-5-22-5-32 0-25 17-25 9 0 19 3t23 14 27 35 25 59q3 12 5 14t17 2q20 0 20-10 0-8-9-31t-25-51-45-50-62-22q-32 0-59 21T74 74q0 17 5 32t43 114q38 101 44 121t7 39q0 24-17 24h-2q-30 0-55-33t-38-84q-1-1-2-3t-1-3-2-2-3-1-4 0-8 0H27q-6 6-6 9Z"/><path id="k" stroke-width="10" d="M21 287q1 6 3 16t12 38 20 47 33 37 46 17q36 0 60-18t30-34 6-21q0-2 1-2l11 11q61 64 139 64 54 0 87-27t34-79-38-157-38-127q0-26 17-26 6 0 9 1 29 5 52 38t35 80q2 8 20 8 20 0 20-8 0-1-4-15-8-29-22-57t-46-56-69-27q-47 0-68 27t-21 56q0 19 36 120t37 152q0 59-44 59h-5q-86 0-145-101l-7-12-33-134Q156 26 151 16q-13-27-43-27-13 0-21 6T76 7t-2 10q0 13 38 163t40 163q1 5 1 23 0 39-24 39-38 0-63-100-6-20-6-21-2-6-19-6H27q-6 6-6 9Z"/><path id="i" stroke-width="10" d="M21 287q1 3 2 8t5 22 10 31 15 33 20 30 26 22 33 9q29 0 51-12t31-22 11-20q2-6 3-6t8 7q48 52 111 52h3q48 0 72-41 8-19 8-37 0-30-13-48t-26-23-25-4q-20 0-32 11t-12 29q0 48 56 64-22 13-36 13-56 0-103-74-10-16-15-33t-34-133Q156 25 151 16q-13-27-43-27-13 0-21 6T76 7t-2 10q0 13 40 172t40 177q0 39-26 39-21 0-36-28t-24-61-11-36q-2-2-16-2H27q-6 6-6 9Z"/><path id="o" stroke-width="10" d="M33 157q0 101 76 192t171 92q51 0 90-49 16 30 46 30 13 0 23-8t10-20q0-13-37-160T374 68q0-25 7-33t21-9q9 1 20 9 21 20 41 96 6 20 10 21 2 1 10 1h4q19 0 19-9 0-6-5-27t-20-54-32-50Q436 0 417-8q-8-2-24-2-34 0-57 15t-30 31l-6 15q-1 1-4-1l-4-4q-59-56-120-56-55 0-97 40T33 157Zm318 171q0 6-5 22t-23 35-46 20q-35 0-67-31t-50-81q-29-79-41-164v-11q0-8-1-12 0-45 18-62t43-18q38 0 75 33t44 51q2 4 27 107t26 111Z"/><path id="d" stroke-width="10" d="M26 385q-7 7-7 10 0 4 3 16t5 14q2 5 9 5t51 1h53l19 80q3 11 7 29t7 26 6 20 8 17 10 12 14 9 18 2q18-1 25-11t7-19q0-7-9-47t-20-79l-10-37q0-2 50-2h51q7-7 7-11 0-22-13-35H210l-36-145Q135 80 135 68q0-42 27-42 35 0 68 34t53 84q2 6 5 7t15 2h4q15 0 15-8 0-3-3-12-5-16-18-38t-34-47-51-42-61-17q-30 0-57 15T59 56q-2 8-2 27v18l35 140q35 141 36 142 0 2-51 2H26Z"/><path id="g" stroke-width="10" d="M131 289q0 32 16 65t56 61 97 27q62 0 90-27t29-60q0-32-17-47t-38-16q-13 0-24 8t-12 26q0 16 9 28t17 18 13 6q1 0 1 1 0 3-7 9t-25 11-39 6q-48 0-70-26t-23-53q0-25 19-35t55-17 52-15q66-29 66-96 0-28-11-56t-33-56-63-44-94-17q-77 0-109 29T53 87q0 39 21 56t44 17q15 0 28-9t14-31q0-26-18-44t-31-18q-2-1-3-1t-1-2q1-3 8-8t31-13 55-7q36 0 62 11t38 28 17 31 5 25q0 28-21 42t-48 17-59 15-47 35q-17 25-17 58Z"/><path id="h" stroke-width="10" d="M34 159q0 109 86 196t186 87q56 0 88-24t33-63q0-29-19-49t-48-21q-19 0-30 10t-11 30 11 34 22 21 14 6h1q0 2-6 6t-21 8-34 4q-30 0-57-14-21-9-43-31-44-44-64-124t-21-116q0-46 26-69 22-24 58-24h4q112 0 185 85 9 10 12 10 4 0 13-9t10-14-9-15-29-28-45-30-64-25-80-11q-75 0-121 48T34 159Z"/><path id="j" stroke-width="10" d="M39 168q0 57 19 104t49 78 67 52 70 31 63 9h3q45 0 78-22t33-65q0-90-111-118-49-13-134-14-37 0-38-2 0-2-6-35t-7-58q0-47 21-74t63-28 93 19 92 66q9 10 12 10 4 0 13-9t10-14-9-16-30-27-46-31-63-25-76-10q-79 0-122 53T39 168Zm334 185q-6 52-68 52-33 0-61-14t-45-34-29-41-16-36-5-19q0-1 20-1 113 0 158 24t46 69Z"/><path id="m" stroke-width="10" d="M84 520q0 8 4 13t8 6l3 1q7 0 154-69t291-137l143-69q7-5 7-15t-7-15q-2-2-292-139L107-40h-6q-18 2-18 20v3q-1 7 15 16 19 10 150 72 78 37 130 61l248 118-248 118Q90 504 86 509q-2 4-2 11Z"/><path id="n" stroke-width="10" d="M21 287q1 6 3 16t12 38 20 47 32 37 44 17 43-7 30-18 16-22 8-19l2-7q0-2 1-2l11 11q60 64 141 64 17 0 31-2t26-7 19-10 15-12 10-13 8-13 4-12 3-9 2-7l8 10q63 75 149 75 54 0 87-27t34-79q0-51-38-158T704 50q1-14 5-19t15-5q28 0 52 30t39 82q3 11 6 13t16 2q20 0 20-8 0-1-4-15-8-29-22-57t-46-56-69-27q-47 0-68 27t-21 56q0 19 36 120t37 152q0 59-44 59h-5q-86 0-145-101l-7-12-33-134Q433 26 428 16q-13-27-43-27-13 0-21 7T353 8t-3 10q0 11 34 143l36 146q3 15 3 38 0 59-44 59h-5q-86 0-145-101l-7-12-33-134Q156 26 151 16q-13-27-43-27-13 0-21 6T76 7t-2 10q0 13 38 164 39 154 39 161 3 15 3 27 0 36-25 36-22 0-37-28t-23-61-12-36q-2-2-16-2H27q-6 6-6 9Z"/><path id="l" stroke-width="10" d="M311 43q-15-13-44-28T206 0q-63 0-101 45T66 160q0 105 77 193t171 89q47 0 87-48l3 4q2 3 5 6t9 8 13 7 16 3q14 0 23-9t10-19q0-15-57-242T363-80q-18-54-77-89t-135-36q-141 0-141 68 0 26 18 46t46 20q15 0 28-9t14-31q0-10-2-19t-7-14-8-10-7-8l-2-2h1q10-3 60-3 38 0 60 12 23 11 43 33t28 47q6 19 16 62 13 48 13 56Zm73 285-4 11q-3 11-5 15t-6 14-10 14-13 11-18 9-22 3q-44 0-85-53-30-39-50-119t-20-116q0-79 62-79 56 0 110 70l8 10 53 210Z"/><path id="a" stroke-width="10" d="M580 385q0 21 19 39t42 19q18 0 33-18t16-57q0-29-19-115-15-56-27-92t-35-81-55-68-72-23q-44 0-78 16t-49 43q-1-1-3-4-41-55-100-55-26 0-50 6t-47 19-37 39-14 63q0 54 34 146t35 117v14q0 3-4 7t-11 4h-4q-23 0-42-19t-30-41-17-42-8-22q-2-2-16-2H27q-6 6-6 9 0 6 8 28t23 51 44 52 65 23q43 0 66-25t23-58q0-18-33-108t-33-139q0-46 21-65t53-20q43 0 76 61l5 9v32q0 6 1 8t1 7 1 9 3 13 3 17 6 24 8 32 11 43q29 114 33 123 13 27 43 27 19 0 26-10t8-19q0-13-29-128t-32-132q-2-11-2-35v-7q0-15 3-29t19-29 45-16q71 0 113 122 9 23 20 65t12 60q0 33-13 52t-26 32-13 28Z"/><path id="c" stroke-width="10" d="M366 683q1 0 72 5t73 6q12 0 12-8 0-7-73-302T375 83t-1-15q0-42 28-42 9 1 20 9 21 20 41 96 6 20 10 21 2 1 10 1h8q15 0 15-8 0-5-3-16-13-50-30-81T445 8 417-8q-8-2-24-2-34 0-57 15t-30 31l-6 15q-1 1-4-1l-4-4q-59-56-120-56-55 0-97 40T33 157q0 48 20 98t48 86q47 57 94 79t85 22q56 0 84-42 5-6 5-4 1 4 27 109t28 111q0 13-7 16t-39 5h-21q-6 6-6 8t2 19q5 19 13 19Zm-14-357q-23 79-75 79-35 0-67-31t-50-81q-29-79-41-164v-11q0-8-1-12 0-45 18-62t43-18q54 0 111 72l8 11 54 217Z"/><path id="e" stroke-width="10" d="M137 683q1 0 72 5t73 6q12 0 12-9 0-11-36-151-38-148-38-151 0-2 7 5 61 54 130 54 54 0 87-27t34-79q0-51-38-158T402 50q1-14 5-19t15-5q28 0 52 30t39 82q3 11 6 13t16 2q20 0 20-8 0-1-4-15-16-59-51-97-34-43-81-43h-5q-47 0-68 27t-21 57q0 16 36 118t37 153q0 59-44 59h-5q-83 0-144-98l-7-13-34-135Q132 28 127 16q-13-27-44-27-14 0-24 9T48 16q0 14 73 304l74 296q0 13-7 16t-39 5h-21q-6 6-6 8t2 19q5 19 13 19Z"/><path id="f" stroke-width="10" d="M0-62v37h499v-37H0Z"/></defs></svg>
{{< /rawhtml >}}

And because everything is positive numbers, the following rewrite is valid. Also because we are working with ratios, we could use (16,9) as the image size.

{{< rawhtml >}}
<svg xmlns:xlink="http://www.w3.org/1999/xlink" style="height: 1rem; margin: 1rem auto;" viewBox="0 -723.936 27293.444 958.871"><g stroke="#000" stroke-width="0" transform="scale(1 -1)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_a"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_b" x="721"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_c" x="1071"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_d" x="1599"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_e" x="1965"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_f" x="2546"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_g" x="3051"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_h" x="3525"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_i" x="3963"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_j" x="4419"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_j" x="4890"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_k" x="5361"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_l" x="6188"/><g transform="translate(6915)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_e"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_j" x="581"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_b" x="1052"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_m" x="1402"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_e" x="1887"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_d" x="2468"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_f" x="2834"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_b" x="3339"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_n" x="3689"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_o" x="4572"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_m" x="5106"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_j" x="5591"/></g><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_p" x="13255"/><g transform="translate(14316)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_a"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_b" x="721"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_c" x="1071"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_d" x="1599"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_e" x="1965"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_f" x="2546"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_b" x="3051"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_n" x="3401"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_o" x="4284"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_m" x="4818"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_j" x="5303"/></g><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_l" x="20312"/><g transform="translate(21039)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_e"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_j" x="581"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_b" x="1052"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_m" x="1402"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_e" x="1887"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_d" x="2468"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_f" x="2834"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_g" x="3339"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_h" x="3813"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_i" x="4251"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_j" x="4707"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_j" x="5178"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#1_k" x="5649"/></g></g><defs><path id="1_b" stroke-width="10" d="M184 600q0 24 19 42t44 19q18 0 30-12t13-30q0-23-20-42t-44-20q-15 0-28 10t-14 33ZM21 287q0 8 9 31t24 51 44 51 60 22q39 0 65-23t27-62q0-17-14-56t-40-105-42-113q-5-22-5-32 0-25 17-25 9 0 19 3t23 14 27 35 25 59q3 12 5 14t17 2q20 0 20-10 0-8-9-31t-25-51-45-50-62-22q-32 0-59 21T74 74q0 17 5 32t43 114q38 101 44 121t7 39q0 24-17 24h-2q-30 0-55-33t-38-84q-1-1-2-3t-1-3-2-2-3-1-4 0-8 0H27q-6 6-6 9Z"/><path id="1_k" stroke-width="10" d="M21 287q1 6 3 16t12 38 20 47 33 37 46 17q36 0 60-18t30-34 6-21q0-2 1-2l11 11q61 64 139 64 54 0 87-27t34-79-38-157-38-127q0-26 17-26 6 0 9 1 29 5 52 38t35 80q2 8 20 8 20 0 20-8 0-1-4-15-8-29-22-57t-46-56-69-27q-47 0-68 27t-21 56q0 19 36 120t37 152q0 59-44 59h-5q-86 0-145-101l-7-12-33-134Q156 26 151 16q-13-27-43-27-13 0-21 6T76 7t-2 10q0 13 38 163t40 163q1 5 1 23 0 39-24 39-38 0-63-100-6-20-6-21-2-6-19-6H27q-6 6-6 9Z"/><path id="1_i" stroke-width="10" d="M21 287q1 3 2 8t5 22 10 31 15 33 20 30 26 22 33 9q29 0 51-12t31-22 11-20q2-6 3-6t8 7q48 52 111 52h3q48 0 72-41 8-19 8-37 0-30-13-48t-26-23-25-4q-20 0-32 11t-12 29q0 48 56 64-22 13-36 13-56 0-103-74-10-16-15-33t-34-133Q156 25 151 16q-13-27-43-27-13 0-21 6T76 7t-2 10q0 13 40 172t40 177q0 39-26 39-21 0-36-28t-24-61-11-36q-2-2-16-2H27q-6 6-6 9Z"/><path id="1_o" stroke-width="10" d="M33 157q0 101 76 192t171 92q51 0 90-49 16 30 46 30 13 0 23-8t10-20q0-13-37-160T374 68q0-25 7-33t21-9q9 1 20 9 21 20 41 96 6 20 10 21 2 1 10 1h4q19 0 19-9 0-6-5-27t-20-54-32-50Q436 0 417-8q-8-2-24-2-34 0-57 15t-30 31l-6 15q-1 1-4-1l-4-4q-59-56-120-56-55 0-97 40T33 157Zm318 171q0 6-5 22t-23 35-46 20q-35 0-67-31t-50-81q-29-79-41-164v-11q0-8-1-12 0-45 18-62t43-18q38 0 75 33t44 51q2 4 27 107t26 111Z"/><path id="1_d" stroke-width="10" d="M26 385q-7 7-7 10 0 4 3 16t5 14q2 5 9 5t51 1h53l19 80q3 11 7 29t7 26 6 20 8 17 10 12 14 9 18 2q18-1 25-11t7-19q0-7-9-47t-20-79l-10-37q0-2 50-2h51q7-7 7-11 0-22-13-35H210l-36-145Q135 80 135 68q0-42 27-42 35 0 68 34t53 84q2 6 5 7t15 2h4q15 0 15-8 0-3-3-12-5-16-18-38t-34-47-51-42-61-17q-30 0-57 15T59 56q-2 8-2 27v18l35 140q35 141 36 142 0 2-51 2H26Z"/><path id="1_g" stroke-width="10" d="M131 289q0 32 16 65t56 61 97 27q62 0 90-27t29-60q0-32-17-47t-38-16q-13 0-24 8t-12 26q0 16 9 28t17 18 13 6q1 0 1 1 0 3-7 9t-25 11-39 6q-48 0-70-26t-23-53q0-25 19-35t55-17 52-15q66-29 66-96 0-28-11-56t-33-56-63-44-94-17q-77 0-109 29T53 87q0 39 21 56t44 17q15 0 28-9t14-31q0-26-18-44t-31-18q-2-1-3-1t-1-2q1-3 8-8t31-13 55-7q36 0 62 11t38 28 17 31 5 25q0 28-21 42t-48 17-59 15-47 35q-17 25-17 58Z"/><path id="1_h" stroke-width="10" d="M34 159q0 109 86 196t186 87q56 0 88-24t33-63q0-29-19-49t-48-21q-19 0-30 10t-11 30 11 34 22 21 14 6h1q0 2-6 6t-21 8-34 4q-30 0-57-14-21-9-43-31-44-44-64-124t-21-116q0-46 26-69 22-24 58-24h4q112 0 185 85 9 10 12 10 4 0 13-9t10-14-9-15-29-28-45-30-64-25-80-11q-75 0-121 48T34 159Z"/><path id="1_j" stroke-width="10" d="M39 168q0 57 19 104t49 78 67 52 70 31 63 9h3q45 0 78-22t33-65q0-90-111-118-49-13-134-14-37 0-38-2 0-2-6-35t-7-58q0-47 21-74t63-28 93 19 92 66q9 10 12 10 4 0 13-9t10-14-9-16-30-27-46-31-63-25-76-10q-79 0-122 53T39 168Zm334 185q-6 52-68 52-33 0-61-14t-45-34-29-41-16-36-5-19q0-1 20-1 113 0 158 24t46 69Z"/><path id="1_p" stroke-width="10" d="M84 520q0 8 4 13t8 6l3 1q7 0 154-69t291-137l143-69q7-5 7-15t-7-15q-2-2-292-139L107-40h-6q-18 2-18 20v3q-1 7 15 16 19 10 150 72 78 37 130 61l248 118-248 118Q90 504 86 509q-2 4-2 11Z"/><path id="1_n" stroke-width="10" d="M21 287q1 6 3 16t12 38 20 47 32 37 44 17 43-7 30-18 16-22 8-19l2-7q0-2 1-2l11 11q60 64 141 64 17 0 31-2t26-7 19-10 15-12 10-13 8-13 4-12 3-9 2-7l8 10q63 75 149 75 54 0 87-27t34-79q0-51-38-158T704 50q1-14 5-19t15-5q28 0 52 30t39 82q3 11 6 13t16 2q20 0 20-8 0-1-4-15-8-29-22-57t-46-56-69-27q-47 0-68 27t-21 56q0 19 36 120t37 152q0 59-44 59h-5q-86 0-145-101l-7-12-33-134Q433 26 428 16q-13-27-43-27-13 0-21 7T353 8t-3 10q0 11 34 143l36 146q3 15 3 38 0 59-44 59h-5q-86 0-145-101l-7-12-33-134Q156 26 151 16q-13-27-43-27-13 0-21 6T76 7t-2 10q0 13 38 164 39 154 39 161 3 15 3 27 0 36-25 36-22 0-37-28t-23-61-12-36q-2-2-16-2H27q-6 6-6 9Z"/><path id="1_m" stroke-width="10" d="M311 43q-15-13-44-28T206 0q-63 0-101 45T66 160q0 105 77 193t171 89q47 0 87-48l3 4q2 3 5 6t9 8 13 7 16 3q14 0 23-9t10-19q0-15-57-242T363-80q-18-54-77-89t-135-36q-141 0-141 68 0 26 18 46t46 20q15 0 28-9t14-31q0-10-2-19t-7-14-8-10-7-8l-2-2h1q10-3 60-3 38 0 60 12 23 11 43 33t28 47q6 19 16 62 13 48 13 56Zm73 285-4 11q-3 11-5 15t-6 14-10 14-13 11-18 9-22 3q-44 0-85-53-30-39-50-119t-20-116q0-79 62-79 56 0 110 70l8 10 53 210Z"/><path id="1_a" stroke-width="10" d="M580 385q0 21 19 39t42 19q18 0 33-18t16-57q0-29-19-115-15-56-27-92t-35-81-55-68-72-23q-44 0-78 16t-49 43q-1-1-3-4-41-55-100-55-26 0-50 6t-47 19-37 39-14 63q0 54 34 146t35 117v14q0 3-4 7t-11 4h-4q-23 0-42-19t-30-41-17-42-8-22q-2-2-16-2H27q-6 6-6 9 0 6 8 28t23 51 44 52 65 23q43 0 66-25t23-58q0-18-33-108t-33-139q0-46 21-65t53-20q43 0 76 61l5 9v32q0 6 1 8t1 7 1 9 3 13 3 17 6 24 8 32 11 43q29 114 33 123 13 27 43 27 19 0 26-10t8-19q0-13-29-128t-32-132q-2-11-2-35v-7q0-15 3-29t19-29 45-16q71 0 113 122 9 23 20 65t12 60q0 33-13 52t-26 32-13 28Z"/><path id="1_c" stroke-width="10" d="M366 683q1 0 72 5t73 6q12 0 12-8 0-7-73-302T375 83t-1-15q0-42 28-42 9 1 20 9 21 20 41 96 6 20 10 21 2 1 10 1h8q15 0 15-8 0-5-3-16-13-50-30-81T445 8 417-8q-8-2-24-2-34 0-57 15t-30 31l-6 15q-1 1-4-1l-4-4q-59-56-120-56-55 0-97 40T33 157q0 48 20 98t48 86q47 57 94 79t85 22q56 0 84-42 5-6 5-4 1 4 27 109t28 111q0 13-7 16t-39 5h-21q-6 6-6 8t2 19q5 19 13 19Zm-14-357q-23 79-75 79-35 0-67-31t-50-81q-29-79-41-164v-11q0-8-1-12 0-45 18-62t43-18q54 0 111 72l8 11 54 217Z"/><path id="1_e" stroke-width="10" d="M137 683q1 0 72 5t73 6q12 0 12-9 0-11-36-151-38-148-38-151 0-2 7 5 61 54 130 54 54 0 87-27t34-79q0-51-38-158T402 50q1-14 5-19t15-5q28 0 52 30t39 82q3 11 6 13t16 2q20 0 20-8 0-1-4-15-16-59-51-97-34-43-81-43h-5q-47 0-68 27t-21 57q0 16 36 118t37 153q0 59-44 59h-5q-83 0-144-98l-7-13-34-135Q132 28 127 16q-13-27-44-27-14 0-24 9T48 16q0 14 73 304l74 296q0 13-7 16t-39 5h-21q-6 6-6 8t2 19q5 19 13 19Z"/><path id="1_f" stroke-width="10" d="M0-62v37h499v-37H0Z"/><path id="1_l" stroke-width="10" d="M229 286q-13 134-13 150 0 18 24 28h5q4 0 6 1 12-1 22-9t10-20q0-17-6-80t-7-70l58 42q56 41 61 44t10 3q13 0 24-10t12-27q0-13-10-23-5-3-68-33t-68-32l66-31 70-35q9-9 9-23 0-15-9-25t-24-11q-8 0-18 6t-55 40l-58 42q13-134 13-150 0-10-7-19t-26-9q-19 0-26 9t-8 19q0 17 6 80t7 70l-58-42q-56-41-61-44-4-3-10-3-13 0-24 10t-12 27v8q0 3 3 6t5 6 9 7 13 7 19 9 25 11 32 15 40 20L74 315q-9 9-9 23 0 15 9 25t24 11q8 0 18-6t55-40l58-42Z"/></defs></svg>
{{< /rawhtml >}}

{{< rawhtml >}}
<svg xmlns:xlink="http://www.w3.org/1999/xlink" style="height: 1.1rem; margin: 1rem auto;"  viewBox="0 -723.936 16972.444 958.871"><g stroke="#2_000" stroke-width="0" transform="scale(1 -1)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_a"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_b" x="721"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_c" x="1071"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_d" x="1599"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_e" x="1965"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_f" x="2546"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_g" x="3051"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_h" x="3525"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_i" x="3963"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_j" x="4419"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_j" x="4890"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_k" x="5361"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_l" x="6188"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_m" x="6915"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_n" x="7698"/><g transform="translate(8759)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_o"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_p" x="505"/></g><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_l" x="9991"/><g transform="translate(10718)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_e"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_j" x="581"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_b" x="1052"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_q" x="1402"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_e" x="1887"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_d" x="2468"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_f" x="2834"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_g" x="3339"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_h" x="3813"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_i" x="4251"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_j" x="4707"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_j" x="5178"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#2_k" x="5649"/></g></g><defs><path id="2_b" stroke-width="10" d="M184 600q0 24 19 42t44 19q18 0 30-12t13-30q0-23-20-42t-44-20q-15 0-28 10t-14 33ZM21 287q0 8 9 31t24 51 44 51 60 22q39 0 65-23t27-62q0-17-14-56t-40-105-42-113q-5-22-5-32 0-25 17-25 9 0 19 3t23 14 27 35 25 59q3 12 5 14t17 2q20 0 20-10 0-8-9-31t-25-51-45-50-62-22q-32 0-59 21T74 74q0 17 5 32t43 114q38 101 44 121t7 39q0 24-17 24h-2q-30 0-55-33t-38-84q-1-1-2-3t-1-3-2-2-3-1-4 0-8 0H27q-6 6-6 9Z"/><path id="2_k" stroke-width="10" d="M21 287q1 6 3 16t12 38 20 47 33 37 46 17q36 0 60-18t30-34 6-21q0-2 1-2l11 11q61 64 139 64 54 0 87-27t34-79-38-157-38-127q0-26 17-26 6 0 9 1 29 5 52 38t35 80q2 8 20 8 20 0 20-8 0-1-4-15-8-29-22-57t-46-56-69-27q-47 0-68 27t-21 56q0 19 36 120t37 152q0 59-44 59h-5q-86 0-145-101l-7-12-33-134Q156 26 151 16q-13-27-43-27-13 0-21 6T76 7t-2 10q0 13 38 163t40 163q1 5 1 23 0 39-24 39-38 0-63-100-6-20-6-21-2-6-19-6H27q-6 6-6 9Z"/><path id="2_o" stroke-width="10" d="m213 578-13-5q-14-5-40-10t-58-7H83v46h19q47 2 87 15t56 24 28 22q2 3 12 3 9 0 17-6V361l1-300q7-7 12-9t24-4 62-2h26V0h-11q-21 3-159 3-136 0-157-3H88v46h64q16 0 25 1t16 3 8 2 6 5 6 4v517Z"/><path id="2_i" stroke-width="10" d="M21 287q1 3 2 8t5 22 10 31 15 33 20 30 26 22 33 9q29 0 51-12t31-22 11-20q2-6 3-6t8 7q48 52 111 52h3q48 0 72-41 8-19 8-37 0-30-13-48t-26-23-25-4q-20 0-32 11t-12 29q0 48 56 64-22 13-36 13-56 0-103-74-10-16-15-33t-34-133Q156 25 151 16q-13-27-43-27-13 0-21 6T76 7t-2 10q0 13 40 172t40 177q0 39-26 39-21 0-36-28t-24-61-11-36q-2-2-16-2H27q-6 6-6 9Z"/><path id="2_d" stroke-width="10" d="M26 385q-7 7-7 10 0 4 3 16t5 14q2 5 9 5t51 1h53l19 80q3 11 7 29t7 26 6 20 8 17 10 12 14 9 18 2q18-1 25-11t7-19q0-7-9-47t-20-79l-10-37q0-2 50-2h51q7-7 7-11 0-22-13-35H210l-36-145Q135 80 135 68q0-42 27-42 35 0 68 34t53 84q2 6 5 7t15 2h4q15 0 15-8 0-3-3-12-5-16-18-38t-34-47-51-42-61-17q-30 0-57 15T59 56q-2 8-2 27v18l35 140q35 141 36 142 0 2-51 2H26Z"/><path id="2_g" stroke-width="10" d="M131 289q0 32 16 65t56 61 97 27q62 0 90-27t29-60q0-32-17-47t-38-16q-13 0-24 8t-12 26q0 16 9 28t17 18 13 6q1 0 1 1 0 3-7 9t-25 11-39 6q-48 0-70-26t-23-53q0-25 19-35t55-17 52-15q66-29 66-96 0-28-11-56t-33-56-63-44-94-17q-77 0-109 29T53 87q0 39 21 56t44 17q15 0 28-9t14-31q0-26-18-44t-31-18q-2-1-3-1t-1-2q1-3 8-8t31-13 55-7q36 0 62 11t38 28 17 31 5 25q0 28-21 42t-48 17-59 15-47 35q-17 25-17 58Z"/><path id="2_h" stroke-width="10" d="M34 159q0 109 86 196t186 87q56 0 88-24t33-63q0-29-19-49t-48-21q-19 0-30 10t-11 30 11 34 22 21 14 6h1q0 2-6 6t-21 8-34 4q-30 0-57-14-21-9-43-31-44-44-64-124t-21-116q0-46 26-69 22-24 58-24h4q112 0 185 85 9 10 12 10 4 0 13-9t10-14-9-15-29-28-45-30-64-25-80-11q-75 0-121 48T34 159Z"/><path id="2_j" stroke-width="10" d="M39 168q0 57 19 104t49 78 67 52 70 31 63 9h3q45 0 78-22t33-65q0-90-111-118-49-13-134-14-37 0-38-2 0-2-6-35t-7-58q0-47 21-74t63-28 93 19 92 66q9 10 12 10 4 0 13-9t10-14-9-16-30-27-46-31-63-25-76-10q-79 0-122 53T39 168Zm334 185q-6 52-68 52-33 0-61-14t-45-34-29-41-16-36-5-19q0-1 20-1 113 0 158 24t46 69Z"/><path id="2_n" stroke-width="10" d="M84 520q0 8 4 13t8 6l3 1q7 0 154-69t291-137l143-69q7-5 7-15t-7-15q-2-2-292-139L107-40h-6q-18 2-18 20v3q-1 7 15 16 19 10 150 72 78 37 130 61l248 118-248 118Q90 504 86 509q-2 4-2 11Z"/><path id="2_q" stroke-width="10" d="M311 43q-15-13-44-28T206 0q-63 0-101 45T66 160q0 105 77 193t171 89q47 0 87-48l3 4q2 3 5 6t9 8 13 7 16 3q14 0 23-9t10-19q0-15-57-242T363-80q-18-54-77-89t-135-36q-141 0-141 68 0 26 18 46t46 20q15 0 28-9t14-31q0-10-2-19t-7-14-8-10-7-8l-2-2h1q10-3 60-3 38 0 60 12 23 11 43 33t28 47q6 19 16 62 13 48 13 56Zm73 285-4 11q-3 11-5 15t-6 14-10 14-13 11-18 9-22 3q-44 0-85-53-30-39-50-119t-20-116q0-79 62-79 56 0 110 70l8 10 53 210Z"/><path id="2_a" stroke-width="10" d="M580 385q0 21 19 39t42 19q18 0 33-18t16-57q0-29-19-115-15-56-27-92t-35-81-55-68-72-23q-44 0-78 16t-49 43q-1-1-3-4-41-55-100-55-26 0-50 6t-47 19-37 39-14 63q0 54 34 146t35 117v14q0 3-4 7t-11 4h-4q-23 0-42-19t-30-41-17-42-8-22q-2-2-16-2H27q-6 6-6 9 0 6 8 28t23 51 44 52 65 23q43 0 66-25t23-58q0-18-33-108t-33-139q0-46 21-65t53-20q43 0 76 61l5 9v32q0 6 1 8t1 7 1 9 3 13 3 17 6 24 8 32 11 43q29 114 33 123 13 27 43 27 19 0 26-10t8-19q0-13-29-128t-32-132q-2-11-2-35v-7q0-15 3-29t19-29 45-16q71 0 113 122 9 23 20 65t12 60q0 33-13 52t-26 32-13 28Z"/><path id="2_c" stroke-width="10" d="M366 683q1 0 72 5t73 6q12 0 12-8 0-7-73-302T375 83t-1-15q0-42 28-42 9 1 20 9 21 20 41 96 6 20 10 21 2 1 10 1h8q15 0 15-8 0-5-3-16-13-50-30-81T445 8 417-8q-8-2-24-2-34 0-57 15t-30 31l-6 15q-1 1-4-1l-4-4q-59-56-120-56-55 0-97 40T33 157q0 48 20 98t48 86q47 57 94 79t85 22q56 0 84-42 5-6 5-4 1 4 27 109t28 111q0 13-7 16t-39 5h-21q-6 6-6 8t2 19q5 19 13 19Zm-14-357q-23 79-75 79-35 0-67-31t-50-81q-29-79-41-164v-11q0-8-1-12 0-45 18-62t43-18q54 0 111 72l8 11 54 217Z"/><path id="2_e" stroke-width="10" d="M137 683q1 0 72 5t73 6q12 0 12-9 0-11-36-151-38-148-38-151 0-2 7 5 61 54 130 54 54 0 87-27t34-79q0-51-38-158T402 50q1-14 5-19t15-5q28 0 52 30t39 82q3 11 6 13t16 2q20 0 20-8 0-1-4-15-16-59-51-97-34-43-81-43h-5q-47 0-68 27t-21 57q0 16 36 118t37 153q0 59-44 59h-5q-83 0-144-98l-7-13-34-135Q132 28 127 16q-13-27-44-27-14 0-24 9T48 16q0 14 73 304l74 296q0 13-7 16t-39 5h-21q-6 6-6 8t2 19q5 19 13 19Z"/><path id="2_f" stroke-width="10" d="M0-62v37h499v-37H0Z"/><path id="2_l" stroke-width="10" d="M229 286q-13 134-13 150 0 18 24 28h5q4 0 6 1 12-1 22-9t10-20q0-17-6-80t-7-70l58 42q56 41 61 44t10 3q13 0 24-10t12-27q0-13-10-23-5-3-68-33t-68-32l66-31 70-35q9-9 9-23 0-15-9-25t-24-11q-8 0-18 6t-55 40l-58 42q13-134 13-150 0-10-7-19t-26-9q-19 0-26 9t-8 19q0 17 6 80t7 70l-58-42q-56-41-61-44-4-3-10-3-13 0-24 10t-12 27v8q0 3 3 6t5 6 9 7 13 7 19 9 25 11 32 15 40 20L74 315q-9 9-9 23 0 15 9 25t24 11q8 0 18-6t55-40l58-42Z"/><path id="2_p" stroke-width="10" d="M42 313q0 163 81 258t180 95q69 0 99-36t30-80q0-25-14-40t-39-15q-23 0-38 14t-15 39q0 44 47 53-22 22-62 25-71 0-117-60-47-66-47-202l1-4q5 6 8 13 41 60 107 60h4q46 0 81-19 24-14 48-40t39-57q21-49 21-107v-18q0-23-5-43-11-59-64-115T253-22q-28 0-54 8t-56 30-51 59-36 97-14 141Zm215 84q-30 0-52-17t-34-45-17-57-6-62q0-83 12-119t38-58q24-18 53-18 51 0 78 38 13 18 18 45t5 105q0 80-5 107t-18 45q-27 36-72 36Z"/><path id="2_m" stroke-width="10" d="M352 287q-48-76-120-76-78 0-128 59T44 396q-2 16-2 40v8q0 93 69 162 60 60 132 60h6q4 0 8-1h4q12 0 25-2t37-12 47-32 43-59q43-88 43-226 0-140-60-237-35-56-84-87T208-22q-61 0-100 29T68 93t53 56q22 0 37-14t15-39q0-18-9-31t-16-16-13-5l-4-1q0-2 7-6t26-10 42-5h6q60 0 101 64 39 56 39 194v7Zm-108-39q48 0 77 49t30 133q0 78-8 112-2 10-6 20t-14 26-30 27-47 10q-38 0-65-27-21-22-27-52t-7-105q0-83 5-112t20-47q25-34 72-34Z"/></defs></svg>
{{< /rawhtml >}}

Unluckily css doesnt have comparision functions yet. But we can still rewrite this expresion in the following way.
{{< rawhtml >}}
<svg xmlns:xlink="http://www.w3.org/1999/xlink" style="height: 1.1rem; margin: 1rem auto;" viewBox="0 -723.936 18704.889 958.871"><g stroke="#000" stroke-width="0" transform="scale(1 -1)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_a"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_b" x="721"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_c" x="1071"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_d" x="1599"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_e" x="1965"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_f" x="2546"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_g" x="3051"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_h" x="3525"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_i" x="3963"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_j" x="4419"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_j" x="4890"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_k" x="5361"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_l" x="6188"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_m" x="6915"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_n" x="7642"/><g transform="translate(8647)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_o"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_p" x="505"/></g><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_l" x="9880"/><g transform="translate(10607)"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_e"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_j" x="581"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_b" x="1052"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_q" x="1402"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_e" x="1887"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_d" x="2468"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_f" x="2834"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_g" x="3339"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_h" x="3813"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_i" x="4251"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_j" x="4707"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_j" x="5178"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_k" x="5649"/></g><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_r" x="17139"/><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#3_s" x="18199"/></g><defs><path id="3_b" stroke-width="10" d="M184 600q0 24 19 42t44 19q18 0 30-12t13-30q0-23-20-42t-44-20q-15 0-28 10t-14 33ZM21 287q0 8 9 31t24 51 44 51 60 22q39 0 65-23t27-62q0-17-14-56t-40-105-42-113q-5-22-5-32 0-25 17-25 9 0 19 3t23 14 27 35 25 59q3 12 5 14t17 2q20 0 20-10 0-8-9-31t-25-51-45-50-62-22q-32 0-59 21T74 74q0 17 5 32t43 114q38 101 44 121t7 39q0 24-17 24h-2q-30 0-55-33t-38-84q-1-1-2-3t-1-3-2-2-3-1-4 0-8 0H27q-6 6-6 9Z"/><path id="3_s" stroke-width="10" d="M96 585q56 81 153 81 48 0 96-26t78-92q37-83 37-228 0-155-43-237-20-42-55-67t-61-31-51-7q-26 0-52 6t-61 32-55 67q-43 82-43 237 0 174 57 265Zm225 12q-30 32-71 32-42 0-72-32-25-26-33-72t-8-192q0-158 8-208t36-79q28-30 69-30 40 0 68 30 29 30 36 84t8 203q0 145-8 191t-33 73Z"/><path id="3_k" stroke-width="10" d="M21 287q1 6 3 16t12 38 20 47 33 37 46 17q36 0 60-18t30-34 6-21q0-2 1-2l11 11q61 64 139 64 54 0 87-27t34-79-38-157-38-127q0-26 17-26 6 0 9 1 29 5 52 38t35 80q2 8 20 8 20 0 20-8 0-1-4-15-8-29-22-57t-46-56-69-27q-47 0-68 27t-21 56q0 19 36 120t37 152q0 59-44 59h-5q-86 0-145-101l-7-12-33-134Q156 26 151 16q-13-27-43-27-13 0-21 6T76 7t-2 10q0 13 38 163t40 163q1 5 1 23 0 39-24 39-38 0-63-100-6-20-6-21-2-6-19-6H27q-6 6-6 9Z"/><path id="3_o" stroke-width="10" d="m213 578-13-5q-14-5-40-10t-58-7H83v46h19q47 2 87 15t56 24 28 22q2 3 12 3 9 0 17-6V361l1-300q7-7 12-9t24-4 62-2h26V0h-11q-21 3-159 3-136 0-157-3H88v46h64q16 0 25 1t16 3 8 2 6 5 6 4v517Z"/><path id="3_i" stroke-width="10" d="M21 287q1 3 2 8t5 22 10 31 15 33 20 30 26 22 33 9q29 0 51-12t31-22 11-20q2-6 3-6t8 7q48 52 111 52h3q48 0 72-41 8-19 8-37 0-30-13-48t-26-23-25-4q-20 0-32 11t-12 29q0 48 56 64-22 13-36 13-56 0-103-74-10-16-15-33t-34-133Q156 25 151 16q-13-27-43-27-13 0-21 6T76 7t-2 10q0 13 40 172t40 177q0 39-26 39-21 0-36-28t-24-61-11-36q-2-2-16-2H27q-6 6-6 9Z"/><path id="3_d" stroke-width="10" d="M26 385q-7 7-7 10 0 4 3 16t5 14q2 5 9 5t51 1h53l19 80q3 11 7 29t7 26 6 20 8 17 10 12 14 9 18 2q18-1 25-11t7-19q0-7-9-47t-20-79l-10-37q0-2 50-2h51q7-7 7-11 0-22-13-35H210l-36-145Q135 80 135 68q0-42 27-42 35 0 68 34t53 84q2 6 5 7t15 2h4q15 0 15-8 0-3-3-12-5-16-18-38t-34-47-51-42-61-17q-30 0-57 15T59 56q-2 8-2 27v18l35 140q35 141 36 142 0 2-51 2H26Z"/><path id="3_g" stroke-width="10" d="M131 289q0 32 16 65t56 61 97 27q62 0 90-27t29-60q0-32-17-47t-38-16q-13 0-24 8t-12 26q0 16 9 28t17 18 13 6q1 0 1 1 0 3-7 9t-25 11-39 6q-48 0-70-26t-23-53q0-25 19-35t55-17 52-15q66-29 66-96 0-28-11-56t-33-56-63-44-94-17q-77 0-109 29T53 87q0 39 21 56t44 17q15 0 28-9t14-31q0-26-18-44t-31-18q-2-1-3-1t-1-2q1-3 8-8t31-13 55-7q36 0 62 11t38 28 17 31 5 25q0 28-21 42t-48 17-59 15-47 35q-17 25-17 58Z"/><path id="3_h" stroke-width="10" d="M34 159q0 109 86 196t186 87q56 0 88-24t33-63q0-29-19-49t-48-21q-19 0-30 10t-11 30 11 34 22 21 14 6h1q0 2-6 6t-21 8-34 4q-30 0-57-14-21-9-43-31-44-44-64-124t-21-116q0-46 26-69 22-24 58-24h4q112 0 185 85 9 10 12 10 4 0 13-9t10-14-9-15-29-28-45-30-64-25-80-11q-75 0-121 48T34 159Z"/><path id="3_j" stroke-width="10" d="M39 168q0 57 19 104t49 78 67 52 70 31 63 9h3q45 0 78-22t33-65q0-90-111-118-49-13-134-14-37 0-38-2 0-2-6-35t-7-58q0-47 21-74t63-28 93 19 92 66q9 10 12 10 4 0 13-9t10-14-9-16-30-27-46-31-63-25-76-10q-79 0-122 53T39 168Zm334 185q-6 52-68 52-33 0-61-14t-45-34-29-41-16-36-5-19q0-1 20-1 113 0 158 24t46 69Z"/><path id="3_r" stroke-width="10" d="M84 520q0 8 4 13t8 6l3 1q7 0 154-69t291-137l143-69q7-5 7-15t-7-15q-2-2-292-139L107-40h-6q-18 2-18 20v3q-1 7 15 16 19 10 150 72 78 37 130 61l248 118-248 118Q90 504 86 509q-2 4-2 11Z"/><path id="3_q" stroke-width="10" d="M311 43q-15-13-44-28T206 0q-63 0-101 45T66 160q0 105 77 193t171 89q47 0 87-48l3 4q2 3 5 6t9 8 13 7 16 3q14 0 23-9t10-19q0-15-57-242T363-80q-18-54-77-89t-135-36q-141 0-141 68 0 26 18 46t46 20q15 0 28-9t14-31q0-10-2-19t-7-14-8-10-7-8l-2-2h1q10-3 60-3 38 0 60 12 23 11 43 33t28 47q6 19 16 62 13 48 13 56Zm73 285-4 11q-3 11-5 15t-6 14-10 14-13 11-18 9-22 3q-44 0-85-53-30-39-50-119t-20-116q0-79 62-79 56 0 110 70l8 10 53 210Z"/><path id="3_a" stroke-width="10" d="M580 385q0 21 19 39t42 19q18 0 33-18t16-57q0-29-19-115-15-56-27-92t-35-81-55-68-72-23q-44 0-78 16t-49 43q-1-1-3-4-41-55-100-55-26 0-50 6t-47 19-37 39-14 63q0 54 34 146t35 117v14q0 3-4 7t-11 4h-4q-23 0-42-19t-30-41-17-42-8-22q-2-2-16-2H27q-6 6-6 9 0 6 8 28t23 51 44 52 65 23q43 0 66-25t23-58q0-18-33-108t-33-139q0-46 21-65t53-20q43 0 76 61l5 9v32q0 6 1 8t1 7 1 9 3 13 3 17 6 24 8 32 11 43q29 114 33 123 13 27 43 27 19 0 26-10t8-19q0-13-29-128t-32-132q-2-11-2-35v-7q0-15 3-29t19-29 45-16q71 0 113 122 9 23 20 65t12 60q0 33-13 52t-26 32-13 28Z"/><path id="3_c" stroke-width="10" d="M366 683q1 0 72 5t73 6q12 0 12-8 0-7-73-302T375 83t-1-15q0-42 28-42 9 1 20 9 21 20 41 96 6 20 10 21 2 1 10 1h8q15 0 15-8 0-5-3-16-13-50-30-81T445 8 417-8q-8-2-24-2-34 0-57 15t-30 31l-6 15q-1 1-4-1l-4-4q-59-56-120-56-55 0-97 40T33 157q0 48 20 98t48 86q47 57 94 79t85 22q56 0 84-42 5-6 5-4 1 4 27 109t28 111q0 13-7 16t-39 5h-21q-6 6-6 8t2 19q5 19 13 19Zm-14-357q-23 79-75 79-35 0-67-31t-50-81q-29-79-41-164v-11q0-8-1-12 0-45 18-62t43-18q54 0 111 72l8 11 54 217Z"/><path id="3_e" stroke-width="10" d="M137 683q1 0 72 5t73 6q12 0 12-9 0-11-36-151-38-148-38-151 0-2 7 5 61 54 130 54 54 0 87-27t34-79q0-51-38-158T402 50q1-14 5-19t15-5q28 0 52 30t39 82q3 11 6 13t16 2q20 0 20-8 0-1-4-15-16-59-51-97-34-43-81-43h-5q-47 0-68 27t-21 57q0 16 36 118t37 153q0 59-44 59h-5q-83 0-144-98l-7-13-34-135Q132 28 127 16q-13-27-44-27-14 0-24 9T48 16q0 14 73 304l74 296q0 13-7 16t-39 5h-21q-6 6-6 8t2 19q5 19 13 19Z"/><path id="3_f" stroke-width="10" d="M0-62v37h499v-37H0Z"/><path id="3_l" stroke-width="10" d="M229 286q-13 134-13 150 0 18 24 28h5q4 0 6 1 12-1 22-9t10-20q0-17-6-80t-7-70l58 42q56 41 61 44t10 3q13 0 24-10t12-27q0-13-10-23-5-3-68-33t-68-32l66-31 70-35q9-9 9-23 0-15-9-25t-24-11q-8 0-18 6t-55 40l-58 42q13-134 13-150 0-10-7-19t-26-9q-19 0-26 9t-8 19q0 17 6 80t7 70l-58-42q-56-41-61-44-4-3-10-3-13 0-24 10t-12 27v8q0 3 3 6t5 6 9 7 13 7 19 9 25 11 32 15 40 20L74 315q-9 9-9 23 0 15 9 25t24 11q8 0 18-6t55-40l58-42Z"/><path id="3_p" stroke-width="10" d="M42 313q0 163 81 258t180 95q69 0 99-36t30-80q0-25-14-40t-39-15q-23 0-38 14t-15 39q0 44 47 53-22 22-62 25-71 0-117-60-47-66-47-202l1-4q5 6 8 13 41 60 107 60h4q46 0 81-19 24-14 48-40t39-57q21-49 21-107v-18q0-23-5-43-11-59-64-115T253-22q-28 0-54 8t-56 30-51 59-36 97-14 141Zm215 84q-30 0-52-17t-34-45-17-57-6-62q0-83 12-119t38-58q24-18 53-18 51 0 78 38 13 18 18 45t5 105q0 80-5 107t-18 45q-27 36-72 36Z"/><path id="3_m" stroke-width="10" d="M352 287q-48-76-120-76-78 0-128 59T44 396q-2 16-2 40v8q0 93 69 162 60 60 132 60h6q4 0 8-1h4q12 0 25-2t37-12 47-32 43-59q43-88 43-226 0-140-60-237-35-56-84-87T208-22q-61 0-100 29T68 93t53 56q22 0 37-14t15-39q0-18-9-31t-16-16-13-5l-4-1q0-2 7-6t26-10 42-5h6q60 0 101 64 39 56 39 194v7Zm-108-39q48 0 77 49t30 133q0 78-8 112-2 10-6 20t-14 26-30 27-47 10q-38 0-65-27-21-22-27-52t-7-105q0-83 5-112t20-47q25-34 72-34Z"/><path id="3_n" stroke-width="10" d="M84 237v13l14 20h581q15-8 15-20t-15-20H98q-14 7-14 20Z"/></defs></svg>
{{< /rawhtml >}}

If *width_screen\*9* is greater than *16\*height_screen* this will be positive number, and we want to have some kind of *true* value. If not, we want a *false* value. The default number values for true and false in the programming world are 1 and 0. So this seems to be a work for clamp. If its a positive number, we want the property to be *1cqh*, and if not, we want it to be *0cqh*.

But our value could be a number between 0 and 1, and we want it to be a 1 in that case, and clamp wont make it. Thats why we multiply it by 100. I think two decimal places of accuracy is ok for this. If not, one can always add more zeros.

I called it *\--_is-height* because i wanted to reflect that if its true, we want the slide to have 100% of the container height.

For *\--_is-width* is exactly the same thought. We only multiply it by -100, to express the inequality in the other way.

**Its very important to notice that this properties have units in them, and are not unitless**

Now that we can check if its greater or not, the only thing left to do, is change our width and height. I will explain only one, as the other is the same.

If *\--_is-height* is 1cqh, we need to use 100% of the container's height for the slides and calculate the width ourselves. Multiplying it by 100, we would have 100cqh which is 100% of the container's height.

If its 0cqh, that means we need to calculate the height to keep the aspect ratio. The previous part will be 0 (0cqh*100), so we could add the new height to this.

As we saw in the pseudocode, its value should be *height_image * width_screen / width_image*. We already have height_image and width_image (16,9) as explained before. So our final calculation its *9 * width_screen / 16*. But width_screen could be obtained by multiplying *--_is-width\*100* because if *\--_is-height* its 0, *\--_is-width* should be 1cqw.

And with this, we finally have a fully responsive slide system respecting its parent size. Its important that we dont remove the *aspect-ratio* property from the main. Because if it doesnt have a width or height, it could be calculate from there.

# Updating typography
The last thing we need to do, is update our fluid typography. Because we were using the container's width as unit, it will not longer work, because now, we need to use our "slide width", wich could be smaller. But this is easy to solve. We define another custom property with the value of the slide's width, and use that one, instead of the 1cqw of before. We also need to remove the *\*100* because our new custom property is already multiplied

```css
main {
	--slide_width: calc((var(--_is-width) * 100) + (var(--_is-height) * (16*100/9)));
	--h1-size__fluid: calc( (var(--h1-size__fluid-slope) * var(--slide_width)) + (var(--h1-size__fluid-intercept) * 1pt));
}


```

# Outro
We saw that the current state of css features its **SO** powerful. Using container queries, css scroll snap, aspect-ratio and math functions, all new and shiny things, we built something that in the past would require javascript. Althought the version i uploaded to [github](https://pudymody.github.io/slidy/) uses javascript, its only needed for parsing the markdown and having a custom element. I believe that using something like [enhance](https://enhance.dev/) you could remove all js completly.

If you want you could read the [source code](https://github.com/pudymody/slidy)

Currently this only works in Chrome and i believe Safari. But it shouldnt be long untill my browser of choice, Firefox catches up.
