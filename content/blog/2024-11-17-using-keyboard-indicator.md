---
title: "Using my keyboard as an indicator"
date: 2024-11-17
issueId: 124 
---

## Intro
This post was going to be called *Hacking my keyboard* or *reverse engineering my keyboard* but that is a **long** stretch. Instead its more of a journey and fun things along the way.

A few months ago, i bought my first [mechanical keyboard](https://ar.vsglatam.com/products/mintaka). Its a rebrand one, but that i found at the end. Being the kind of keyboard it is, the software to customize it only runs on windows, so i thought *how hard can it be to port it to linux?* or at least reverse engineer the protocol.  I have seen some of these in the past, like [this one in javascript](https://www.youtube.com/watch?v=is9wVOKeIjQ) or [this other one hooked to an http webhook](https://blog.cynthia.re/post/keyboard-alerts). The journey begins.

## First failure
My first attempt was to search in [OpenRGB](https://openrgb.org/), but no luck, my keyboard isnt famous enough. Time to do the hard work.

I was already running [Virtualbox](https://www.virtualbox.org/) to use the original software. My first attempt was to run [Wireshark](https://www.wireshark.org/) and [capture the usb traffic](https://wiki.wireshark.org/CaptureSetup/USB) to then replay that series of commands by code under linux, my main os.

I first tried using [node-hid](https://github.com/node-hid/node-hid/tree/master) a NodeJS library to interact with hid devices. But although i was replaying the same commands captured by wireshark, it wasnt working, my keyboard turned off inmediatly after sending the raw packets. 

Maybe it was a problem with the node library, time to try some Go using the *[defacto library](https://github.com/karalabe/usb)*, but the same thing happend, no change of lights. I also tried to use this [other library](https://github.com/karalabe/hid) but nothing.

What if we go even lower level, to the realms of [C code](https://github.com/libusb/hidapi?tab=readme-ov-file#what-does-the-api-look-like)? Nope, same thing.

Time to try some replayer code, maybe im doing something wrong. Time to try [usbrply](https://github.com/JohnDMcMaster/usbrply), a tool that promises to replay a given wireshark capture. But then again nothing was working.

## Time to read a little
Here i started to think, *maybe its easier if i try to read some basics about how usb works, it doesnt seem to be just a [replay attack](https://en.wikipedia.org/wiki/Replay_attack)*..

So i started reading different [blog posts](https://embeddedguruji.blogspot.com/2019/04/learning-usb-hid-in-linux-part-3.html),  even from people [doing the same thing as me](https://www.beyondlogic.org/usbnutshell/usb1.shtml),  or more [low level explanations](https://www.engineersgarage.com/usb-requests-and-stages-of-control-transfer-part-4-6/), going as far as the "[canonical guide for usb](https://www.engineersgarage.com/usb-requests-and-stages-of-control-transfer-part-4-6/)".

Although i learn a few things, nothing that allowed me to understand why the replays  wasnt working. All hope was lost at this point.

## A little light
Surfing reddit for other keyboards software, i found [two](https://www.reddit.com/r/Keychron/comments/obelqu/keymapping_customization_software/) [different](https://www.reddit.com/r/Keychron/comments/18znee6/k3_v2_aftermarket_software_for_rgb/) posts suggesting some "aftermarket" software for the [Keychron keyboard](https://www.keychron.com/). [Ninja71 Software](https://www.monstargears.com/75/?bmode=view&idx=3106747) its the name. And here comes the light in our path.

![Ninja71 Software screenshot](/static/imgs/using-keyboard-indicator/monster_gear.png)
![Mintaka software screenshot](/static/imgs/using-keyboard-indicator/mintaka_software.png)
Do you see the similarity? Its the exact same software but with a reskin. And OpenRGB [has support for this kind of keyboards](https://gitlab.com/CalcProgrammer1/OpenRGB/-/merge_requests/1090#62f5b2da8f68fd46b0a36563631e3525192de042), maybe i could use that code as my base. *(Spoiler: [That was the case](https://gitlab.com/CalcProgrammer1/OpenRGB/-/merge_requests/2543))*. Whats interesting about this, is the first comment:

> FYI - Keychron keyboards are similar to EVision, they use Sonix SN32 chips though from an OEM known as Huafenda (HFD). These HFD chips are used in more than just Keychron, so I would probably rename this HFDKeyboardController. HFD and EVision both use SN32F248B chips but have their own distinct stock firmwares.

We could confirm this as both keyboards share the same VendorID (0x05AC), and that the code for one works for the other with minor adjustments. A few comments and hiccups along the PR, and now the code is merged and ready to be used for everyone.

This is why i said that calling this post *reverse engineering my keyboard* would be a long streatch. I only stood on the shoulder of giants, of people smarter than me. But that doesnt make it any less interesting of a journey.
![Screenshot of a tweet saying: how software actually works for 99% of engineers: someone way smarter than you solved a really hard problem and now you build on top of their solution like adult legos and think you're a genius](/static/imgs/using-keyboard-indicator/lego.png)

## Toying with our new powers
My first experiment, its to configure my shell to flash with red whenever a command exits with an status different to 0. AKA a command that failed.

First we need some script that calls OpenRGB and flashes with the given color and then loads our default profile.

```sh
 #! /bin/sh
openrgb --device 0 --mode static --color $1 -b 100 --noautoconnect --loglevel 1
openrgb --device 0 --mode static --color ffffff -b 100 --noautoconnect --loglevel 1
openrgb --device 0 --mode static --color $1 -b 100 --noautoconnect --loglevel 1
openrgb --device 0 --mode static --color ffffff -b 100
openrgb -p /home/pudymody/.config/OpenRGB/asdf.orp --noautoconnect --loglevel 1
```

After that, we only need to conjure some zsh encantation to run before every cmd

```sh
print_status(){
	if [ $? -ne 0 ]; then
		(/home/pudymody/bin/flash.sh ff0000 > /dev/null 2>&1 &)
	fi
}
precmd_functions+=(print_status)
```
And now, whenever a command fails, the keyboard will look like this:

{{< rawhtml html >}}
<video src="/static/imgs/using-keyboard-indicator/demo.mp4" controls="controls" muted="muted" style="max-width:100%;max-height:640px;"></video>
{{< /rawhtml >}}

## Outro
It started a little difficult, with a few wrong paths that lead me to learn and try some new things that didnt work, but few things tends to work on the first try. But now, thanks to the amazing work of other people, whenever i run a failed command, my keyboard will alert me, and the rest of the time, i could decorate to my like.
