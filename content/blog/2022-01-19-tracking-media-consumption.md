---
title: Tracking media consumption
date: 2022-01-19
issueId: 45
---

I have been using [Trakt.tv](https://trakt.tv/) since 2016, thats almost 6 years of media consumption records. Every movie, serie, chapter i watched gets recorded there. I finally decided to use some selfhosted version of this.

At first i wanted to use [Flox](https://github.com/devfake/flox) which is almost what i want. But there was two things that i didnt like. One was an [ux preference of mine](https://github.com/devfake/flox/issues/185), and the other is something that i dont like in almost all things self hosted. You need another account to use it. That wouldnt be a problem if it was something that i would share with friends or family, but i was the only user to use this.

So i made [another tracking movie software](https://github.com/pudymody/tvtracker). Its made in NodeJS, with SQLite and you need a [TMDB api key](https://themoviedb.org/). Nothing super complicated or fancy.

One interesting thing i found before publishing it, is [BFG repo cleaner](https://rtyley.github.io/bfg-repo-cleaner/), a tool to remove sensible keys from your git repository. I needed to remove my keys before opening it. [This is the tutorial](https://fabianlee.org/2019/03/24/git-bfg-for-removing-secrets-from-entire-git-history/) i followed.