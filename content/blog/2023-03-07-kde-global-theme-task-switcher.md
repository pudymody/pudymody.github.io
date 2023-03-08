---
title: "Kde global theme task switcher"
date: 2023-03-08
issueId: 100 
---

Im a happy KDE user and i love it. I think they success at one of their mottos *"Simple by default, powerful when needed"*. But there is one little tiny nitpick. I dont like the default task switcher.

![Default task switcher](/static/imgs/kde-global-theme-task-switcher/task-switcher-default.jpg)

Yes, i know you can change it from the settings, and thats what i've done. I like this one, the old-classic-win task switcher.

![Big icons task switcher](/static/imgs/kde-global-theme-task-switcher/task-switcher-win.jpg)

But i also like sometimes, when its dark at night to change the global theme to the dark one to feel like a **real haxx0r**. I do it from the settings home page.

![Settings home page](/static/imgs/kde-global-theme-task-switcher/settings-home.png)

The problem with this is that it changes my liked task switcher to the default one. My solution to this? Edit the theme. Is the correct one? I dont know, but its A solution and it works for me.

The files i had to edit were */usr/share/plasma/look-and-feel/org.kde.breeze.desktop/contents* and */usr/share/plasma/look-and-feel/org.kde.breezedark.desktop/contents* removing the following lines

```
[kwinrc][WindowSwitcher]
LayoutName=org.kde.breeze.desktop
```

As our theme doesnt have a WindowSwitcher config anymore, it will mantain whats currently set.
