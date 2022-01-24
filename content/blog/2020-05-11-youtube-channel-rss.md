---
title: Youtube channel RSS url
date: 2020-05-11
issueId: 36
---

Since i dont have a Youtube account, but i still want to be subscribed to some great channels, i use their [RSS](https://en.wikipedia.org/wiki/RSS) url. The problem with this is that although they are available, Youtube doesnt make them public in their website. So i always return to this [excellent answer](https://webapps.stackexchange.com/a/116549). As i dont want to lose it, im going to copy it here.

If you have the ChannelID, you can make it with the following way ```https://www.youtube.com/feeds/videos.xml?channel_id=ChannelID```.

Or you can always execute this snippet in the console devtools to get the url.
```js
for (var arrScripts = document.getElementsByTagName('script'), i = 0; i < arrScripts.length; i++) {
    if (arrScripts[i].textContent.indexOf('externalId') != -1) {
        var channelId = arrScripts[i].textContent.match(/\"externalId\"\s*\:\s*\"(.*?)\"/)[1];
        var channelRss = 'https://www.youtube.com/feeds/videos.xml?channel_id=' + channelId;
        var channelTitle = document.title.match(/\(?\d*\)?\s?(.*?)\s\-\sYouTube/)[1];
        console.log('The rss feed of the channel \'' + channelTitle + '\' is:\n' + channelRss);
        break;
    }
}
```

Another option is to add this {{< rawhtml >}}<a href="javascript:(function()%7Bfor%20(var%20arrScripts%20%3D%20document.getElementsByTagName('script')%2C%20i%20%3D%200%3B%20i%20%3C%20arrScripts.length%3B%20i%2B%2B)%20%7B%0A%20%20%20%20if%20(arrScripts%5Bi%5D.textContent.indexOf('externalId')%20!%3D%20-1)%20%7B%0A%20%20%20%20%20%20%20%20var%20channelId%20%3D%20arrScripts%5Bi%5D.textContent.match(%2F%5C%22externalId%5C%22%5Cs*%5C%3A%5Cs*%5C%22(.*%3F)%5C%22%2F)%5B1%5D%3B%0A%20%20%20%20%20%20%20%20var%20channelRss%20%3D%20'https%3A%2F%2Fwww.youtube.com%2Ffeeds%2Fvideos.xml%3Fchannel_id%3D'%20%2B%20channelId%3B%0A%20%20%20%20%20%20%20%20var%20channelTitle%20%3D%20document.title.match(%2F%5C(%3F%5Cd*%5C)%3F%5Cs%3F(.*%3F)%5Cs%5C-%5CsYouTube%2F)%5B1%5D%3B%0A%20%20%20%20%20%20%20%20prompt(channelTitle%2C%20channelRss)%3B%0A%20%20%20%20%20%20%20%20break%3B%0A%20%20%20%20%7D%0A%7D%7D)()%3B">Subscribe</a>{{< /rawhtml >}} bookmarklet to your bookmarks and just click it.
