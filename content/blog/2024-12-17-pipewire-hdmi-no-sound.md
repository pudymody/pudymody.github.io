---
title: "Pipewire no sound over HDMI"
date: 2024-12-17
issueId: 126
---

This is the second time that i was bitten by the same thing. One a few years ago and another a few days while setting my new pc. I have spent around two hours ending on the same post both times. So here its for future me to not lose it.

I have installed [Pipewire](https://wiki.archlinux.org/title/PipeWire) and everything was working. I connected my tv over HDMI to play some movies but sound wasnt coming.

It was interesting, because seing [pavucontrol-qt](https://github.com/lxqt/pavucontrol-qt) sound was recognised. Heck, even ```aplay -l``` recognized the output. Doing some tests with ```speaker-test --channels 2 --test wav --device hw:0,3``` and **it played**. So it must be some kind of configuration with pipewire.

To my luck, thanks to [this post by Ignacio Brittez](https://discussion.fedoraproject.org/t/how-to-enable-hdmi-audio-output-in-wireplumber-on-fedora-41/137313) i found out that my tv cant play 32bit audio, so i have to reduce it to 16bits.

First of all copy the default config
```
cp -r /usr/share/wireplumber ~/.config/
```

Then edit `~/.config/wireplumber/wireplumber.conf.d/alsa-vm.conf` with the following content

```
# ALSA node property overrides for HDMI output
monitor.alsa.rules = [
  {
    matches = [
      { node.name = "~alsa_output.*" }
    ]
    actions = {
      update-props = {
        audio.format = "S16LE"
        audio.channels = 2
        audio.position = "FR,FL"
      }
    }
  }
]
```

The important thing here is the *audio.format = "S16LE"* part. And now i can enjoy my movies in its full low quality sound.
