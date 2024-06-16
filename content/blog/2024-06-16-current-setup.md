---
title: "Current Setup"
date: 2024-06-16
issueId: 122
---

# Intro
![Fake working example](/static/imgs/current-setup/working.png)

This is a record of my current setup in case my computer caughts on fire and i have to recreate it. It wouldnt be the first time.

# Desktop Environment
I started using KDE but i transitioned to [my own fork of dwm](https://github.com/pudymody/dwm). I like the four basic layouts (top/left/bottom/right) of [AwesomeWM](https://awesomewm.org/). I tried to use it, but i ended using like 2% of all that it provides. I also like the idea behind [bspwm](https://github.com/baskerville/bspwm) of only dealing with layouts and controlling everything through an IPC. And i think [dwm](https://dwm.suckless.org/) nailed the idea of a master-slave layout. Being a relative small project i decided to add some of the [provided patches](https://dwm.suckless.org/patches/) and a few of my own to get the best of the three worlds.

The main differences are:
- Four different layouts (top/left/bottom/right)
- Attach new clients by default in the slave stack
- Move clients in the stack
- Cycle between layouts
- Smart gaps (without gaps when only one window, configurable)
- Settings per tag
- Some configs from xresources
- Enough ewmh tags to use polybar with its xresources module
- Remove bar code and keys handling
- IPC control

For keys handling im using [sxhkd](https://github.com/baskerville/sxhkd) and for the status bar [Polybar](https://github.com/polybar/polybar/) with a few custom scripts.

For the wallpaper i have a custom script running in a cronjob to change the [dynamic wallpapers](https://github.com/adi1090x/dynamic-wallpaper).

The theme im using is [Catppuccin](https://github.com/catppuccin/catppuccin) with a custom script that will change all my apps to the selected version (dark/light) on demand or automatically given the hour.

For dark/light mode im using `xsettingsd` and every KDE app is run with `env XDG_CURRENT_DESKTOP=kde` to pick the correct theme.

# Software

- [Dolphin](https://apps.kde.org/dolphin/)
- [Nvim](https://neovim.io/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [ZSH](https://www.zsh.org/)
- [Rofi](https://github.com/davatorium/rofi)
- [Joshuto](https://github.com/kamiyaa/joshuto)
- [MPV](https://mpv.io/)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [KeepassXC](https://keepassxc.org/)
- [git](https://git-scm.com/)
- [scrot](https://github.com/resurrecting-open-source-projects/scrot)
- [urxvt](http://software.schmorp.de/pkg/rxvt-unicode.html)
- [pure prompt](https://github.com/sindresorhus/pure)
- [bat](https://github.com/sharkdp/bat)
- [fd](https://github.com/sharkdp/fd)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [delta](https://github.com/dandavison/delta)
- [fzf](https://github.com/junegunn/fzf)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [sqlitebrowser](https://sqlitebrowser.org/)
- [Firefox](https://www.mozilla.org/en-US/firefox/new/)
- [Filezilla](https://filezilla-project.org/)
- [Okular](https://okular.kde.org/)
- [Transmission](https://transmissionbt.com/)
- [qView](https://interversehq.com/qview/)
- [VeraCrypt](https://www.veracrypt.fr/code/VeraCrypt/)
- [Vorta](https://github.com/borgbase/vorta)
- [krabby](https://github.com/yannjor/krabby/)

# Firefox
![Firefox screenshot](/static/imgs/current-setup/firefox.png)
Here are the extensions that i have installed currently:

- [Audio equalizer](https://addons.mozilla.org/en-US/firefox/addon/audio-equalizer-wext/)
- [Catppuccin Selector](https://addons.mozilla.org/en-US/firefox/addon/catppuccin-selector/)
- [Facebook Container](https://addons.mozilla.org/en-US/firefox/addon/facebook-container/)
- [QR Code](https://addons.mozilla.org/en-US/firefox/addon/qr-code-address-bar/)
- [Steamcito](https://addons.mozilla.org/en-US/firefox/addon/steamcito-steam-impuestos-arg/)
- [Stylus](https://addons.mozilla.org/en-US/firefox/addon/styl-us/)
- [Tab Center Reborn](https://addons.mozilla.org/en-US/firefox/addon/tabcenter-reborn/)
- [Tabby Cat](https://addons.mozilla.org/en-US/firefox/addon/tabby-cat-friend/)
- [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/)

# dotfiles
With all the software installed, what is only left to do is clone my [dotfiles](https://github.com/pudymody/dotfiles)
