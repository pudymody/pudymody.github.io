---
title: "Caddy WebDAV"
date: 2025-10-21
issueId: 145
---

I finally migrated to [Radicale](https://radicale.org/v3.html) for my CalDAV and CardDAV. What i was missing was some kind of WebDAV to backup some of my android apps data.

[Caddy](https://caddyserver.com/) doesnt have an official webdav plugin, but there is one called [caddy-webdav](https://github.com/mholt/caddy-webdav) made by the creator itself. This guide its a template on how to enable the plugin under some path and also have an index browser for them.

First you have to install the plugin. I used the following commands but the ideal its to use the xcaddy cli or make a custom Docker image.

```
caddy add-package github.com/mholt/caddy-webdav
```

For the configuration you can use the following snippet. This will serve the index and webdav endpoints under `/webdav` with a basic auth, use the `/data/webdav` folder for storage, and setup an `admin` account with `demo` password that you can generate with `caddy hash-password`:
```
@webdav {
        path /webdav /webdav/*
        not method GET HEAD
}
@webdav-index {
        path /webdav /webdav/*
        method GET HEAD
}
route @webdav  {
        root * /data/webdav
        basic_auth {
                admin $2a$14$IemJ3FxaGzD9XDVpgLCld.3eO5UlrAKfk5LGUdM9nkLG6ItbIOPcy
        }

        webdav {
                prefix /webdav
        }
}
route @webdav-index {
        basic_auth {
                admin $2a$14$IemJ3FxaGzD9XDVpgLCld.3eO5UlrAKfk5LGUdM9nkLG6ItbIOPcy
        }
        root * /data/webdav
        uri strip_prefix /webdav
        file_server browse
}
```
