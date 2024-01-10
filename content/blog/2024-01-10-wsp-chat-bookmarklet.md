---
title: "WhatsApp direct chat bookmarklet"
date: 2024-01-10
issueId: 119 
---

Another day, another pain point that could be solved with a little enchant. On the web, sometimes people publishes or handles you their whatsapp number. But to talk, you have to add them as a contact.

Few knows that whatsapp [provides a url you can use to chat directly](https://faq.whatsapp.com/5913398998672934). Its nothing more than `https://wa.me/1XXXXXXXXXX`

So lets write something to make that link with the currently selected text.

As always, here is the javascript code if you want to run it in your devtools
```js
const sel = window.getSelection().toString().replaceAll(/[^0-9\.]+/g, ""); sel !== "" && window.open(`https://wa.me/${sel}`, "_blank");
```

Another option is to add this {{< rawhtml >}}<a href="javascript:(function()%7Bconst%20sel%20%3D%20window.getSelection().toString().replaceAll(%2F%5B%5E0-9%5C.%5D%2B%2Fg%2C%20%22%22)%3B%20sel%20!%3D%3D%20%22%22%20%26%26%20window.open(%60https%3A%2F%2Fwa.me%2F%24%7Bsel%7D%60%2C%20%22_blank%22)%7D)()">WSP Chat</a>{{< /rawhtml >}} bookmarklet to your bookmarks and just click it.
