---
title: Host a Youtube watch party
date: 2020-04-08
issueId: 35
---

# Intro
During this COVID lockdown, with a group of friends we are doing what i call a *youtube watch party*, everyone take turns to play a youtube video and we discuss it or comment about it as we see it in sync. Its the closest thing we have to being together during this time. And in this post im going to explain how you can setup your own.

# Install
First, you need to install the following software. This guide is made for windows users but the three of them provides Unix and Mac versions.

1. [MPV](https://mpv.io/installation/) - [Windows builds](https://sourceforge.net/projects/mpv-player-windows/files/stable/)
2. [Youtube-dl](https://ytdl-org.github.io/youtube-dl/download.html)
3. [Syncplay](https://syncplay.pl/)

If you dont know which file to download for MPV you will probably need the *mpv-0.X.X-**x86_64**.7z* file. For youtube-dl you need to click in the *Windows exe* link.

# Config
After you extract the MPV file, put the *youtube-dl.exe* file you have just downloaded in the same folder as the *mpv.exe* file you have just extracted. Then install Syncplay, or extract it if you have downloaded the portable version.

Now its time to setup everything. Open the Syncplay program and you will be greeted with a config screen. In the *server address* option select one, and make sure everyone selects the same. Under *username* put yours, to make sure everyone recognices you. Under *default room* put the name of your room and make sure everyone also puts the same. This is the same as a chat room, to talk with them, everyone needs to be in the same room. Finally in *path to media player* press in browse and search for the *mpv.exe* file you downloaded previously. Hit *Store configuration and run Syncplay* and you should be inside the room.

![Syncplay config box](/static/imgs/host-a-youtube-watch-party/syncplay-config.jpg)

# Room settings
Here you have two modes. Managed room and Non-managed room (default option). The difference between the two is that in a managed room, only people with the password can manage the playback options as play status, media playing, position. And everyone else could only watch and chat. This is useful if you dont want to give everyone power over what is playing. To create one of these you need to go to *Advanced -> Create managed room* and in the notification box you should see the new name and password for that room. Using the *Advanced -> Identify as room operator* option you would be asked for the previous password and would be able to control the room.

![Syncplay creating a managed room](/static/imgs/host-a-youtube-watch-party/syncplay-managed.jpg)
![Syncplay created managed room information](/static/imgs/host-a-youtube-watch-party/syncplay-managed-created.jpg)

# Usage
From the playlist menu is where you can put your links to be watched by everyone. You need to right click and select *Add url(s) to bottom of playlist*, there in the popup menu, you insert your link and press ok. Now everyone should have the video playing in their player. When everyone has marked as ready in the main interface, the manager can start the playback.

![Syncplay playlist](/static/imgs/host-a-youtube-watch-party/syncplay-playlist.jpg)

**The way i think this works is by only syncing the playback status, thats why if you want to play a local file, everyone needs to have it.** Doesnt need to be the same file, but at least have the same duration and name. To do this, you need to add the folder to the sources in *File -> Set media directories*. Thats the list of folders the player will search when it needs to play a local file.

**And the most important thing about the player, is that if you press enter, you could chat from the video itself.**
