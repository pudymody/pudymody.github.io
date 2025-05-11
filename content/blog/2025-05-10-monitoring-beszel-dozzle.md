---
title: "Monitoring my server with Beszel and Dozzle"
date: 2025-05-10
issueId: 139
---

This is a follow up of my previous post [Server setup](/blog/2025-02-28-server-setup/). I finally took the time to setup some basic monitoring and autostart of the containers.

## Systemd unit
Lets begin setting up some systemd unit files for every container so they autostart whenever the server boots or they shutdown. Im using an old version of Podman (v3.4.4) so i cant use [Quadlets](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) yet.

Lucky me, podman makes this as simple as running the following commands

```sh
podman generate systemd --files --name container_name 
cp container_name.service ~/.config/systemd/user/
systemctl --user enable container_name.service
```

You also have to enable lingering for your current user 

```sh
loginctl enable-linger pudymody
```

## Server stats with Beszel

I was about to use something like [Grafana](https://grafana.com/)+[Prometheus](https://prometheus.io/)+[prometheus_podman_exporter](https://github.com/containers/prometheus-podman-exporter) but then i found [Beszel](https://beszel.dev/guide/what-is-beszel) on reddit and it clicked inmediatly. It only reported simple stats with a beautiful dashboard and is light on resources. The kind of thing i wanted.

One thing i liked, its that the docker graph its relative to the CPU usage, [as said in this comment](https://github.com/henrygd/beszel/discussions/610#discussioncomment-12293924)

And the setup is pretty straightforward, im still surprised how easy it was. This is mostly a copy and paste of the official documentation adapted to podman.

The first thing is to [enable the podman socket service](https://github.com/containers/podman/blob/main/docs/tutorials/socket_activation.md)
```sh
systemctl --user enable podman.socket
systemctl --user start podman.socket
```

To start the hub
```sh
podman create -v beszel_data:/beszel_data -v beszel_socket:/beszel_socket --name beszel_hub --env "APP_URL=https://main-domain/beszel" docker.io/henrygd/beszel
```

To start the collector using the key obtained while adding your first system
```sh
podman create -v /run/user/1000/podman/podman.sock:/var/run/docker.sock:ro -v beszel_socket:/beszel_socket --env "LISTEN=/beszel_socket/beszel.sock" --env "KEY=MY_KEY" --name beszel_agent docker.io/henrygd/beszel-agent
```

And finally, configure caddy to reverse proxy
```sh
handle_path /beszel* {
	reverse_proxy beszel_hub:8090 {
		transport http {
			read_timeout 360s
		}
	}
}
```

## Podman logs with Dozzle
To view logs, im using another lightweight app in the same vein of Beszel, [Dozzle](https://dozzle.dev/guide/getting-started). As before, the setup is very easy and will mostly be a copy from the offical guide.

You generate a user for dozzle
```sh
mkdir data
podman run -it --rm amir20/dozzle generate admin --password password > data/users.yml
```

Create pod for dozzle
```sh
podman create -v /run/user/1000/podman/podman.sock:/var/run/docker.sock:ro -v ./data:/data --name dozzle --env "DOZZLE_BASE=/dozzle" --env "DOZZLE_NO_ANALYTICS=1"  amir20/dozzle --auth-provider simple
```

Sadly, my podman setup was a little broken, so i have to change some settings [as this github issue](https://github.com/containers/podman/issues/10987#issuecomment-973930603)

```sh
cp /usr/share/containers/containers.conf ~/.config/containers/containers.conf
```

Change the following line
```
#events_logger = "journald"
events_logger = "file"
```

And finally the configs for caddy
```
handle /dozzle* {
	reverse_proxy dozzle:8080
}
```

## Outro
Now the only thing missing is some kind of CI/CD for deploys. Maybe also some [Watchtower](https://containrrr.dev/watchtower/)?. We'll see in the future what its the best option and what i like.
