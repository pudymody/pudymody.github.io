---
title: "Notes about idling on Linux/Wayland"
date: 2024-12-17
issueId: 127
---

As i said [in my previous post](/blog/2024-12-17-pipewire-hdmi-no-sound/) im setting my new computer. I took advantage of this to make it as *simple* as possible. That means dealing with things that i dont fully understand. Here are some notes about how idling works, or at least how i understand it. Its mostly a collection of quotes with text in between to make something cohesive. I spent a good amount of time reading so it shouldnt be lost in the ether.

At first i thought that modifying `/etc/elogind/logind.conf` with the following content would be enough.

```
IdleAction=suspend
IdleActionSec=30m
```

But it wasnt working. Reading the man pages and the [freedesktop.org](https://www.freedesktop.org/wiki/Software/systemd/writing-desktop-environments/) guides shines some light.

> Whenever the session gets idle the DE should invoke the SetIdleHint(True) call on the respective session object on the session bus. This is necessary for the system to implement auto-suspend when all sessions are idle. If the session gets used again it should call SetIdleHint(False). A session should be considered idle if it didn't receive user input (mouse movements, keyboard) in a while. See the Bus API of logind for further details. 

> Note that this requires that user sessions correctly report the idle status to the system. The system will execute the action after all sessions report that they are idle, no idle inhibitor lock is active, and subsequently, the time configured with IdleActionSec= (see below) has expired.

It seems that my choice of window manager of this time ([river](https://codeberg.org/river/river)) doesnt report this. Something that we could corroborate running the following command

```
gdbus call -y -d org.freedesktop.login1 -o /org/freedesktop/login1/session/auto -m org.freedesktop.login1.Session.SetIdleHint true 
```

After running this, it will suspend after 30m, and will continue doing it until we set it to false

```
gdbus call -y -d org.freedesktop.login1 -o /org/freedesktop/login1/session/auto -m org.freedesktop.login1.Session.SetIdleHint false
```

There is also [this comment from Megame50](https://www.reddit.com/r/swaywm/comments/wmxbqa/comment/ik3pckt/) from reddit validating this:

> swayidle asks the compositor to notify it when some time elapses without user activity. The compositor knows about all user input as it processes it and restarts its internal timer on user actions. When the timer has elapsed and nothing inhibits the idle state, the compositor notifies the client (swayidle) as much and swayidle takes the action it was configured to.

> logind has no role here – it is another client that wants to be notified about the idle state of the user session, similar to swayidle, however it doesn't speak wayland protocol, only dbus, and some other clients only want to listen to logind's opinion on the matter.

> So now swayidle is both the idle client and server, as it has features built to notify logind in turn when it is itself notified by the compositor. Similarly, some utilities don't speak wayland so swayidle has grown features to listen to those same signals from logind as well, allowing it to be notified by commands like loginctl lock-session.

> Because of the way logind awkwardly duplicates the idle management of the compositor, but in a way that splinters client tooling, and without any of the access or convenience of the compositor, logind integration is a candidate for removal from swayidle: https://github.com/swaywm/swayidle/issues/117.

[This other comment](https://github.com/swaywm/swayidle/issues/117#issuecomment-1059989173) from the [github issue](https://github.com/swaywm/swayidle/issues/117#issuecomment-1059989173) suggest the best solution: use *elogind* to trigger programatically the suspend/hibernate/poweroff and *swayidle* for listening for events.

> For idle actions, there is no point in having sway tell swayidle, which the tells logind, which then runs actions when swayidle is meant to run them directly. For button actions, it makes no sense to have logind waste resources by eavesdropping in all input devices when sway bindsyms can do the trick. For direct loginctl suspend calls, just start swaylock first.

After surfing and reading for a while, i think that i finally have the setup i want. And its nothing more than the example from the man pages of swayidle. Turn off the screen after 5 minutes. Suspend after 10. And lock the system before suspending either via timeout or lid close (still managed by elogind).

```
timeout 300 "brightnessctl -s set 0" resume "brightnessctl -r"
timeout 600 "loginctl suspend-then-hibernate"
before-sleep "swaylock -f"
```
