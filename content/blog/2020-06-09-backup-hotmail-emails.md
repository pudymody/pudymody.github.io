---
title: "Backup your hotmail account (with attachments)"
date: 2020-06-09
---

*(Yes, i put hotmail on purpouse because thats the way i first searched for it, and because searching for outlook give me answers for the software and not the email service)*

## Intro
In another attempt to regain control over my online identity, i decided to start deleting my unused accounts or at least obfuscating its data from services that doesnt allow me to delete them. Its incredible how a PITA its this task. Even having a list of a lot of sites im in. I think thats because most of the accounts are from forgotten sites where i registered just to read some forum post and they didnt keep in touch with current trends. There are others that even contacting support they tell me that *"we dont delete accounts"*, WHAT THE HELL?? Im not allowed to delete my own account? What kind of dystopia is this?. Luckily there are some that have updated their sites and could delete them from the user panel, or contacting their support was enough.

One of this accounts was my hotmail email, yes, hotmail, i made it long before the service was called outlook. There between all the spam accumulating this years, there was lot of great old memories from family, friends, or even teachers. Seeing this i wanted to download all this data to preserve them, but it was a surprise to me that Outlook dont allow you to do this, like google does with its [Takeout feature](https://takeout.google.com/settings/takeout). This is the way i made it, although its an easy task for some users, i hope it can help others who dont know how.

## Setup
The first step its to download and install [Thunderbird](https://www.thunderbird.net/en-US/), a multiplatform email client previously from Mozilla but now managed by its community. I was a little nervous because in the past it was tricky for me to setup my accounts. I dont know if it was because i didnt know too much at the moment or because of the software. This time i only needed to fill my email and password and everything was working. No need to setup IMAP, POP3 or SMTP servers.

The first time you open it, you will see this dialog where you can put your email data. After accepting, the same dialog will show you the available methods with its settings for retrieving emails. For this task IMAP worked just fine.

![Dialog to setup your account](/static/imgs/backup-hotmail-emails/account-setup.jpg)
![Dialog to setup your accounts servers](/static/imgs/backup-hotmail-emails/account-setup-servers.jpg)

Now you have Thunderbird configured with your outlook email. From here you can read your emails and answer them, the main task for what this app was made. Now its time to export all your emails. To do this, you need to install the following addon: **ImportExportTools NG**.

*If you know how to install addons you can skip to the following section.*

First click on the "hamburger menu" on the top right and go to the addons menu item. From there click the addons button again. If you find it in the *Featured addons* list, click it and hit *Add to thunderbird*. If you dont find it, you can click on the *Extensions* button on the sidebar on the left, and from there search it. After installing it, it will ask to restart Thunderbird, do it.

![Main menu](/static/imgs/backup-hotmail-emails/addons-menu.jpg)

![Addons button](/static/imgs/backup-hotmail-emails/addons-menu-2.jpg)

![Install addon](/static/imgs/backup-hotmail-emails/install-addon.jpg)

## Exporting
Now is just a matter of going folder by folder exporting them. I say this because when i tried to export everything, some werent exported, and i needed to do it one by one. This is done by right clicking on the folder -> ImportExportTools NG -> Export all messages in this folder -> HTML format (with attachments). I choose HTML format because i wanted them in a readable format, but you could choose the one you like. The important thing for me was the *(with attachments)* option, because that way it also exports received files.

![Export menu](/static/imgs/backup-hotmail-emails/export.jpg)


And that's everything you need to do to export your outlook emails. Now I can continue fighting services to delete my account.
