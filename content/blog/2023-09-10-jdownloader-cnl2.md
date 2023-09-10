---
title: "Jdownloader CNL2"
date: 2023-09-10
issueId: 115
---

The last few days i started surfing this side of the web again. To my surprise [Jdownloader](https://jdownloader.org/) is still a thing. As i dont want to install this for a few uses, here is the incantation you have to do to decrypt its CnL2 format.

```sh
echo "DATA" | openssl enc -aes-128-cbc -nosalt -d -iv "KEY" -K "KEY" -nopad -a
```

KEY is the result of calling the `jk` input value, DATA is the value of the `crypted` field.

Here is a {{< rawhtml >}}<a href="javascript:(function()%7B%5B...document.querySelectorAll(%60form%5Baction%3D%22http%3A%2F%2F127.0.0.1%3A9666%2Fflash%2Faddcrypted2%22%5D%60)%5D.forEach(function(%24form)%7B%20const%20form%20%3D%20new%20FormData(%24form)%3B%20const%20data%20%3D%20%5Beval(%60(function()%7B%24%7Bform.get(%22jk%22)%7D%20return%20f()%7D)()%60)%2C%20form.get(%22crypted%22)%5D%3B%20const%20cmd%20%3D%20%60echo%20%22%24%7Bdata%5B1%5D%7D%22%20%7C%20openssl%20enc%20-aes-128-cbc%20-nosalt%20-d%20-iv%20%22%24%7Bdata%5B0%5D%7D%22%20-K%20%22%24%7Bdata%5B0%5D%7D%22%20-nopad%20-a%60%3B%20%24pre%20%3D%20document.createElement(%22pre%22)%3B%20%24pre.innerHTML%20%3D%20cmd%3B%20%24form.parentNode.replaceChild(%24pre%2C%20%24form)%20%7D)%7D)()">bookmarklet</a>{{< /rawhtml >}} to replace the form with the command to run. Or the code if you want to run it yourself.

I tried using the [SubtleCrypto](https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto) API to decrypt entirely in the browser, but i couldnt figure out how. I even try asking ChatGPT.

```js
[...document.querySelectorAll(`form[action="http://127.0.0.1:9666/flash/addcrypted2"]`)].forEach(function($form){
    const form = new FormData($form);
    const data = [eval(`(function(){${form.get("jk")} return f()})()`), form.get("crypted")];
    const cmd = `echo "${data[1]}" | openssl enc -aes-128-cbc -nosalt -d -iv "${data[0]}" -K "${data[0]}" -nopad -a`;
    $pre = document.createElement("pre");
    $pre.innerHTML = cmd;
    $form.parentNode.replaceChild($pre, $form)
})
```
There are a [some](https://github.com/Brawl345/CNL-decryptor/blob/master/source/service-worker-functions.js) browser extensions that also do this. But thats too much hassle for a few times.
