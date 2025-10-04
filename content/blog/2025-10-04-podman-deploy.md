---
title: "podman-deploy"
date: 2025-10-04
issueId: 144
---

There is time to solve another thing in my journey of self hosting things. Whenever i want to deploy a new app i have to run the same commands and im getting tired. I want something like [Kamal](https://kamal-deploy.org/) or [Dokploy](https://dokploy.com/). I want to run some command and have everything done. Thats why i wrote the following scripts tuned to my own use case, podman + caddy.

# Auto starting apps
Podman has service called [podman-restart](https://github.com/containers/podman/blob/main/contrib/systemd/system/podman-restart.service.in) that will start all containers that where created with `--restart=always` which isnt enabled by default at least on debian. So i only have to enable it with `systemctl --user enable podman-restart.service`

# Structure
I have the following structure for caddy.

A main `Caddyfile` that sets some global configs for each domain and an import for its index page and subapps. Socket activation so that apps can get the real user ip and not the one from the caddy pod.

```
{
	servers {
		trusted_proxies static 10.0.0.0/8
	}
}
domain {
	log {
		output discard
	}
	bind fd/3 {
		protocols h1
	}
	bind fd/4 {
		protocols h1 h2
	}
	bind fdgram/5 {
		protocols h3
	}

	import sites-enabled/domain.caddy
}
```

To enable socket activation, you also have to create a `container-caddy.socket` systemctl file with the following content
```
[Socket]
ListenStream=[::]:80
ListenStream=[::]:443
ListenDatagram=[::]:443
BindIPv6Only=both

[Install]
WantedBy=sockets.target
```



Then in my `sites-enabled/domain.caddy` file
```
import domain/freshrss/freshrss.caddy
import domain/app/app.caddy

import domain/index.caddy
```

On `sites-enabled/domain/index.caddy` the configuration for my index page, and on each `sites-enabled/domain/app/app.caddy`

```
@appname path /appname /appname/*
route @appname {
        forward_auth authelia:9091 {
                uri /api/authz/forward-auth
                copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
        }
        uri strip_prefix /appname
	reverse_proxy appname:8080
}
```

I also have a `sites-enabled/domain/app/log` folder for each pod logs, and a `sites-enabled/domain/app/deploy.toml` file with deploy configs
```
healthcheck_url = "http://127.0.0.1:8080"
healthcheck_interval = 5
max_healthchecks = 5

entrypoint = ["/usr/bin/app", "arg1"]

volumes = ["app_data:/data"]

[env]
HTTP_ROOT_PATH="/app"
```

healthcheck_url and the likes are used to do zero downtime deploys. It will spin up the container, whenever this url returns a 200 the new pod is added to the network and the old one is brought down. The other fields i think are self explainatory.

# Creating apps
If you think the previous structure its a lot to create manually whenever you want to create a new app, you are correct, thats why i created the following script for that. I dont tend to write python so maybe there are a few things that arent the *python way*, but it works for now. You run it like `podman-app-create domain/appname`

```python
#!/usr/bin/python3
import sys
from os import path
import os
import subprocess
import settings

def create_app(domain, app):
    domain_path = path.join(settings.ROOT, "sites-enabled", domain)
    domain_caddy_file_path = path.join(settings.ROOT, "sites-enabled", f"{domain}.caddy")
    app_path = path.join(domain_path, app)
    log_path = path.join(app_path, "log")

    if not path.exists(domain_path):
        print(f"Domain '{domain}' does not exists")
        return

    if path.exists(app_path):
        print(f"App '{app}' already exists under domain '{domain}'" )
        return

    os.makedirs(app_path, exist_ok=True)
    os.makedirs(log_path, exist_ok=True)

    deploy_file_path = path.join(app_path, f"deploy.toml" )
    deploy_file = open(deploy_file_path, "w")
    deploy_file.write(f"""healthcheck_url = "http://127.0.0.1/up"
healthcheck_interval = 5
max_healthchecks = 5

entrypoint = []

volumes = []

[env]
""")
    deploy_file.close()

    app_caddy_file_path = path.join(app_path, f"{app}.caddy" )
    app_caddy_file = open(app_caddy_file_path, "w")
    app_caddy_file.write(f"""@{app} path /{app} /{app}/*
route @{app} {{
	forward_auth authelia:9091 {{
		uri /api/authz/forward-auth
		copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
	}}
	uri strip_prefix /{app}
	reverse_proxy {app}:8080
}}""")
    app_caddy_file.close()

    original_data = ""
    original_file = open(domain_caddy_file_path, 'r')
    original_data = original_file.read()
    original_file.close()

    modified_file = open(domain_caddy_file_path, 'w')
    modified_file.write(f"import {domain}/{app}/{app}.caddy\n{original_data}")
    modified_file.close()

    subprocess.run(["podman", "exec", "-w", "/etc/caddy", "caddy", "caddy", "reload"])

def main():
    if len(sys.argv) < 2:
        print("Correct syntaxis is podman-create-app domain/app-name")
        return

    args = [x.strip() for x in sys.argv[1].split("/")]
    if len(args) != 2 or args[0] == "" or args[1] == "":
        print("Correct syntaxis is podman-create-app domain/app-name")
        return

    create_app(args[0], args[1])

if __name__ == "__main__":
    main()
```

# Deploying apps
And whenever you want to deploy an app without downtime you can run the following one `podman-app-deploy domain/appname image-identifier`

```python
#!/usr/bin/python3
import sys
import os
import subprocess
import random
import string
import time
import tomllib
import json

from os import path
import settings as global_settings

def parse_settings(domain, app):
    settings = {
        'container_name': '',
        'log_file': '',
        'env': {},
        'app_path': '',
        'healthcheck_url': 'http://127.0.0.1/up',
        'volumes': [],
        'entrypoint': [],
        'healthcheck_interval': 5,
        'max_healthchecks': 5,
    }

    domain_path = path.join(global_settings.ROOT, "sites-enabled", domain)
    settings['app_path'] = path.join(domain_path, app)
    log_path = path.join(settings['app_path'], "log")

    if not path.exists(domain_path):
        raise Exception(f"Domain '{domain}' does not exists")

    if not path.exists(settings['app_path']):
        raise Exception(f"App '{app}' does not exists under domain '{domain}'" )

    deploy_settings_path = path.join(settings['app_path'], "deploy.toml")
    with open(deploy_settings_path, "rb") as f:
        deploy_settings = tomllib.load(f)
        settings['healthcheck_url'] = deploy_settings['healthcheck_url']
        settings['healthcheck_interval'] = deploy_settings['healthcheck_interval']
        settings['max_healthchecks'] = deploy_settings['max_healthchecks']

        if len(deploy_settings['entrypoint']) > 0:
            settings['entrypoint'] = json.dumps(deploy_settings['entrypoint'])

        settings['env'] = deploy_settings['env']
        settings['volumes'] = deploy_settings['volumes']

    random_string = ''.join(random.choices(string.ascii_lowercase + string.digits, k=6))
    settings['container_name'] = f"{app}-{random_string}"

    settings['log_file'] = path.join(log_path, settings['container_name']) 
    
    return settings

def create_container(settings):
    create_args = [
            "podman",
            "run", "-d",
            "--network", "podman",
            "--log-opt", f"path={settings['log_file']}",
            "--name", settings['container_name'],
            "--restart", "always"]
    for v in settings['volumes']:
        create_args.append("-v")
        create_args.append(v)
    for key,value in settings['env'].items():
        create_args.append("-e")
        create_args.append(f"{key}={value}")
    if len(settings['entrypoint']) > 0:
        create_args.append("--entrypoint")
        create_args.append(settings['entrypoint'])

    create_args.append(settings['image'])
    subprocess.run(create_args, stdout = subprocess.DEVNULL, cwd=settings['app_path'])

    pid = subprocess.run(["podman", "inspect", settings['container_name'], "-f", '{{.State.Pid}}'], capture_output=True)
    if pid.returncode != 0:
        raise Exception(f"Could not get pid of new container {pid.stderr}")
        return

    print(f"Waiting for container to be online...")
    is_up = False
    attempt = 0
    while not is_up and attempt < settings['max_healthchecks']:
        print(f"Waiting {settings['healthcheck_interval']} seconds")
        time.sleep(settings['healthcheck_interval'])
        print(f"Attempt {attempt + 1} to {settings['healthcheck_url']}")
        status = subprocess.run(["nsenter", "-t", pid.stdout.strip(), "-U", "-n", "curl", settings['healthcheck_url'], "-s", "-o", "/dev/null", "-w", "%{http_code}"], capture_output=True)
        is_up = status.returncode == 0 and (status.stdout == b"200" or status.stdout == b"404")
        attempt += 1

    if attempt == settings['max_healthchecks']:
        print(f"Container is created but not connected to the network")
        print(f"When ready run `podman network connect --alias {settings['app']} {global_settings.MAIN_NETWORK} {settings['container_name']}` to connect it")
        print(f"Current pods still alive")
        raise Exception(f"Failed to check health after {attempt} attempts")
    else:
        subprocess.run(["podman", "network", "connect", "--alias", settings['app'], global_settings.MAIN_NETWORK, settings['container_name']])

def remove_old_containers(settings):
    old_ids = subprocess.run(["podman", "ps", "--no-trunc", "--filter", "status=running", "--filter", f"name={settings['app']}-.*", "--format", "{{.Names}}"], capture_output=True, text=True)
    if old_ids.returncode != 0:
        raise Exception(f"Could not get ids of old containers {old_ids.stderr}")
        return

    for old_name in [str(name.strip()) for name in old_ids.stdout.splitlines()]:
        if old_name != settings['container_name']:
            subprocess.run(["podman", "stop", old_name], stdout = subprocess.DEVNULL, stderr = subprocess.DEVNULL)
            print(f"Removed old container '{old_name}'")

def deploy_app(domain, app, image):
    try:
        settings = parse_settings(domain,app)
        settings['image'] = image
        settings['app'] = app

        print(f"Creating container for '{domain}/{app}")
        create_container(settings)

        print(f"Removing old containers...")
        remove_old_containers(settings)
    except Exception as e:
        print(e)
        return

def main():
    if len(sys.argv) < 3:
        print("Correct syntaxis is podman-deploy-app domain/app-name image-identifier")
        return

    args = [x.strip() for x in sys.argv[1].split("/")]
    if len(args) != 2 or args[0] == "" or args[1] == "":
        print("Correct syntaxis is podman-deploy-app domain/app-name image-identifier")
        return


    deploy_app(args[0], args[1], sys.argv[2].strip())

if __name__ == "__main__":
    main()
```

# Outro
Now i have what i think its a good secure server, with reverse proxy and zero downtime deploys with autostart. The only thing missing its some kind of ci to deploy/build whenever i push to the repository, but i think this could be implemented easily with git hooks. For now, time to do another thing.
