---
title: "Building Dockerfiles based on old Debian"
date: 2025-07-31
issueId: 142
---

Today i was trying to build a dockerfile based on an old version of debian but it failed because when i tried to use apt to install some extra software all request returned 404s. In particular [php:7.1-apache](https://hub.docker.com/layers/library/php/7.1-apache/images/sha256-0d245ad6cfc41e9a5b8ba387f7ea83b913caf35a4ea5a3ba387c816871c68dc3) which is based on [buster](https://www.debian.org/releases/buster/).

This is something documented on the [debian wiki](https://www.debian.org/distrib/archive) whenever a version reaches EOL, but it took me a few minutes and i know that in the future it will bite me again. So a post it is.

The solution its to put this extra line in your Dockerfile according to your debian version before any apt command.

```
RUN echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list
```
