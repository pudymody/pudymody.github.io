---
title: "Server setup"
date: 2025-02-28
issueId: 137
---

This is cheatsheet from a [few](https://www.youtube.com/watch?v=F-9KWQByeU0) [different](https://becomesovran.com/blog/server-setup-basics.html) [resources](https://x.com/kkyrio/status/1846139949512372243) on how to setup a new VPS. Im collecting them here so i can refer it in the future and not lose them. Along with a few tips on how i deploy apps.

## Create a new user
Using the root user its not a good idea. Create a new one and add them to the `sudo` group.

```sh
adduser pudymody 
usermod -aG sudo pudymody
```

## Harden SSH
First of all copy your ssh key and test that you can login
```sh
ssh-copy-id -p port pudymody@server_ip
ssh -p port pudymody@server_ip
```

Add/change the following settings from `/etc/ssh/sshd_config`
```
Port 2222     # Change default port (use a number between 1024 and 65535)
PermitRootLogin no                 # Disable root login
PasswordAuthentication no          # Disable password authentication
PubkeyAuthentication yes           # Enable public key authentication
AuthorizedKeysFile .ssh/authorized_keys # Specify authorized_keys file location
AllowUsers pudymody                 # Only allow specific users to login
UsePAM no
Protocol 2                 # Use only SSH protocol version 2
MaxAuthTries 3             # Limit authentication attempts
ClientAliveInterval 300    # Client alive interval in seconds
ClientAliveCountMax 2      # Maximum client alive count
```

Restart SSH with `sudo service ssh restart`

## Network safety 
Install ufw and allow only http(s) and SSH traffic

```
apt install ufw

ufw default deny incoming
ufw default allow outgoing
ufw allow 80
ufw allow 443
ufw allow 2222 (or your configured ssh port)

ufw enable
```

Install and configure fail2ban
```
apt install fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

Add/Uncomment the following from `jail.local`
```
[sshd]
enabled = true
mode = aggresive
```

## Containerization

I use [podman](https://podman.io/).

```apt install podman```.

I had a problem and had to run what podman suggested.

```loginctl enable-linger 1000```

My installation used an old version of podman, so i have to create a new network to enable the dns plugin. Edit the ```/home/pudymody/.config/cni/net.d/net.conflist``` file to use "0.4.0" cniVersion because another bug. 

```
podman network create net
/home/pudymody/.config/cni/net.d/net.conflist
```

Most of my apps are run with the following command
```
podman create --log-driver="k8s-file" --log-opt=path=/var/logs/service.log --network net --name serviceName imageName 
```

## Reverse proxy
For reverse proxying, i use [Caddy](https://caddyserver.com/), but i had to allow port 80 for everyone. Not good, but dont want to fight firewall rules.

```sh
sudo sysctl net.ipv4.ip_unprivileged_port_start=80
```

## Future improvements
The only thing missing is running the containers as a systemd resource to start them whenever the server goes down. But as this currently only host my apps, i can deal with this.
Maybe some kind of CI/CD? I currently build the images locally, push them to the server, and then run the previous command.
