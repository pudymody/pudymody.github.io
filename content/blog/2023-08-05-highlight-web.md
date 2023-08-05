---
title: "Highlight web content"
date: 2023-08-05
issueId: 113 
---

Whenever i read something from my [feed reader](https://freshrss.org/) that i like or want to share, i tend to highlight some parts to quote in my [stream section](/stream).

I used to read all the article and  when i have finished it, reread looking for the parts that i liked. This was inefficient as i had to read the same thing twice.

Thats when another bookmarklet was born. Select some text that you like, and click it to highlight it.

It works by getting the bounding box of the current selection and making an overlay div there. As it takes the position when calling it, if content is added or shifted afterwards, the highlight will be broken. But for highlighting content to reference in a few minutes or hours works for my case. It also doesnt persist it, so try no to close the article. Or maybe it could be made into a lean browser extension.

As always, here is the code if you want to call it from your devtools or however you run this things. It uses a yellow overlay, but you can change it modifying the `rgba(255,255,0,.3)` part.

```js
[...window.getSelection().getRangeAt(0).getClientRects()]
    .map( e => {
        const a = document.createElement("mark");
        a.style.position = "absolute";
        a.style.pointerEvents = "none";
        a.style.background = "rgba(255,255,0,.3)";
        a.style.left= (e.left+document.documentElement.scrollLeft)+"px";
        a.style.top = (e.top+document.documentElement.scrollTop)+"px";
        a.style.height = e.height+"px";
        a.style.width = e.width+"px";
        return a;
    })
    .forEach(d => { document.body.appendChild(d); });
```

Another option is to add this {{< rawhtml >}}<a href="javascript:(function()%7B%5B...window.getSelection().getRangeAt(0).getClientRects()%5D.map(%20e%20%3D%3E%20%7B%20const%20a%20%3D%20document.createElement(%22mark%22)%3B%20a.style.position%20%3D%20%22absolute%22%3B%20a.style.pointerEvents%20%3D%20%22none%22%3B%20a.style.background%20%3D%20%22rgba(255%2C255%2C0%2C.3)%22%3B%20a.style.left%3D%20(e.left%2Bdocument.documentElement.scrollLeft)%2B%22px%22%3B%20a.style.top%20%3D%20(e.top%2Bdocument.documentElement.scrollTop)%2B%22px%22%3B%20a.style.height%20%3D%20e.height%2B%22px%22%3B%20a.style.width%20%3D%20e.width%2B%22px%22%3B%20return%20a%3B%20%7D).forEach(d%20%3D%3E%20%7B%20document.body.appendChild(d)%3B%20%7D)%7D)()">Highlight</a>{{< /rawhtml >}} bookmarklet to your bookmarks and just click it.
