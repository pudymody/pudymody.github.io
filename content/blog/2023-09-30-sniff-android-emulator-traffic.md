---
title: "How to sniff Android emulator traffic"
date: 2023-09-30
issueId: 117 
---

I found myself needing to sniff some android https traffic. My first attempt was to use [mitmproxy](https://mitmproxy.org/) on my own phone, but since Android 7 [apps ignore user provided certificates](https://android-developers.googleblog.com/2016/07/changes-to-trusted-certificate.html) and you cant change this without being root.

Then i tried to install an android emulator and do everything there. It wasnt a download and install experience, but it wasnt either too dificult. To prevent future googling, i will put the solution to different things for future me. Its mostly based on [this guide](https://community.neptune-software.com/topics/tips--tricks/blogs/how-to-install--android-emulator-without--android--st) and different stackoverflow ansers. This was under Kubuntu 22.04, so YMMV.

## Installing Tools

First we need to download the [command line tools only of Android studio](https://developer.android.com/studio) and extract them. I will put them under `~/bin/android-sdk/cmdline-tools`

```
com.android.sdklib.tool.sdkmanager.SdkManagerCli
        java.lang.UnsupportedClassVersionError: com/android/sdklib/tool/sdkmanager/SdkManagerCli has been compiled by a more recent version of the Java Runtime (class file version 61.0), this version of the Java Runtime only recognizes class file versions up to 55.0
```
Trying to run `./cmdline-tools/bin/sdkmanager --list` i found that i dont have the correct version of JRE. Lucky me, [someone asked the same thing but for Minecraft](https://askubuntu.com/a/1411892). Nothing that a `sudo apt install openjdk-17-jre-headless` couldnt solve.

```
Error: Could not determine SDK root.
Error: Either specify it explicitly with --sdk_root= or move this package into its expected location: <sdk>/cmdline-tools/latest/
```
As per [another stackoverflow answer](https://stackoverflow.com/a/71765298) and [this other filed issue](https://issuetracker.google.com/issues/154298380) the downloaded tools should be under `./cmdline-tools/latest/bin` and `./cmdline-tools/latest/lib`

Now running `./cmdline-tools/latest/bin/sdkmanager --list` will list all the available versions to download.

## Installing SDK
Now we need to install the android platform. To know which version, [APILevels](https://apilevels.com/) is a great resource. I needed android 10 without Google APIs and the version was x86_64. We also need platform tools for this level, so the following command is the one:
```
./cmdline-tools/latest/bin/sdkmanager --install "system-images;android-29;default;x86_64" "platform-tools" "platforms;android-29"
```

## Creating device
Now with everything installed, we only need to create our device
```
./cmdline-tools/latest/bin/avdmanager create avd --name android29 --package "system-images;android-29;default;x86_64"
```

And to start it
```
./emulator/emulator "@android29"
```

## Buttons not working
Hardware buttons like back, menu and power didnt work, but [stackoverflow ansers](https://stackoverflow.com/a/73106273) to the rescue again. We need to edit the `.android/avd/android29.avd/config.ini` and change `hw.keyboard=no` to `hw.keyboard=yes`

## Installing Certificates
Now we need to install our custom certificate to sniff traffic. First, we have to install [mitmproxy](https://mitmproxy.org/) in our host machine. This **IS** a download and run case. And the following is just the extracted commands from [their docs](https://docs.mitmproxy.org/stable/howto-install-system-trusted-ca-android/#instructions-for-api-level--28-using--writable-system) for me to copy and paste without reading why we have to do this.

We have to at least run the software once for it to generate our custom certificate.

Generate a custom hashed version
```
hashed_name=`openssl x509 -inform PEM -subject_hash_old -in mitmproxy-ca-cert.cer | head -1` && cp mitmproxy-ca-cert.cer $hashed_name.0
```

Start our avd with the writable flag
```
./emulator/emulator "@android29" -writable-system
```

Restart adb as root
```
./platform-tools/adb root
```

Disable secure boot verification
```
./platform-tools/adb shell avbctl disable-verification
```

Reboot device
```
./platform-tools/adb reboot
```

Restart adb as root
```
./platform-tools/adb root
```

Remount as read-write
```
./platform-tools/adb remount
```

Push new certificate
```
./platform-tools/adb push <path_to_hashed_certificate> /system/etc/security/cacerts
```

Set permissions
```
./platform-tools/adb shell chmod 664 /system/etc/security/cacerts/<name_of_pushed_certificate>
```

Reboot device
```
./platform-tools/adb reboot
```

Finally, we run mitmproxy, and configure our emulator wifi to use it as a proxy. **Always start emulator with the writable flag or our changes will be overwriten**
```
./emulator/emulator "@android29" -writable-system
```

## Installing Apps
As our device doesnt have a playstore because it doesnt use google apis, different services exists to download apks. With them, we only need to drag and drop them into the running emulator.
- [APKPure](https://apkpure.com)
- [APKMirror](https://www.apkmirror.com/)
