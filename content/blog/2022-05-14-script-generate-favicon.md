---
title: Script to generate favicons
date: 2022-05-14
issueId: 51
---

After reading [this awesome post](https://evilmartians.com/chronicles/how-to-favicon-in-2021-six-files-that-fit-most-needs) i decided to join all the command line things together in a single script so i can generate them easily without needing to copy paste every command separately and post them here so i can refer it in the future.

You need to have [Inkscape](https://inkscape.org/) and [NPM](https://www.npmjs.com/) installed. And the favicon has to be in a svg file with an square viewbox for better results.

```sh
#!/bin/env sh 

mkdir -p favicons
inkscape $1 --export-width=512 --export-filename="./favicons/android-chrome-512.png"
inkscape $1 --export-width=192 --export-filename="./favicons/android-chrome-192.png"
inkscape $1 --export-width=180 --export-filename="./favicons/apple-touch-icon.png"
inkscape $1 --export-width=32 --export-filename="./favicons/32.png"
inkscape $1 --export-width=16 --export-filename="./favicons/16.png"
convert "./favicons/16.png" "./favicons/32.png" "./favicons/favicon.ico"
rm "./favicons/32.png"
rm "./favicons/16.png"
npx svgo --multipass $1 -o "./favicons/favicon.svg"
```

Save it as `generate_favicons.sh`.

Make it executable `chmod +x generate_favicons.sh`.

And then run it passing your svg file `./generate_favicon.sh my_icon.svg`
