---
title: Recreating Tinder swipe effect with css3
date: 2015-08-09
issueId: 20
---

Today its a rainy day here and you cant do so much things on a rainy sunday, so we are going to recreate the tinder swipe effect with the power of css3.

First of all, i know you like seeing the final effect before reading the post, so here you [got it](http://pudymody.github.io/tinderSwipe/) and if you want just to read the code [here](https://github.com/pudymody/tinderSwipe) you got the repository

First we begin creating a simple html structure for our project.
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Document</title>
</head>
<body>
    <div class="view"></div>
</body>
</html>
```

Then we create a simple function to get random user data from [https://randomuser.me](https://randomuser.me) and append it to our stored view div (*The markup and styles used here are just to this project, they arent needed to work, you can use whatever you want*).
```js
var $VIEW = document.querySelector('.view');
function getPerson(cb){
    var url = "https://randomuser.me/api/?gender=female";

    var oReq = new XMLHttpRequest();
        oReq.addEventListener('load', function(){
            var data = JSON.parse(this.responseText);
            data = data.results[0].user;

            var html = '<div class="user-card"><img class="user-card__picture" src="'+data.picture.large+'"></img><h1 class="user-card__name">'+data.name.first+' '+data.name.last+'</h1></div>';
            $VIEW.innerHTML = html;
        });
        oReq.open("get", url, true);
        oReq.send();
}

getPerson();
```

We proceed to style this cards.
```css
body {
    margin: 0;
    font-family: sans-serif;
}

.user-card {
    max-width: 500px;
    margin: 10px;
    border: 1px solid #ccc;
    padding: 8px;
    box-shadow: 0px 2px 5px 0px #ccc;
}

.user-card__picture {
    width: 100%;
    display: block;
}

.user-card__name {
    margin-bottom: 0;
    margin-top: 8px;
}
```

Till now, we only have one card with random people's faces and names, so here it comes the magic. First we need to create two classes, one for the left-swipe and one for the right-swipe
```css
.swipe-left {}
.swipe-right {}
```

Now, we have to create the two animations (*here i use the unprefixed versions, but you can/must use the prefixied ones*)
```css
@keyframes swipe-left {
    to {
        transform: rotate(-13deg) translate3d(-100%, 0, 0)
        opacity: 0;
    }
}

@keyframes swipe-right {
    to {
        transform: rotate(13deg) translate3d(100%, 0, 0)
        opacity: 0;
    }
}
```
So, what are we doing here? We are creating two animations (swipe-left and swipe-right) which takes the element being applied, rotates it 13 degs and moves it to its left or right ( the params for translate3d are x,y,z ), and reduce its opacity till 0 to make it fade

Now we have our two classes, and our two animations we only just have to link them
```css
.swipe-left {
    animation: swipe-left 1s forwards;
}

.swipe-right {
    animation: swipe-right 1s forwards;
}
```

And here we end, now the only thing you have to do its apply this two classes *swipe-left* and *swipe-right* to whatever element you want.

Another useful tip its to listen for the animationend event from javascript and delete the element. [Good post about it](http://davidwalsh.name/css-animation-callback)
