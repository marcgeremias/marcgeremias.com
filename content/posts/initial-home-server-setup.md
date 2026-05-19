---
date: '2026-04-29T11:50:47+02:00'
draft: false
title: 'Initial Home Server Setup (Ubuntu, SSH & Networking Basics)'
---

## Introduction

Nowadays, when building a new application, we often end up relying on multiple **SaaS services** such as app hosting, mail relays, database infrastructure, payment gateways, caching systems, routing, observability tools, and many others.

However, I do not think these services should always be the default choice. A proper architectural analysis should be performed before introducing **external dependencies** into a project. Building a tech stack is relatively easy, but maintaining it over the mid or long term can become expensive, complex, and sometimes difficult to migrate away from.

![image](/images/saas_selfhost.png)

The discussion around SaaS services versus self-hosting could go on forever. There are already many great articles and detailed posts about this topic, so the purpose of this post is not to decide which approach is right or wrong.

What I really want is to experiment with building my own infrastructure in order to better understand what happens behind the scenes.

The main objective of this project is to experiment with a **self-hosted server** and improve my understanding of software architecture and infrastructure.


## Hardware

First of all, we need something capable of hosting the server. In this case, I decided to use a small and old Dell laptop, which is actually a perfect candidate because:

- I want something with **low power consumption**
- Performance and storage are not critical for this project
- It is a standalone device dedicated to experimentation

![image](/images/dell_laptop.jpeg)

### Hardware specs

| Component        | Details                                      |
|------------------|----------------------------------------------|
| Model            | Dell Latitude 7390                           |
| CPU              | Intel Core i5-8250U @ 1.60GHz (4 cores)      |
| RAM              | 16 GB DDR4 2400 MHz                          |
| Storage          | 512 GB NVMe SSD (Toshiba KXG60ZNV512G)       |
| Architecture     | x86_64                                       |
| GPU              | Intel UHD Graphics 620                       |
| Network (LAN)    | Intel Ethernet I219-LM                       |

## Initial software configuration

### Ubuntu Server OS

First, we need to prepare the operating system and configure the machine to operate as a stable server. The selected OS is **Ubuntu 24.04.4 LTS**, as it is widely used, well-documented, reliable, and easy to manage, making it suitable for experimental and development environments.

![image](/images/neofetch.png)

The disk was automatically partitioned during the Ubuntu installation. The 512 GB NVMe SSD was divided into two partitions. A small EFI partition used for booting the system and a large EXT4 partition (around 475 GB) used as the main filesystem for Ubuntu.

### Preventing lid suspension

With Ubuntu Server running, we can start with the software configuration. The first thing that I configure is disabling **lid suspension** and enabling **SSH access** to be able to access the server without having to be physically using the machine’s display and keyboard.

With the following configuration, now we can keep the lid closed and keep using the machine.

`/etc/systemd/logind.conf`
```ini
HandleLidSwitch=ignore
# this one prevents the network interface from shutting down when closing the lid
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```

### Display power saving

To reduce power consumption, the display can be configured to turn off after 5 minutes of inactivity, since the server will mainly be accessed via SSH (CLI).

`# /etc/default/grub`
```ini
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash consoleblank=300"
```

### Static IP configuration

The next step is configuring SSH. Before doing so, it is useful to assign a **static IP address** to ensure consistent access to the server. To begin, we can inspect the available network interfaces and current IP assignments using the `ip a` command.

![image](/images/network_interfaces.png)

As shown in the output, the system exposes three main network interfaces:

- `lo`: loopback interface used for internal communication
- `enp0s31f6`: wired ethernet interface
- `wlp2s0`: wireless interface

For this setup, we chose the wired ethernet interface due to its higher reliability, better performance, and simpler configuration compared to Wi-Fi.

The interface `enp0s31f6` is currently assigned the IP address `192.168.1.64` via DHCP. To make this address persistent, a DHCP reservation (static lease) was configured in the router using the **MAC address** of the Ethernet interface.

The following image shows the final router configuration:

![image](/images/static_private_ip.png)

### SSH access

Now that the static IP address has been configured, we can continue with the SSH setup. On the server, we need to install the `openssh-server` package, which provides the `sshd` daemon responsible for managing Secure Shell connections.

With the following command, we can verify that the SSH service is running properly:

![image](/images/ssh_service.png)

To improve the security of the server, we will use a **passwordless SSH configuration**. This is considered a good practice because it helps prevent brute-force attacks.

To do so, we first need to generate an **SSH key pair** on the client machine that will connect to the server.

```bash
ssh-keygen -t rsa -b 4096 -C "homelaptop"
```

- `-t rsa` specifies the type of key to generate using the RSA algorithm
- `-b 4096` defines the key size in bits
- `-C` adds a label or comment to identify the key

This command will generate a public key (`.pub`) and a private key. The public key must be copied to the server inside the `~/.ssh/authorized_keys` file of the target user, while the private key must remain secure on the client machine.

To further improve security, **password authentication** can be completely disabled on the server by editing the SSH daemon configuration:

`/etc/ssh/sshd_config`
```ini
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
```

Finally, restart the SSH service:

```bash
sudo systemctl restart ssh
```

From this point, the server will only allow SSH connections using authorized SSH keys.







