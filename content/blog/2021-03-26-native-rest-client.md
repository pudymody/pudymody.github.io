---
title: Native rest client
date: 2021-03-26
issueId: 44
---

This is an attempt to make a rest client using the Qt toolkit. There are already various great rest clients, but all of them fails in some way. This project tries to solve all of those issues.

They are OS-Specific: [Paw](https://paw.cloud/) (Mac only), [Nightingale](https://nightingale.rest/) (Windows only).

They are made with Electron, something i tend to consider as bloated: [Postman](https://www.postman.com/), [Insomnia](https://insomnia.rest/products/insomnia), [Advanced REST Client](https://chrome.google.com/webstore/detail/advanced-rest-client/hgmloofddffdnphfgcellkdfbfbjeloo?hl=en-US) (Technically not Electron, but you need Chrome to use it)

They are too developer focused like [httpie](https://httpie.io/) or you need a server to host them like [hoppscotch](https://github.com/hoppscotch/hoppscotch) (if you can live hosting i think this is one of the best)

**Why Python and Qt and not X Language and Y Toolkit?**

Python is already a great crossplatform language present in almost every unix distro, and the kind of software im building doesnt need super x10 performance. And i think Qt has a great documentation and apis to develop and prototype. In the end is just personal preference, i doesnt mean that it could not change in the future if needed.

The [source code](https://github.com/pudymody/rest-client-qt) is on github. There you could find instructions on how to build it, some screenshots, and everything else.