---
title: Recreating a book cover programatically
date: 2022-02-26
issueId: 51
---

![Book cover](/static/imgs/recreating-book-cover-programatically/cover.jpg)

This is the cover of a book a friend bought. After seeing it i tought "that seems like a cool [Coding challenge](https://www.youtube.com/channel/UCvjgXvBlbQiydffZU7m1_aw) type of things". After arriving home, i decided to recreate it but using SVG and vanilla js, nothing more.

After a while i had some basic image created. But this being the web and not some plain paper, i decided to **animate** it.

Sprinkle some [WebShare API](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share) because thats what all the cool kids are about right? Sharing stuff on social networks. And a download button just in case your browser doesnt  support it.

Add parameters settings by url, and a form as a frontend, and you have [this experiment](https://pudymody.github.io/playground/name-graph.html).

You can read [its source code](https://github.com/pudymody/playground/blob/main/name-graph.html), but be aware, its not production ready because... *hey its just an experiment*.