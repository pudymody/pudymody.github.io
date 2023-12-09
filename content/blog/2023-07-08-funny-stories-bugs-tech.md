---
title: "Funny stories and bugs in tech"
date: 2023-07-08
issueId: 110
---

This is a collection of stories and bugs in the tech world that i found funny. They are mostly all from my [bookmarks](/bookmarks) pages, but the other day i tried to find them here, so why not put theme also?

## Only crash leaving it on over night!?!

A game that only crash when QA leaves it over night? From [this twitter thread](https://twitter.com/mmalex/status/1066111290580582403) (Quoted here for archival purposes)

> I feel your pain! We had a ‘fun’ one on LittleBigPlanet 1: 2 weeks to gold, a Japanese QA tester started reliably crashing the game by leaving it on over night. We could not repro. Like you, days of confirmation of identical environment, os, hardware, etc; each attempt took /

> Over 24h, plus time differences, and still no repro. Eventually we realised they had an eye toy plugged in, and set to record audio (that took 2 days of iterating) still no joy. Finally we noticed the crash was always around 4am. Why? What happened only in Japan at 4am? We begged

> To find out. Eventually the answer came: cleaners arrived. They were more thorough than our cleaners! One hour of vacuuming near the eye toy- white noise- caused the in game chat audio compression to leak a few bytes of memory (only with white noise). Long enough? Crash.

> Our final repro: radios tuned to noise, turned up, and we could reliably crash the game. Fix took 5 minutes after that. Oh, gamedev....

---

## I cannot print on tuesdays!?!

From [this bug report](https://bugs.launchpad.net/ubuntu/+source/cupsys/+bug/255161/comments/28) it seems that ubuntu wont let you print on tuesdays

> What a fascinating bug!! My wife has complained that open office will never print on Tuesdays!?! Then she demonstrated it. Sure enough, won't print on Tuesday. Other applications print. I think this is the same bug. Here is my guess:

---

## Using Memory Errors to Attack a Virtual Machine
This isnt a bug, but the mere idea of someone pointing a lamp to a memory computer to corrupt it and gain access to execute unauthorized code is bizarre and beautiful at the same time to me. [Here is the paper](https://www.cs.princeton.edu/~appel/papers/memerr.pdf)

---

## The case of the 500-mile email
If not being able to print on tuesdays was funny to you, imagine these people debugging why [they couldnt send an email to distances longer than 500-miles.](https://www.ibiblio.org/harris/500milemail.html)

---

## 1983 Soviet nuclear false alarm incident
When an [error in a radar](https://en.wikipedia.org/wiki/1983_Soviet_nuclear_false_alarm_incident) almost made us live a nuclear war, but someone prevented it by saying:

> Petrov cited his belief and training that any U.S. first strike would be massive, so five missiles seemed an illogical start.

---

## ARIANE 5
How an overflow error made the [launch of the ARIANE 5 a failure](https://www-users.cse.umn.edu/~arnold/disasters/ariane5rep.html)

---

## Bit Flip
How cosmic rays almost made an election in Belgium useless by flipping a single bit. [Here the full chapter](https://radiolab.org/podcast/bit-flip)

---

## One in five genetics papers contains errors thanks to Microsoft Excel
Excel trying to be smart about month names, made [one in five genetics papers contains errors](https://www.science.org/content/article/one-five-genetics-papers-contains-errors-thanks-microsoft-excel)

---

## How did MS-DOS decide that two seconds was the amount of time to keep the floppy disk cache valid?
Sometimes user testing is the best way to get some magic numbers.

> Mark Zbikowski led the MS-DOS 2.0 project, and he sat down with a stopwatch while Aaron Reynolds and Chris Peters tried to swap floppy disks on an IBM PC as fast as they could.

> They couldn’t do it under two seconds.

[Here the full article](https://devblogs.microsoft.com/oldnewthing/20190924-00/?p=102915)

---

## Light Commands
Hack into anyone's Alexa's microphone by shinning light. [Here the full article](https://lightcommands.com/)

---

## Side-Channel Attack Turns Power Supply Into Speakers
Nothing is invulnerable when [you could turn your powersupply into a speaker](https://hackaday.com/2020/05/11/side-channel-attack-turns-power-supply-into-speakers/)

---

## Illegal numbers
As computer information could be represented by numbers, laws decided that [some number are illegal](https://en.wikipedia.org/wiki/Illegal_number#Illegal_primes). Beautiful distopian world we live on.

---

## MSN TV
As i said [in my previous post](blog/2023-03-23-devices-for-internet/) this set-top-box [was classified as a weapon](https://en.wikipedia.org/wiki/MSN_TV#WebTV_briefly_classified_as_a_weapon) for a little moment.

---

## Screaming memory
As technology advances, its easy to laugh at first attempts, but this idea of a ["screaming memory"](https://www.youtube.com/watch?v=TQCr9RV7twk&t=115s) always makes me laugh.

---

## TV interfering internet connection
You turn your TV on, and suddenly all the village lost its internet access. [What could be happening?](https://hackaday.com/2020/09/22/second-hand-television-shines-takes-down-entire-villages-internet/)

---
## Root certificates
When someone tried to add their own root certificates. [Add Honest Achmed’s root certificate](https://bugzilla.mozilla.org/show_bug.cgi?id=647959), [Add my root CA cert to mozilla’s trusted root CA cert list](https://bugzilla.mozilla.org/show_bug.cgi?id=233458)

> Resolved invalid? What’s the difference between Honest Achmed and the other CAs? Just an audit report? The community should chip in!

---
## Cars stopping because updates
> Another event occurred in 2019 when a [Chinese NIO electric automobile](https://www.theverge.com/2019/1/31/18205774/nio-ota-update-traffic-china-es8) stopped in traffic and imprisoned its occupant for over an hour after it was disabled by an over-the-air software update. At least one [Lucid Air EV](https://www.teslarati.com/lucid-air-bricked-after-failed-ota-update) was also disabled the same way in 2022.

---
## Testing software in production in a hospital
> I've been told the worst thing that can happen to a developer is their code crashes in production? Well.... what happens if that production environment is in a hospital? This video tells the story of one of the Therac-25 incidents, and how Ray Cox ultimately died because of a programming error in a safety critical system.

This isnt funny at all, but another example of how important and delicate is to put software in things that are critical to human beings

[how a simple bug in software ended 6 lives](https://www.youtube.com/watch?v=41Gv-zzICIQ)

---
## Sometimes hardware bugs exists
[Rust std fs slower than Python!? No, it's hardware!](https://xuanwo.io/2023/04-rust-std-fs-slower-than-python/) by [Xuanwo](https://xuanwo.io/) its an interesting deep dive into some AMD hardware bugs.
