---
title: "Batch download from Google Drive"
date: 2020-07-17
---

The other day a friend shared with me a link to a Google Drive folder with a lot of files. I wanted to download all of them, but i didnt want to use the native "Download folder" function, as it was a lot of GBs and also needed to start using the files as soon as i have them. Also, having a crappy internet connection means that i could lost all of the files because a single cut.

First i tried using *wget* and *curl* but i couldnt make it work. Luckily after some searching i found [gdown](https://pypi.org/project/gdown/), a python library for this. It could be used as a cli program with ```gdown FILE_LINK```. And also programatically from python.

This is how i used it. I made a little script to read urls from stdin and download them. Simple but useful.
```python
import sys
import gdown

for line in sys.stdin:
	gdown.download(line.rstrip())
```

Having all the urls in a file, to execute it you only need to do ```cat urlfiles.txt | python file.py```

To get the links of all the files in the folder, the following snippet worked for me. You need to run it in the DevTools console.

```js
copy(
	[...$0.querySelectorAll("[data-target='doc'][data-id]")]
	.map( e => e.dataset.id )
	.map( id => `https://drive.google.com/uc?id=${id}`)
	.join("\n")
)
```
