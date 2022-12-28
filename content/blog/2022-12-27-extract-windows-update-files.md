---
title: "Extract Windows Update files"
date: 2022-12-27
issueId: 98
---

The other day, a friend wanted to install some software, but she was getting some errors about missing *api-ms-win-crt-runtime-l1-1-0.dll* library file. I knew it was the [Universal C RunTime](https://support.microsoft.com/es-es/topic/actualizaci%C3%B3n-para-universal-c-runtime-en-windows-c0514201-7fe6-95a3-b0a5-287930f3560c) as i already had the same problem in the past.

The problem with this, is that you need admin rights to install it, something that she didnt have. At that time, i didnt think about extracting the files from the update itself, so we started looking for them somewhere else.

After reading an old forum post, we found out that [Mozilla Firefox](https://www.mozilla.org/es-AR/firefox/new/) bundles them. So we ended up downloading [a compressed version](https://ftp.mozilla.org/pub/firefox/nightly/latest-mozilla-central/) of Firefox, and copying the files from there.

Thank you Firefox for saving myself again.

This isnt the best solution, but you do the best you can with what you have in the moment. And the program was running fine, everyone was happy.

---

For the future, here is how you extract the files from different Windows Update containers which would have helped me a lot in that moment. *(extracted from [this Microsoft Community post](https://answers.microsoft.com/en-us/windows/forum/all/extracting-an-update/2f341403-1419-4153-8c4a-e088d6bfdd72))*

*(Destination folder must already exists)*

For ***.msu files**:

```expand -f:* {Update Name}.msu {Destination Folder}```

For **service pack**:

```{Service pack file} /x:{Destination Folder}```

From inside the *Destination folder*:

```expand -f:* {Update Name}.cab {Destination Folder}```
