---
title: "KDE toggle dark mode"
date: 2023-09-15
issueId: 116
---

Following my previous [dark mode collection](/blog/2021-06-26-dark-mode-collection/) and having [fixed the switch between themes](/blog/2023-03-07-kde-global-theme-task-switcher/), now i have a button to toggle between dark and light mode from the taskbar.

Using [configurable button plasmoid](https://github.com/pmarki/plasmoid-button) with the `weather-clear` and `weather-clear-night` icons, running the following commands i can make an easy toggle theme button.

For the *on script* `lookandfeeltool -a org.kde.breeze.desktop`

For the *off script* `lookandfeeltool -a org.kde.breezedark.desktop`

{{< rawhtml >}}
<video src="/static/imgs/kde-toggle-dark/demo.mp4" controls loop>
{{</ rawhtml >}}
