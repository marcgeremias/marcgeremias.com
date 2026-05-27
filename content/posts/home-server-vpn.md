---
date: '2026-05-13T11:50:47+02:00'
draft: false
title: 'Home server VPN'
cover:
    image: "/diagrams/Stage2.drawio.svg"
    alt: "Stage2 diagram"
---

## Introduction

So, now we have a fully functional server capable of running multiple services. However, access is still limited to the local network (LAN), which is impractical for remote usage. To solve this, there are several options, such as exposing the server to the WAN using port forwarding or setting up a VPN-based solution.

In terms of security, there are pros and cons to both approaches. However, in this case, I not only want to access the server itself, but also other machines within the same LAN. Additionally, I want to be able to manage the router when I am not physically at home.

Another important requirement is that the solution should work seamlessly across different devices, both on desktop and mobile. This way I can securely access my home network from a laptop, a phone, or any other device, regardless of location.

## Benchmarking

First of all, After researching different VPN solutions I ended up choosing WireGuard protocol as my VPN solution. This technology is widely used, open source, and has become a modern standard. Compared to traditional solutions like OpenVPN or IPsec, WireGuard is significantly simpler to configure, offers better performance, and has a much smaller attack surface due to its minimal codebase.

In addition, it integrates natively into the Linux kernel, which improves both efficiency and stability. For my use case, remote access to a home server and full LAN connectivity, WireGuard provides the right balance between security, simplicity, and performance.

## Dynamic DNS (DDNS)

Before setting up a VPN, we first need to solve an issue. Home internet connections are often assigned dynamic public IP addresses, which means they can change over time depending on the ISP. This makes it difficult to reliably access our home network from outside, since the public IP is not guaranteed to stay the same.

To solve this problem, we use Dynamic DNS (DDNS), which allows us to associate a domain name with a changing public IP address and automatically keep it updated whenever the IP changes. There are a variety of free services that offer DDNS implementations, such as [DuckDNS](https://www.duckdns.org/). However, in this case I used the router’s built-in DDNS functionality, which simplifies the process. I just need to create an account with one of the listed DDNS providers and then configure the required credentials.

This is how the DDNS configuration of the router looks:

![image](/images/ddns.png)

## WireGuard VPN

There are many ways to install WireGuard, but in this case I used the [PiVPN](https://www.pivpn.io/) tool, which provides a simple CLI wizard that simplifies the installation and initial configuration. The configuration is quite straightforward; the only thing to take into account is the port used by the WireGuard service. In my case, I selected the default WireGuard port, `51820`.

This port must be forwarded in the router’s NAT/PAT settings in order to allow incoming connections from the internet. This is the configuration being used:

![image](/images/natpat_vpn.png)

Now, we can add a new client using the `pivpn add` command. When a new client is created, WireGuard generates a public and private key pair for that device. These keys are used to establish an encrypted connection between the client and the server. The private key always remains on the client side and must never be shared, while the public key is exchanged with the server.

In practice, PiVPN automatically handles key generation and configuration. It creates the server configuration file and adds the client as a new peer, including its public key and allowed IP range. The result is a client configuration file (`.conf`) that contains all the necessary information, including the client’s private key, the server’s public key, endpoint address, and allowed IPs. This file can then be imported directly into the WireGuard application on the client device to establish the VPN connection.

This is the configuration file being used:

```ini
[Interface]
PrivateKey = ************************************
Address = 10.12.158.2/24
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = ************************************
PresharedKey = ************************************
AllowedIPs = 192.168.1.64/32, 192.168.1.1/32
Endpoint = **********.ddns.net:51820
```

The configuration is split into two sections. The **Interface** section defines the client configuration. It includes the private key, which identifies this device, the VPN IP address assigned to the client, and the DNS servers used while the VPN is active. The **Peer** section defines the remote WireGuard server. It includes the server’s public key for authentication, an optional preshared key for extra security, and the endpoint, which is the public address and port used to reach the server.

Finally, **AllowedIPs** defines which traffic goes through the VPN. In this case, only the home server (192.168.1.64) and the router (192.168.1.1) are accessible through the tunnel, while the rest of the traffic uses the normal internet connection. This is known as split tunneling.
