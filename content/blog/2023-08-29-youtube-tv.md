---
title: "Youtube TV"
date: 2023-08-29
issueId: 114 
---

Trying to clean my bookmarks (again) i found three entries dealing with this. Thats a lot for a simple tip. So a post it is.

Maybe you want to run the [Youtube TV](https://youtube.com/tv) experience from your computer. The same that Smart TVs and consoles have. But you cant, because they will redirect you to the homepage.

Lucky us [a reddit post](https://old.reddit.com/r/htpc/comments/y5o7mi/youtube_leanback_tv_useragent_for_4k_60fps/) has the answer. You have to change your user-agent.

To do this in [Firefox](https://www.mozilla.org/es-AR/firefox/new/), you have to go to [about:config](about:config) and make a new property called `general.useragent.override` and use the value `Mozilla/5.0 (PS4; Leanback Shell) Gecko/20100101 Firefox/65.0 LeanbackShell/01.00.01.75 Sony PS4/ (PS4, , no, CH)`

Maybe you could also set to true the property `dom.allow_scripts_to_close_windows` to allow closing the tab with the exit functionality, but i didnt need it.

Another idea is to make a new profile with this settings and an alias just to run it on its own in a fullscreen manner.
```sh
alias youtube_tv='firefox -profile "path to profile" -no-remote -new-window --kiosk "https://youtube.com/tv"'
```

If you use chrome, you could do it with the following command
```sh
google-chrome-stable --kiosk --enable-extensions --user-agent="Mozilla/5.0 (PS4; Leanback Shell) Gecko/20100101 Firefox/65.0 LeanbackShell/01.00.01.75 Sony PS4/ (PS4, , no, CH)" https://www.youtube.com/tv
```

If you only want the user-agent string, here it is
```
Mozilla/5.0 (PS4; Leanback Shell) Gecko/20100101 Firefox/65.0 LeanbackShell/01.00.01.75 Sony PS4/ (PS4, , no, CH)
```
