---
title: "My first minigame"
date: 2023-07-12
issueId: 111 
---

![Screenshot of the game](/static/imgs/my-first-minigame/screenshot.png)

I made a minigame. Why? It doesnt matter. My plan was to make 9 minigames that didnt need too many buttons, 2 at most. That could be played in mobile and desktop.  I probably wont publish, not even make the 8 left, but why not release at least one as a little pet project?.

By the constraints i made, the web was the perfect solution, it would work wherever a browser can run. And it provided me a platform with a lot of things already solved.

My first attempt was to use a [canvas renderer](https://pudymody.github.io/minigames/src/canvas) ([source](https://github.com/pudymody/minigames/blob/main/src/canvas.html)). But i have a problem scaling the sprites and retaining the pixel perfect look.

Thats when i thought *"why not use the DOM? Nowadays is optimized and the graphics and interactions arent that complex."*. And that way the [dom version](https://pudymody.github.io/minigames/src/dom) was born. ([Source](https://github.com/pudymody/minigames/blob/main/src/dom.html) also available)

Doing this was my first time using the [ScreenOrientation.lock](https://developer.mozilla.org/en-US/docs/Web/API/ScreenOrientation/lock) and the [Element.requestFullscreen](https://developer.mozilla.org/es/docs/Web/API/Element/requestFullScreen) APIs. And they are fantastic for this kind of experiences.

For the sprites i used [LibreSprite](https://libresprite.github.io/), but being simple pixel art, they could probably be made in any image editor.

The gameplay is simple. Two players with half of the screen each. Both have a current card that changes every round. Whenever you see your card drawn in the middle tap your side and score a point. If you see your opponent's, tap and steal a point. Tap when there is another card and lose a point.

I think i dont have anymore to say. **[Go play it](https://pudymody.github.io/minigames/src/dom)**
