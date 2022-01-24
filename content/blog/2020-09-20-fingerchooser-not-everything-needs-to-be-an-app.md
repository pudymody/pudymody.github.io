---
title: "FingerChooser: Not everything needs to be an app"
date: 2020-09-20
issueId: 40
---

Yes, i know the title is a little clickbait. Im not going to talk about how a super complex app could be made as a website, but a little one.

Some time ago, a friend showed me the [Chwazi Finger chooser](https://play.google.com/store/apps/details?id=com.tendadigital.chwaziApp&hl=es_AR) which is a little android app to select someone from a group or to divide them. Our primary use was to select from our group of friends who will buy the beers. The use is simple, when the app is ready, everyone puts its finger on the screen and after some time one will be selected. Simple but useful.

After some time using it the idea came to my mind *Why did i had to download this?*. Its simple enough to be some modern web app. Heck, today you can even [compress images and convert them between different formats](https://squoosh.app/) why do i have to download and android app to select from a group of touches when this api has been available for a while.

Thats when i tried to replicate it using only plain html, css and vanilla js. My first try was to use something based on canvas, but then i remembered that svg exists and it seemed the correct tool to draw basic shapes with effects. *As i only used the option to select one touch from a group, thats the only way i made, but i believe it couldnt be any harder to add the other ones*. Add some serviceworker and you have everything in less than 5kb instead of the 1mb of the app. Yes, the app is lightweight as hell also, but i believe this shows how not everything needs to be an app. You also can use it in whatever device with touch support you could make a JS complaint browser run.

**Stop talking, take me to the app** [FingerChooser](https://pudymody.github.io/FingerChooser/)
