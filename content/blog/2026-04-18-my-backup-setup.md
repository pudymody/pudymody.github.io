---
title: "My Backup Setup"
date: 2026-04-18
issueId: 148
---

Its amazing how when things works smoothly and without any friction i ask myself "its that really all?". Im used to tech being so broken and hard to interoperate.  But thats not the case with [syncthing](https://syncthing.net/), [krokiet AKA czkawka](https://github.com/qarmin/czkawka), [rclone](https://rclone.org/), [borg](https://www.borgbackup.org/) and [vorta](https://vorta.borgbase.com/).

I also found out how when things works smoothly and without friction its hard to say something about them. Long posts and rants tends to be to failing things, not to working ones. Working ones tends to be invisible.

This seems to be the current state of the world also.

I've been using borg and vorta for a while for my backups and the process is soo smooth. Yesterday i thought *there should be an easier way to backup my phone*. Thats where i tried syncthing and the setup was also butter smooth. Install on pc, install on [android](https://github.com/researchxxl/syncthing-android) (obviously from Fdroid), follow the setup and there it was, my phone syncthign to my pc without any hassle. Just wait for files to sync.

Then i sort my photos into different folders to have a better organization, delete the ones that are noise like screenshots, tickets and the like. Run krokiet to find if i still have duplicates and copy the surviving ones to my images folder.

Run vorta to an external hdd and then rclone to upload them to gdrive. Will see in the future if this is right or if there is something im missing.
