---
title: My first atom package
date: 2015-08-08
---
There was one thing that prevented me from making the change. When you autocomplete a snippet or an emmet expresion, and you type the final semicolon, it is inserted although it had been inserted by the snippet. Sublime handles this excelente moving the caret next to the char, but in atom it is inserted two times.

Sublime:
![Sublime demo](https://cloud.githubusercontent.com/assets/1085976/6180121/d675bfcc-b374-11e4-90fe-5e6522d5c20c.gif)

Atom:
![Atom demo](https://cloud.githubusercontent.com/assets/1085976/6180115/cae1fcd4-b374-11e4-9caf-de29a49f0288.gif)

So i being open source and with a large community, i couldnt stop from writing an extension to handle this thing, so [here](https://atom.io/packages/smart-tags) it is for everyone who also wants it
