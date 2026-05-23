---
date: '2026-05-15T11:50:47+02:00'
draft: true
title: 'Simple First Web Deployment'
---

## Introduction

With the VPN and remote access already configured, we can now start working on lab projects. The first thing I would like to achieve is deploying a simple web page. The most straightforward approach would be to install a web server such as Nginx or Apache and configure it to serve files from a specific directory.

However, since the goal of this project is to better understand modern infrastructure and self-hosting practices, I also want to experiment with Docker, reverse proxies, domain configuration, and basic network security. For this reason, I decided to use Docker containers to deploy my first simple web page.

I know that using a reverse proxy such as [Nginx](https://github.com/nginx/nginx) or [Traefik](https://github.com/traefik/traefik) would be a better and more scalable approach. However, I enjoy improving things step by step in order to better understand the purpose and necessity behind each upgrade. For now, exposing a simple HTTP service on port 80 is more than enough for a first iteration.

## Docker test and port forwarding

Once the DDNS is configured, exposing a service to the internet becomes relatively straightforward. As with the VPN configuration, the first step is to access the router NAT/PAT settings and forward port 80 to the internal machine running Docker.

![image](/images/natpat_http.png)

After that, Docker can be installed using a package manager such as `apt`. Once installed, we can pull the official `nginx` image and run it as a container.

Then we will install docker using a package manager such as apt, now we can pull the `nginx` image and just execute this simple command that will create and start a new container.

```bash
docker run --restart always -d -p 80:80 --name nginx-container nginx
```

- `--restart always`: ensures the container automatically restarts after a reboot or crash
- `-d`: runs the container in the background (detached mode)
- `-p 80:80`: maps port 80 of the host to port 80 inside the container
- `--name nginx-container`: assigns a readable name to the container

As a result we have exposed the nginx container to the internet, and by using the unsecure HTTP 80 port and the correct DDNS url we can access the web, this is what we obtain using the web browser:

![image](/images/http_ddns.png)

And if we try to access the web using the HTTP 443 port we obtain the following error, because the SSL/TLS certificate is not yet configured.

![image](/images/https_ddns.png)

## Buying my domain







## Cloudflare configuration

## UFW / iptables