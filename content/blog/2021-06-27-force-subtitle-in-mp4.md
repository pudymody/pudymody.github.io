---
title: "Force subtitle in all videos inside a folder"
date: 2021-06-27
---

Lately i've found myself needing to force subtitles in video files so that my tv would display them more than i would like to admit. I always spent the same 5 minutes searching for the right combination of ffmpeg flags and windows cmd commands to do it over all the files in the folder. I always return to the same pages. Here is the snippet so i could find it without effort the next time. You need [FFmpeg](https://ffmpeg.org) and the subtitle and video files to have the same name.

To force subtitles you need to do:
```sh
ffmpeg -i subtitle.srt -i video.mkv -c:v copy -c:a copy -c:s srt -disposition:s:0 default -disposition:s:0 forced "video_forced.mkv"
```

To loop over all files in the folder
```sh
for %%i in (*.mkv) do echo %%~ni
```
*%%~ni* is to retrieve only the filename without extension

Now everything togeter:
```sh
for %%i in (*.mkv) do ffmpeg -i %%~ni.srt -i %%~ni.mkv -c:v copy -c:a copy -c:s srt -disposition:s:0 default -disposition:s:0 forced "converted/%%~ni.mkv"
```
