---
title: "Bringing a 1998 X-Files game to web standards"
date: 2023-02-18
issueId: 99
---

Or **Electron but its 1998** as i also thought of calling this post.

# Intro

**I love The X Files**. Its one of my top series. The other day i was reading through the [long list of merchandise](https://en.wikipedia.org/wiki/The_X-Files_merchandise) and i found something thats interesting to me.

*The X-Files: Unrestricted Access* videogame. Its some kind of database with everything from the series, and a *top-tech* interface. Although i loved the idea, this is not what surprised me.

Quoting the [wikipedia page](https://en.wikipedia.org/wiki/The_X-Files:_Unrestricted_Access)

> Released in 1998, the game was met with mostly positive reviews, with its attention to detail and aesthetics considered as highlights; **however, its reliance on Internet Explorer 4 was viewed as a detraction.**

In 1998 there were already software that needed an entire browser to run, and seems that people had strong opinions. However nowadays we are in the same place, and i believe that even worse.

Every software runs in Electron: [Discord](https://discord.com/), [Obsidian](https://obsidian.md/), [WhatsApp](https://www.whatsapp.com/), [Visual Studio Code](https://code.visualstudio.com/), [Slack](https://slack.com/intl/es-ar/), and a [lot more](https://www.electronjs.org/apps). But no one seems to beat an eye about it or do something.

At least, they run on a browser that respects standards. *Right??*

In this post, i will try to run this same game on a modern browser, and see if we could learn something about it, or at least take a view in the history of browser technologies.

# Browser checking

After installing a virtual machine with Windows 98, extracting the files, and running a server. The first thing we found is this.

![Image of browser checking for IE 4](/static/imgs/xfiles-game-web-standards/iecheck.png)

```js
function init() {
    var version, name;

    name = navigator.appName
    version = navigator.appVersion.substring(0, navigator.appVersion.indexOf(" "));

    if(name != "Microsoft Internet Explorer" || version < "4.0")
        location.href = "error.htm";

    else
        loadXfua();
}
```

This isnt even checking for a userAgent, this is directly checking for name and version. Although this shouldnt be done, and everyone should do feature detection with progressive enhancement instead, i think this was right at the time, standards wasnt spread all along. But today this is a big no-no, so, time to comment this peace of code if i want it to run.

# Old javascript tag

After commenting that previous piece of code... Nothing happens.

![Image of a broken app](/static/imgs/xfiles-game-web-standards/brokenapp.png)

Checking the console browser, we found the following errors:

![Image of the browser console of the broken app](/static/imgs/xfiles-game-web-standards/brokenappconsole.png)
```
Uncaught ReferenceError: tempFrameOnLoad is not defined
Uncaught ReferenceError: init is not defined
```

It seems that javascript its not loading. Time to check the html as the request are all 200s.

```html
<script language=jscript src=main.js></script>
```

Aha, here is the problem. Now adays we dont have to specify the *language* attribute, or if we do, it has to be *"JavaScript"* as [per the spec](https://html.spec.whatwg.org/multipage/obsolete.html#obsolete-but-conforming-features). And as per [MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-language) this was never standardized. Not big of a problem although, a simple edit.

# Responsive design

Peeking around the code we found this beautiful gem.

```js
function loadXfua() {

    switch(window.screen.width) {

        case 640:
            location.href = "main6.htm";
            break;

        case 800:
            location.href = "main8.htm";
            break;

        case 1024:
            location.href = "main10.htm";
            break;

        case 1152:
            location.href = "main11.htm";
            break;

        default:
            location.href = "main11.htm";
            break;
    }
}
```

It conditionally loads a page depending on your screen's width. Responsive design with media queries? Never heard about them.

In their defense, media queries [didnt appear until 2001](https://www.w3.org/TR/2001/WD-css3-mediaqueries-20010404/). At least theoretically.

# Microsoft ActiveX

Here comes something that i have never seen in my life before. Or at least that i remember.

**A Microsoft ActiveX control.**

It seems to be a set of plugins that came preinstalled with IE4+, which you could embed and it will give you some functionality. In this case is the one with id *CLSID:333C7BC4-460F-11D0-BC04-0080C7055A83*, which according to [this page](http://www.javascriptkit.com/javatutors/tdc.shtml) and some googling, its a *Tabular Data Control*.

Or in modern terms, something that fetches a given url, parses it as a csv, and gives you some properties to work with it.

```html
<OBJECT ID="tagList" CLASSID="CLSID:333C7BC4-460F-11D0-BC04-0080C7055A83">
 <PARAM NAME="DataURL" VALUE="tags.txt">
 <PARAM name=UseHeader value="TRUE">
 <PARAM name=FieldDelim value=",">
 <PARAM name=TextQualifier value='"'>
 <PARAM name=EscapeChar value='\'>
</OBJECT>
```

This doesnt work anymore in any browser. In my understanding, browsers dont allow anymore external content outside the browser to be embedded by anyone in any page. *(As in plugins/software like Adobe Flash, Java applets, not as in external images or resources)*. But we have everything in our toolbox to built it, or at least pollyfill it. We have [fetch](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch) to request the url. We have [custom elements](https://developer.mozilla.org/en-US/docs/Web/Web_Components/Using_custom_elements) to use the same or similar html syntaxis. And lots of lots of [csv parsers](https://www.npmjs.com/search?q=csv).

You can read more about how this is made in a future post because it involved writing a parser for a custom language used for filtering data. Which i believe deserves its own post. ~~[Stay tuned](/blog/index.xml) for details.~~ [Here it is](/blog/2023-03-17-retrofill-microsoft-activex/)

## Sound: The old way
There is also another ActiveX control, but this could be replaced almost without thinking about it. This time is the *CLSID:05589FA1-C356-11CE-BF01-00AA0055595A* one. It was the way of embedding the Windows Media Player. There are some caveats but they are easy to surpase.

```html
<object id=atmosphereAudio CLASSID='CLSID:05589FA1-C356-11CE-BF01-00AA0055595A'>
<param name='FileName' VALUE='browser.wav'>
<param name='ShowControls' VALUE='false'>
<param name='ShowDisplay' VALUE='false'>
<param name='BorderStyle' VALUE='0'>
<param name='AutoStart' VALUE='1'>
<param name='PlayCount' VALUE='0'>
</object>
```

First, the audio file is in wav format, to [ensure compatibility](https://developer.mozilla.org/en-US/docs/Web/Media/Formats/Containers) lets convert it to an ogg file.

After reading old documentation pages and searching online to be sure, i realized that what it wants to do is the famous **background music on a loop with autoplay**, today we partially could do this. We have an audio tag, but some browsers block autoplay audio by default, so you have to put it in the whitelist.

It is also used for playing videos which in this case are in avi container. But nothing that [ffmpeg](https://ffmpeg.org), one of the best softwares in the open source world, glued with some [fd](https://github.com/sharkdp/fd/) couldnt handle.

```sh
fd -e avi -x ffmpeg -i {} {}.mp4
```
Although this would rename the file `1meeting.avi` to `1meeting.avi.mp4` this is not a problem, its even easier for changing the code of the player as we only need to add a suffix to the path.

Updating the js code to handle the different background musics per section, we could find some hidden gems like this one

```js
    if(atmoLastIndex == -1)
        atmoLastIndex = -1;
```

Another piece that i find interesting is the following one. Because is something that people still struggle with when doing software and need to handle windows and unix paths. Dealing with forward and backwards slashes when working with file paths. This one had to be modified to deal with urls, instead of windows file paths. Easy fix, but interesting still.

```js
    var atmoLen = atmosphereAudio.src.length;
    var atmoLastIndex = atmosphereAudio.src.lastIndexOf("\\");

    if(atmoLastIndex == -1)
        atmoLastIndex = -1;

    var atmoFileName = atmosphereAudio.src.substring(atmoLastIndex + 1, atmoLen);
```

# Image filters
The next thing that came to my attention after trying to make the javascript break as less as possible, was this thing:

```js
if(elem.filters(1).enabled == 0)
            elem.filters(0).enabled = 1;
```

It seems that [IE4-IE9 allowed different kind of filters in elements](https://webplatform.github.io/docs/concepts/proprietary_internet_explorer_techniques/). Something that was removed entirely from IE10 onwards.

You had the method ```filters(n)``` to get the n filter, and then that have different methods depending on which filter you applied. And also the *enabled* property.

I couldnt find anything about how the *[light](https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms533011(v=vs.85))* filter works, but after seeing it, the best i could do is brightness 220%, something we could do with the [css filter one](https://developer.mozilla.org/en-US/docs/Web/CSS/filter).

For the [invert](https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms533008(v=vs.85)) one we could also use the css filter one.

For the *enabled* property i will replace it with the presence or not of a css class. I could do this, because all the uses are enabling and disabling, and the filters are not dinamically changing. The index 0 is always the multiply overlay, and the index 1 is the invert. I dont know if you could pollyfill this api entirely with classes.

```css
#survCastDivInner img { --filter-light:; --filter-invert:; filter: var(--filter-light) var(--filter-invert); }
#survCastDivInner img.filter-light { --filter-light: brightness(220%); }
#survCastDivInner img.filter-invert { --filter-invert: invert(100%); }
```

# Elements ID variables
Throughout all the code is a heavy use of the thing that when you declare an id for an html element, a variable with that name which references that dom node is made available in the js context.

Something that today we know is a syntom of bad practices.

# Non-Standard JS
Here are some more things that i found around the code that made it not work. Some were IE only things that made its way to the standards with slightly changes, but nothing difficult to fix (kinda).

* [pixelLeft](http://help.dottoro.com/ljritkju.php): an element property setter/getter to set the left style property in pixels. Easy to change using the `style.left` property instead, and doing a `parseInt` when reading. Although it didnt made it to the standards, maybe in the future we could have something similar but more powerful and done right with the [CSS Typed OM API](https://developer.mozilla.org/en-US/docs/Web/API/CSS_Typed_OM_API).
* *HTMLIFrameElement.location* was used to set iframe src, something that now is done with the `src` attribute/property
* *HTMLIFrameElement.document* was used to access the iframe document, something that now is done with the `contentDocument` attribute
* [HTMLElement.sourceIndex](https://flylib.com/books/en/1.260.1.124/1/) was a property to return the index of the element in the `document.all` collection. For now, the solution is to find it manually without any kind of optimization.

This where the most pain in the ass to solve, because there was a lot of inline event handlers along all files, some eval black magic, and a lot of passing things between calls.

* [event global variable](https://developer.mozilla.org/en-US/docs/Web/API/Window/event): a global variable with the current event being handled. Easy to fix, we now receive this as the first param of our handler. And some method name renaming.
* [Event.cancelBubble](https://developer.mozilla.org/en-US/docs/Web/API/Event/cancelBubble): now called ```event.stopPropagation()```.
* [Event.returnValue](https://developer.mozilla.org/en-US/docs/Web/API/Event/returnValue): now called ```Event.preventDefault()```.
* [Event.srcElement](https://developer.mozilla.org/en-US/docs/Web/API/Event/srcElement): now called ```Event.target```.
* [event.button](https://www.quirksmode.org/js/events_properties.html#button): for mouse events, the button property value in IE is different to the one in the W3C standard.

# IE event binding
Another interesting thing is the use of the non-standard microsoft internet explorer way of [adding event listeners to some things](https://stackoverflow.com/questions/1557446/what-are-the-for-and-event-attributes-of-the-script-tag-javascript-html). This will listen for the `StateChange` event in the element with id `videoWin` and run the content of the script. Something that today could be done with a simple `querySelector+addEventListener`, nothing too hard to fix 

```html
<script language="JavaScript" for=videoWin event="StateChange(oldState, newState)">
    videoStateChange(oldState, newState);
</script>
```

# Forgiving HTML
Everything was working at this point, except for a particular scroller. I couldnt find why, until i saw this line. In IE4 it worked flawlessly, but not in modern browsers. Can you spot the error? The syntax highlighting may help you here.

```html
str = "<div id=survCastDivInner style='position:absolute; left:0' top:0'>";
```

It seems that the html parser in IE4 ignored the missplaced quotes and included the *top* declaration in the style attribute. But in modern browsers it wasnt included, making the scroller not work. An easy fix, but it took me a few days to spot it.

# Malformed CSV
Another interesting thing is the big amount of malformed csv that i have to fix by hand. Unescaped quotes, rows without the correct amount of fields, and other things.

# Missing things
There are still things that i couldnt look into because this post have been in the making for too long, but maybe they will have their own post in the future. We will see.

- Custom java applets with cabbase files.
- QuickTime Player plugin for 3d objects and panoramas *(this seems the most interesting to investigate)*

# Are we better?
Although my rant at the beginning about the browser share, its great that now we have a standard group with members from different companies, browser makers and community working together. Having a single source of truth is a great move forwards, as long as something implements it, you know your application will work there. Heck it doesnt even need to be a browser, as long as it implements it, it will work. And being retrocompatible, you have the certainty that it will work in 100 years and someone wont have to write a post like this one. Or maybe they will have to write one about how to implement an *old retro browser*.

# Git patches
If you somehow have the game and want to apply this changes, here you have all the patches with the changes i made. You have to apply them with git, and then start a server in the folder. Or maybe you only want to peek around the code.

- [0001-fix-Change-cd2-path-from-e-drive-to-cd2-folder.patch](/static/imgs/xfiles-game-web-standards/0001-fix-Change-cd2-path-from-e-drive-to-cd2-folder.patch)
- [0002-fix-Skip-IE4-browser-check.patch](/static/imgs/xfiles-game-web-standards/0002-fix-Skip-IE4-browser-check.patch)
- [0003-fix-Script-language-javascript-attribute.patch](/static/imgs/xfiles-game-web-standards/0003-fix-Script-language-javascript-attribute.patch)
- [0004-fix-Background-music.patch](/static/imgs/xfiles-game-web-standards/0004-fix-Background-music.patch)
- [0005-fix-Image-filters.patch](/static/imgs/xfiles-game-web-standards/0005-fix-Image-filters.patch)
- [0006-fix-pixelLeft-pixelTop-property.patch](/static/imgs/xfiles-game-web-standards/0006-fix-pixelLeft-pixelTop-property.patch)
- [0007-fix-SourceIndex-property.patch](/static/imgs/xfiles-game-web-standards/0007-fix-SourceIndex-property.patch)
- [0008-fix-Javascript-language-script-attribute.patch](/static/imgs/xfiles-game-web-standards/0008-fix-Javascript-language-script-attribute.patch)
- [0009-fix-Wrong-quoting-in-survCast-style-attribute.patch](/static/imgs/xfiles-game-web-standards/0009-fix-Wrong-quoting-in-survCast-style-attribute.patch)
- [0010-fix-Iframe-properties.patch](/static/imgs/xfiles-game-web-standards/0010-fix-Iframe-properties.patch)
- [0011-fix-More-pixelLeft-pixelTop-properties.patch](/static/imgs/xfiles-game-web-standards/0011-fix-More-pixelLeft-pixelTop-properties.patch)
- [0012-fix-Global-event-variable.-srcElement-button-prop.patch](/static/imgs/xfiles-game-web-standards/0012-fix-Global-event-variable.-srcElement-button-prop.patch)
- [0013-fix-More-image-filters.patch](/static/imgs/xfiles-game-web-standards/0013-fix-More-image-filters.patch)
- [0014-fix-More-media-player-to-html-native-tags.patch](/static/imgs/xfiles-game-web-standards/0014-fix-More-media-player-to-html-native-tags.patch)
- [0015-fix-UI-things-that-didnt-hide-when-closing.patch](/static/imgs/xfiles-game-web-standards/0015-fix-UI-things-that-didnt-hide-when-closing.patch)
- [0016-fix-Retrofill-activex.patch](/static/imgs/xfiles-game-web-standards/0016-fix-Retrofill-activex.patch)

# Reference
Here are some of the links i have in my bookmarks that i have used while doing this.

- [How do I rename all folders and files to lowercase on Linux? - Stack Overflow](https://stackoverflow.com/questions/152514/how-do-i-rename-all-folders-and-files-to-lowercase-on-linux/17730002#17730002)
- [DHTML Object Model Support for Data Binding | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms531391(v=vs.85))
- [XMLHttpRequest](https://javascript.info/xmlhttprequest)
- [TDC Object | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms531366(v=vs.85))
- [javascript - Is event a global variable that is accessible everywhere inside the callback chain? - Stack Overflow](https://stackoverflow.com/questions/6426497/is-event-a-global-variable-that-is-accessible-everywhere-inside-the-callback-cha)
- [javascript - Convert IE event.button to W3C event.button - Stack Overflow](https://stackoverflow.com/questions/2273907/convert-ie-event-button-to-w3c-event-button)
- [Javascript - Event properties](https://www.quirksmode.org/js/events_properties.html#button)
- [pixelLeft property JavaScript](http://help.dottoro.com/ljritkju.php)
- [style.pixelLeft and style.left](http://www.dynamicdrive.com/forums/showthread.php?18612-style-pixelLeft-and-style-left)
- [html - How do i access Iframe #document with javascript - Stack Overflow](https://stackoverflow.com/questions/51004952/how-do-i-access-iframe-document-with-javascript)
- [Control CLSIDs | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/ms983985(v=msdn.10))
- [Player6.ShowDisplay (deprecated) | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/ms985922(v=msdn.10))
- [Player6.ShowControls (deprecated) | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/ms985909(v=msdn.10))
- [Search | Microsoft Learn](https://learn.microsoft.com/en-us/search/?terms=Player6&dataSource=previousVersions)
- [Player6.PlayCount (deprecated) | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/ms869705(v=msdn.10))
- [Player6.PlayState (deprecated) | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/ms869714(v=msdn.10))
- [Player6.Stop (deprecated) | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/ms986158(v=msdn.10))
- [Player6.FileName (deprecated) | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/ms984771(v=msdn.10))
- [Proprietary Internet Explorer Techniques · WebPlatform Docs](https://webplatform.github.io/docs/concepts/proprietary_internet_explorer_techniques/)
- [addAmbient Method (Light) | Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/platform-apis/ms532949(v=vs.85))
- [sourceIndex · WebPlatform Docs](https://webplatform.github.io/docs/dom/HTMLElement/sourceIndex/)
- [what are the "for" and "event" attributes of the script tag](https://stackoverflow.com/questions/1557446/what-are-the-for-and-event-attributes-of-the-script-tag-javascript-html)
