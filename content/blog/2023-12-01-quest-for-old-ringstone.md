---
title: "Quest for an old ringstone"
date: 2023-12-01
issueId: 118 
---

## Intro
Following my previous post [Big Black Blob (BBB)](/blog/2023-04-06-big-black-blob-bbb/) i sailed in this quest of trying to find this old ringstone.

> I still remember the goofy/silly monkey sound it made when you took a photo (i cant find any video or file about it, if you have one please send it to me).

## Firmware
The first step in this ambitious and overly-complicated journey is having access to the [firmware](https://en.wikipedia.org/wiki/Firmware). I dont have this cellphone anymore, and i havent for a long long time. Even if i had it, i wouldnt know how to dump it. So my best solution is search in google for old forums and personal websites.

To my luck a user called **msajum**, [posted a dump](https://forum.gsmhosting.com/vbb/f477/motorola-v220-firmware-1546902/#post8816106) in some forum in **2012**. I hope this is a good one that has all the data needed. But here is the possible first hero of this tale.

I also found [this post](https://forum.gsmhosting.com/vbb/f166/motorola-shx-sbf-firmwares-here-859277/) but it has all dead links from Rapidshare (do you remember Rapidshare? What great times we lived on). Searching for those links, i also found [this 4shared folder](https://www.4shared.com/minifolder/nQKOPUZL/Firmware_V220.html?woHeader=1)

Other links that i found are [1](https://motohell.com/index.php?topic=290.0) - [2](https://www.4shared.com/rar/rgopqY7I/R364_G_0BD11AR_LP0021_DRM0001_.html?locale=en) -  [3 (but this one needs you to register)](https://service-gsm.net/Motorola/Flash%20files/V220/) -  [4](https://www.4shared.com/minifolder/8sW6Jryu/Firmware_C650.html?woHeader=1) 

Now i have a lot of possible files, without any kind of information or sign that they are the correct ones. Probably a lot of duplicates and versions that arent even for this cellphone. I will try first with the one from **msajum** as it seems the promising one.

## SHX File
The next step is understanding how to manipulate the file we have just downloaded. Time for some more googling and reading old forums with lots of tools and dead links. With the hope that at least one works for what we want to do, which is at minimum extract a single ringstone. And at most write a full emulator.

My first findings were old posts [1](https://forum.gsmhosting.com/vbb/f83/motorola-shx-unsplitter-decryptor-99327/) - [2](https://forum.gsmhosting.com/vbb/f166/unsplit-decrypt-shx-flash-files-99259/) - [3](https://www.howardforums.com/showthread.php/432945-NEW-SHX-Master-The-SHX-lt-gt-BIN-Converter) all with dead links to two tools.

The next one was 7 posts ([1](https://www.howardforums.com/showthread.php/757544-How-to-extract-a-flex-from-a-shx-file) - [2](https://foros.3dgames.com.ar/threads/283041-motorola-desbloqueo-v3-con-bootloader-08-26/page4) - [3](https://motohell.com/index.php?topic=2729.0) - [4](https://www.clangsm.com/forum/index.php?showtopic=65603) - [5](http://www.e398mod.com/content/view/50/28/) - [6](https://falear.foroactivo.com/t509-tutorial-editar-drm-con-shxcodec) - [7](https://blog-moumouza.blogspot.com/2011/11/tutorial-solucion-definitva-para.html)) (although a few of them seems to be the same comment or reposting) all suggesting the same tool *SHXCoDec*, one that i couldnt make it run under Windows XP as i was doing everything inside a virtual machine.

Another thing that i found was this [SHX File Hacking Guide](https://www.laneros.com/attachments/shx-file-hacking-pdf.16288/) with the following paragraph:

> **RandomSHX** – There are many SHX<=>BIN converters out there, this is the only one
worth it’s salt. Sorry to all the other authors out there. This is the only program that will
faithfully recreate an SHX from bin files. The only thing it will not do is recalculating
the header, which is what this guide is for.

And it wasnt joking as this was the one that i could run and finished using. But this only gave me a name and lots of information that could be useful when trying to make the emulator, now i have to search for another tool on the web.

Lucky me, i found another [excellent wiki full of resources](https://lpcwiki.miraheze.org/wiki/Phone_and_firmware_manipulation_guide#Motorola) all about old phones firmware modding. 

Now the plan was: Use *RandomSHX* or *Flash & Backup* to extract the downloaded shx file, and then *FlexParser04* to extract its content to raw files.

Inspecting the extracted files, under the */a/mobile/system* folder i found 5 suspicious files named *shutter1-5.amr*. 

After some duckducking, i found that this is an [audio codec](https://en.wikipedia.org/wiki/Adaptive_Multi-Rate_audio_codec). **The plot thickens.**

Time to copy them to my host machine, as i cant play them in XP.

**THEY ARE. They are the 5 shutter sounds that you could choose when taking a picture. The first is the one that originated this journey.**

Here they are in their full glory after converting them to more modern formats that everyone can play.

{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/shutter1.ogg" controls></audio> {{</ rawhtml >}}

{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/shutter2.ogg" controls></audio> {{</ rawhtml >}}

{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/shutter3.ogg" controls></audio> {{</ rawhtml >}}

{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/shutter4.ogg" controls></audio> {{</ rawhtml >}}

{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/shutter5.ogg" controls></audio> {{</ rawhtml >}}

To my surprise this worked **flawlessly**, not a single problem more than finding the right resources. This is possible thanks to all the people that share information and tools in this world for the solely purpouse of helping everyone else. They are the real heros in everything that we do. I think this is another example of the value of archiving old information and tools to prevent them from being lost.

We have arrived to our first checkpoint, now its time to rest for a while, maybe listening to one of the songs that came with this phone before embarking in making an emulator for this.

I will be playing the *monkey sound* in repeat a few times with a stupid face while im amazed at how something like sound, which are only waves that travel through air can make you feel like this. And we will see in the future if we can write an emulator for this. Who knows.

{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/1.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/2.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/3.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/4.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/5.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/6.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/7.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/8.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/9.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/10.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/11.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/12.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/13.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/14.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/15.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/16.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/17.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/18.ogg" controls></audio> {{</ rawhtml >}}
{{< rawhtml >}} <audio src="/static/imgs/quest-old-ringstone/19.ogg" controls></audio> {{</ rawhtml >}}
