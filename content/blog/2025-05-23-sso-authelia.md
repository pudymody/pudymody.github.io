---
title: "Enabling SSO with Authelia"
date: 2025-05-23
issueId: 140
---

## Intro
Following [my previous post](/blog/2025-05-10-monitoring-beszel-dozzle/) and my journey in setting up my own server, i started to have a few different services each with its own set of credentials. Although i use a [password manager](https://keepassxc.org/) i dont want to be login to every one.

I have been looking into [Authelia](https://www.authelia.com/) and [Authentik](https://goauthentik.io/) for a while and finally the time has arrived. Instead of spending a full day studying for my exams, i will spend it setting this up. Authelia seemed the best option as it appears to be very lightweight and in the same vein as [Beszel](https://beszel.dev/) and [Dozzle](https://dozzle.dev/).

This time the setup wasnt as straightforward as last time, but this was mainly because of YAML and some apps that do things weirdly. I **HATE** yaml, i dont understand why its so widely used on infra-related things.

## Installing Authelia
Before installing Authelia, a personal recommendation its to rename every app user to the have the same username and email to ease the transition.

First lets create a folder to hold and then mount our configuration, users and keys

```sh
mkdir config
mkdir config/keys
```

As im going to be using [OIDC](https://www.authelia.com/configuration/identity-providers/openid-connect/provider/) (more on this later) we need to [generate a pair of keys](https://www.authelia.com/reference/guides/generating-secure-values/#generating-an-rsa-keypair).

```sh
docker run --rm -v "$(pwd)/config/keys":/keys authelia/authelia:latest authelia crypto pair rsa generate --directory /keys
```

For the configuration (config/configuration.yml) this is the smallest one i could make using the default one. Being the only consumer of this i could live with some things being local or not [HA](https://en.wikipedia.org/wiki/High_availability). If you are copying this, watchout for identation issues, this is where i've lost more hours that i would like to admint.

```yml
# yamllint disable rule:comments-indentation
---
## The theme to display: light, dark, grey, auto.
theme: 'auto'

##
## Server Configuration
##
server:
  ## The address for the Main server to listen on in the address common syntax.
  ## Formats:
  ##  - [<scheme>://]<hostname>[:<port>][/<path>]
  ##  - [<scheme>://][hostname]:<port>[/<path>]
  ## Square brackets indicate optional portions of the format. Scheme must be 'tcp', 'tcp4', 'tcp6', 'unix', or 'fd'.
  ## The default scheme is 'unix' if the address is an absolute path otherwise it's 'tcp'. The default port is '9091'.
  ## If the path is specified this configures the router to handle both the `/` path and the configured path.
  ## Im hosting it under host/authelia subpath.
  address: 'tcp://:9091/authelia'

  ## Server Endpoints configuration.
  ## This section is considered advanced and it SHOULD NOT be configured unless you've read the relevant documentation.
  ## Needed for caddy auth directive
  endpoints:
    ## Configure the authz endpoints.
    authz:
      forward-auth:
        implementation: 'ForwardAuth'

##
## Identity Validation Configuration
##
## This configuration tunes the identity validation flows.
identity_validation:

  ## Reset Password flow. Adjusts how the reset password flow operates.
  reset_password:

    ## The secret key used to sign and verify the JWT.
    jwt_secret: 'a_very_important_secret'

##
## Authentication Backend Provider Configuration
##
## Used for verifying user passwords and retrieve information such as email address and groups users belong to.
##
## The available providers are: `file`, `ldap`. You must use only one of these providers.
authentication_backend:
  ##
  ## File (Authentication Provider)
  ##
  ## With this backend, the users database is stored in a file which is updated when users reset their passwords.
  ## Therefore, this backend is meant to be used in a dev environment and not in production since it prevents Authelia
  ## to be scaled to more than one instance. The options under 'password' have sane defaults, and as it has security
  ## implications it is highly recommended you leave the default values. Before considering changing these settings
  ## please read the docs page below:
  ## https://www.authelia.com/r/passwords#tuning
  ##
  ## Important: Kubernetes (or HA) users must read https://www.authelia.com/t/statelessness
  ##
  file:
    path: '/config/users_database.yml'

##
## Access Control Configuration
##
## Access control is a list of rules defining the authorizations applied for one resource to users or group of users.
##
## If 'access_control' is not defined, ACL rules are disabled and the 'deny' rule is applied, i.e., access is denied
## to everyone. Otherwise restrictions follow the rules defined.
##
## Note: One can use the wildcard * to match any subdomain.
## It must stand at the beginning of the pattern. (example: *.example.com)
##
## Note: You must put patterns containing wildcards between simple quotes for the YAML to be syntactically correct.
##
## Definition: A 'rule' is an object with the following keys: 'domain', 'subject', 'policy' and 'resources'.
##
## - 'domain' defines which domain or set of domains the rule applies to.
##
## - 'subject' defines the subject to apply authorizations to. This parameter is optional and matching any user if not
##    provided. If provided, the parameter represents either a user or a group. It should be of the form
##    'user:<username>' or 'group:<groupname>'.
##
## - 'policy' is the policy to apply to resources. It must be either 'bypass', 'one_factor', 'two_factor' or 'deny'.
##
## - 'resources' is a list of regular expressions that matches a set of resources to apply the policy to. This parameter
##   is optional and matches any resource if not provided.
##
## Note: the order of the rules is important. The first policy matching (domain, resource, subject) applies.
access_control:
  ## Default policy can either be 'bypass', 'one_factor', 'two_factor' or 'deny'. It is the policy applied to any
  ## resource if there is no policy to be applied to the user.
  default_policy: 'deny'

  rules:
    ## Rules applied to everyone
    - domain: 'example.com'
      policy: 'one_factor'
      subject:
      - 'group:admin'
      resources:
      - '^/dozzle([/?].*)?$'

##
## Session Provider Configuration
##
## The session cookies identify the user once logged in.
## The available providers are: `memory`, `redis`. Memory is the provider unless redis is defined.
session:
  ## Cookies configures the list of allowed cookie domains for sessions to be created on.
  ## Undefined values will default to the values below.
  cookies:
    -
      ## The domain to protect.
      ## Note: the Authelia portal must also be in that domain.
        domain: 'example.com'

      ## Required. The fully qualified URI of the portal to redirect users to on proxies that support redirections.
      ## Rules:
      ##   - MUST use the secure scheme 'https://'
      ##   - The above 'domain' option MUST either:
      ##      - Match the host portion of this URI.
      ##      - Match the suffix of the host portion when prefixed with '.'.
        authelia_url: 'https://example.com/authelia'

##
## Storage Provider Configuration
##
## The available providers are: `local`, `mysql`, `postgres`. You must use one and only one of these providers.
storage:
  ## The encryption key that is used to encrypt sensitive information in the database. Must be a string with a minimum
  ## length of 20. Please see the docs if you configure this with an undesirable key and need to change it, you MUST use
  ## the CLI to change this in the database if you want to change it from a previously configured value.
  encryption_key: 'random_string_20_chars'

  ##
  ## Local (Storage Provider)
  ##
  ## This stores the data in a SQLite3 Database.
  ## This is only recommended for lightweight non-stateful installations.
  ##
  ## Important: Kubernetes (or HA) users must read https://www.authelia.com/t/statelessness
  ##
  local:
    ## Path to the SQLite3 Database.
    path: '/config/db.sqlite3'

##
## Notification Provider
##
## Notifications are sent to users when they require a password reset, a WebAuthn registration or a TOTP registration.
## The available providers are: filesystem, smtp. You must use only one of these providers.
notifier:
  ## You can disable the notifier startup check by setting this to true.
  # disable_startup_check: false

  ##
  ## File System (Notification Provider)
  ##
  ## Important: Kubernetes (or HA) users must read https://www.authelia.com/t/statelessness
  ##
  filesystem:
    filename: '/config/notification.txt'

##
## Identity Providers
##
identity_providers:

  ##
  ## OpenID Connect (Identity Provider)
  ##
  ## It's recommended you read the documentation before configuration of this section.
  ## See: https://www.authelia.com/c/oidc/provider
  oidc:
    jwks:
      - key: {{ secret "/config/keys/private.pem" | mindent 10 "|" | msquote }}

    ## Authorization Policies which can be utilized by clients. The 'policy_name' is an arbitrary value that you pick
    ## which is utilized as the value for the 'authorization_policy' on the client.
    authorization_policies:
      admin:
        default_policy: 'deny'
        rules:
          - policy: 'one_factor'
            subject: 'group:admin'

    ## Clients is a list of registered clients and their configuration.
    ## It's recommended you read the documentation before configuration of a registered client.
    ## See: https://www.authelia.com/c/oidc/registered-clients
    clients:
      - client_id: 'beszel'
        client_name: 'Beszel'
        client_secret: 'digest'  # The digest of 'insecure_secret'.
        public: false
        authorization_policy: 'admin'
        redirect_uris:
          - 'https://example.com/beszel/api/oauth2-redirect'
        scopes:
          - 'openid'
          - 'email'
          - 'profile'
        userinfo_signed_response_alg: 'none'
        token_endpoint_auth_method: 'client_secret_basic'
        pre_configured_consent_duration: '1M'
...
```

Next we have to define our `config/users_database.yml` file with all our users. To generate the password value, you could run the following command. `podman run --rm -it authelia/authelia:latest authelia crypto hash generate argon2`. Here we are creating a user which its assigned to the groups `admin` and `notes`.

```sh
# yaml-language-server: $schema=https://www.authelia.com/schemas/latest/json-schema/user-database.json
---
users:
  admin:
    disabled: false
    displayname: 'admin'
    password: 'password'
    email: 'admin@example.com'
    groups:
      - 'admin'
      - 'notes'
```

With everything in place, we only need to start Authelia. The `--config.experimental.filters template` its needed to load the key files and dont have to embedded them in the configuration file.

```sh
podman create  -v ./config:/config --name authelia authelia/authelia --config /config/configuration.yml --config.experimental.filters template
```

## Securing APPS
There are two kind of Access Control here. [Trusted Headers SSO](https://www.authelia.com/overview/authorization/trusted-headers/) and [OIDC](https://www.authelia.com/overview/authorization/openid-connect-1.0/).

In Trusted Headers SSO, your app trusts the headers it receives and if it sees a particular one with a username, you are logged in.

This is the section in the configuration file. By default if no matching rule is found, the access is denied. If a request to the subpath `/dozzle/*` is found, and the user is in the `admin` group, ask for single factor authentication AKA user and password.

```yml
access_control:
  ## Default policy can either be 'bypass', 'one_factor', 'two_factor' or 'deny'. It is the policy applied to any
  ## resource if there is no policy to be applied to the user.
  default_policy: 'deny'

  rules:
    ## Rules applied to everyone
    - domain: 'example.com'
      policy: 'one_factor'
      subject:
      - 'group:admin'
      resources:
      - '^/dozzle([/?].*)?$'
```

The other one its the classic [OAuth](https://en.wikipedia.org/wiki/OAuth) flow. Here the `authorization_policies` allows us to setup named policies in the same way as we did before. Clients its an array of registered clients AKA different APPs that will consume this type of authorization.

```yaml
  oidc:
    jwks:
      - key: {{ secret "/config/keys/private.pem" | mindent 10 "|" | msquote }}

    ## Authorization Policies which can be utilized by clients. The 'policy_name' is an arbitrary value that you pick
    ## which is utilized as the value for the 'authorization_policy' on the client.
    authorization_policies:
      admin:
        default_policy: 'deny'
        rules:
          - policy: 'one_factor'
            subject: 'group:admin'

    ## Clients is a list of registered clients and their configuration.
    ## It's recommended you read the documentation before configuration of a registered client.
    ## See: https://www.authelia.com/c/oidc/registered-clients
    clients:
      - client_id: 'beszel'
        client_name: 'Beszel'
        client_secret: 'digest'  # The digest of 'insecure_secret'.
        public: false
        authorization_policy: 'admin'
        redirect_uris:
          - 'https://example.com/beszel/api/oauth2-redirect'
        scopes:
          - 'openid'
          - 'email'
          - 'profile'
        userinfo_signed_response_alg: 'none'
        token_endpoint_auth_method: 'client_secret_basic'
        pre_configured_consent_duration: '1M'
```

You can view in the excellent [Authelia integrations](https://www.authelia.com/integration/prologue/introduction/) what you need to do for your app. I took almost all configs from there.

Next we need to instruct Caddy to first check with authelia if the user is logged in or not for the Trusted Headers SSO ones. First we need to add the following at the root of the Caddyfile. Here im only using `10.0.0.0/8` as Caddy and Authelia are in the same private network.

```
{
	servers {
		trusted_proxies static 10.0.0.0/8
	}
}
```

Previously i was routing apps in the following way:

```
redir /app /app/
handle_path /app/* {
    reverse_proxy app:8080
}
```

Now i have to change them to the following, here i lost another minutes, but thanks to [someone else](https://caddy.community/t/forward-auth-with-strip-prefix/30066/2) i found a solution relatively fast.

```
@app path /app /app/*
route @app {
	forward_auth authelia:9091 {
		uri /api/authz/forward-auth
		copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
	}
	uri strip_prefix /app
	reverse_proxy app:8080
}
```

## Rogue APP
The other place where i lost most of the time, was trying to configure [FreshRSS](https://github.com/FreshRSS/FreshRSS) to use OIDC while being in a subpath, and not a subdomain. I couldnt make it work, i had to do some hacky things. As i couldnt make it redirect to the subpath, it would always redirect to the root.

Here it is as a testament to the future, probably me. I wont try to explain it as i dont fully understand it.

```
rewrite /i/oidc/* /freshrss/i/oidc/
redir /i/ /freshrss/i/?{query}
redir /freshrss /freshrss/
handle_path /freshrss/* {
	reverse_proxy freshrss:80 {
		header_up X-Forwarded-Prefix /freshrss
	}
}
```

## Outro
Now i only need to remember a single user and password and i can login to every app with one or less clicks. Well, almost all apps, but maybe that results in a following PR.

This is a super simple setup with a single user and a few groups, and this post is almost a copy from the official guide. But i know that in the future if i need to do this again, this is the kind of guide i would like to read instead of jumping between different sections and links. As always, [check the official guide](https://www.authelia.com/configuration/prologue/introduction/).

Taking out the amount of time i lost fighting yaml identation and freshrss stubborness, i believe the setup was also straightforward.
