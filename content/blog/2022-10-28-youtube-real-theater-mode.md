---
title: "Youtube real theater mode"
date: 2022-10-28
issueId: 97
---

![youtube theater mode](/static/imgs/youtube-real-theater-mode/00.jpg)

This is Youtube's theater mode. It has something that's been bothering me since a few days. When i say *Theater mode* i expect the video to cover the full window, something that isnt happening here. I dont want to read the title or the author, i just want to view the video in its entirety.

In the same spirit as [Dave Rupert's The Patchability of the Open Web](https://daverupert.com/2022/09/patchability-of-the-open-web/) and [Jim Nielsen's Patching The Open Web](https://blog.jim-nielsen.com/2022/patching-open-web/) i decide to make a custom style for it which you can use with [Stylus](https://add0n.com/stylus.html)

```css
@-moz-document domain("youtube.com") {
ytd-watch-flexy[theater]:not([fullscreen]) #player-theater-container.ytd-watch-flexy {
    max-height: none;
    height: calc(100vh - var(--ytd-toolbar-offset))
}
}
```

You can run it from the developer's console as javascript
```js
(function(doc){
	const $style = doc.createElement("style");
	$style.innerHTML = `ytd-watch-flexy[theater]:not([fullscreen]) #player-theater-container.ytd-watch-flexy {max-height: none;height: calc(100vh - var(--ytd-toolbar-offset))}`;
	doc.body.appendChild($style)
})(document);
```

Or install it as a bookmarklet for one time uses: {{< rawhtml >}}<a href="javascript:(function(doc)%7Bconst%20%24style%20%3D%20doc.createElement(%22style%22)%3B%24style.innerHTML%20%3D%20%60ytd-watch-flexy%5Btheater%5D%3Anot(%5Bfullscreen%5D)%20%23player-theater-container.ytd-watch-flexy%20%7Bmax-height%3A%20none%3Bheight%3A%20calc(100vh%20-%20var(--ytd-toolbar-offset))%7D%60%3Bdoc.body.appendChild(%24style)%7D)(document)">Real theater mode</a>{{< /rawhtml >}}


However is that you choose to use it, now you can enjoy a real theater mode on Youtube.

![youtube theater mode](/static/imgs/youtube-real-theater-mode/01.jpg)
