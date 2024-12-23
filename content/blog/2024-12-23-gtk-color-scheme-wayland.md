---
title: "GTK 'color-scheme' under Wayland"
date: 2024-12-23
issueId: 128
---

As i said in my last [two](/blog/2024-12-17-notes-idle-linux-wayland/) [posts](/blog/2024-12-17-pipewire-hdmi-no-sound/) im setting up again my computer and this took me another few hours to found why it wasnt warking.

Although i followed the [Arch Wiki](https://wiki.archlinux.org/title/Dark_mode_switching#GTK) guide on how to setup GTK dark mode under wayland, it wasnt working. `gsettings set org.gnome.desktop.interface color-scheme 'prefer-{dark/light}'` did nothing.

I installed `xdg-desktop-portal` and `xdg-desktop-portal-gtk`. 

`xdg-desktop-portal` was being executed automatically, but not `xdg-desktop-portal-gtk`.

I could test that it was working by killing all instances of `xdg-desktop-portal` and manually launching `/usr/libexec/xdg-desktop-portal`. So it must be a problem when starting it.

Thanks to the [Gentoo wiki](https://wiki.gentoo.org/wiki/Sway#Screen_sharing_does_not_work) i found out that i have to run `dbus-update-activation-environment --all` on my startup script.

And now everything is working, all color changes are a command away. Its interesting how many things we do for granted when we install a fully desktop enviroment.
