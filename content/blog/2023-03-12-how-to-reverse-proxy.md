---
title: "How to reverse proxy"
date: 2023-03-12
issueId: 102 
---

Today i was fighting this problem for a few hours because i didnt know how reverse proxing truly works at its core. So this posts is a *notes to myself* because i know in the future i will step on the same stone.

I had two containers, one running [FreshRSS](https://freshrss.org/) and the other [Caddy](https://caddyserver.com/) as a reverse proxy. Both were working on its own, they could communicate, but whenever i tried entering the url, it returned 404.

This was my initial Caddyfile
```
domain {
	reverse_proxy /fresh/* container_ip
}
```

First i tried looking for Caddy logs, but it didnt show anything, so the problem must be on the FreshRSS side i thought. Looking at its logs, i saw that it was requesting the /freshrss/ path, and not the /.

Looking through forums i came to this [post](https://caddy.community/t/reverse-proxy-404-issue/6789/2) that clarify everything. The main part was this:
> When Caddy proxies to a backend, it naturally forwards the entire requested URI along with it.

It makes absolute sense, but being used to router libs, i thought that it stripped the /freshrss part. To do that, it suggested to use the *without* modifier, but it was v1 only. After hopping through different github issues: [1](https://github.com/caddyserver/caddy/issues/2813) and [2](https://github.com/caddyserver/caddy/issues/3266), i arrived to the final and correct directive *[handle_path](https://caddyserver.com/docs/caddyfile/directives/handle_path)*, which does exactly what i thought it was doing at the begining.

Now my final Caddyfile looks like this:
```
domain {
	redir /fresh /fresh/
	handle /fresh/* {
		reverse_proxy container_ip {
			header_up X-Forwarded-Prefix /fresh
		}
	}
}
```

What can i learn from this? That Caddy is simple and beautiful to use, at least for now. And if you want to do something, maybe reading its docs, understanding what you are doing and how it works underneath is essential.
