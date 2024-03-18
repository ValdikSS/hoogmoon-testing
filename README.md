HOOGMOON — Remote Access OS for Internet Censorship Research
========

## What

Preconfigured operating system image for reliable remote access to the Linux shell inside the image over the Internet in general, for long-running network interference/censorship tests in particular.

This is an OS to be installed in a virtual machine or on dedicated hardware in countries under government censorship, to perform in-depth Internet studies, which gives full control over the network link to the researcher and allows to perform the most sophisticated types of measurements, as well as the simple ones, with included set of network utilities, or by connecting to the shared network link over proxy or VPN.

The remote connectivity part of the project is designed with heavy network restrictions in mind: it's proven to work in Iran, Turkmenistan, China and Russia.

With all the features for the researcher, it is also beneficial for the person running the image, by providing unrestricted access to the Internet using the same methods remote connection uses.

**Includes:**

* Linux-based OS ([OpenWrt](https://openwrt.org/)) configured to accept remote SSH connections using multple censorship avoidance measures
* Provision subsystem allowing easy customization of the OS without rebuilding: create generic VM image self-configuring on first boot, or add unique parameters for each individual machine, all with just a single OS image
* Integrated [Tor](https://torproject.org/) and [Psiphon](https://psiphon.ca/) tunneling software customized for the most restrictive environment
* Notification daemon which send connection information via Email/Telegram on OS bootup
* Many common as well as less-known network utilities
* IPv4 and IPv6 compatibility
* Internet access using Tor and Psiphon over Wi-Fi/VPN for the machine owner

## For Whom

HOOGMOON is created for anti-censorship experts, helping to dive deep into the research on particular network connection, to reveal all peculiarities of the ISP filtering methods.

## Why

While existing network measurement systems like [OONI Probe](https://ooni.org/), [RIPE Atlas](https://atlas.ripe.net/), and [GlobalCheck](https://globalcheck.net/en) all provide convenient service for quick and bulk reachability testing of websites and services based on HTTP/HTTPS protocol, they are not suitable for sophisticated network tests, such as when you need to check availability of VPN protocols, or to perform HTTP requests with TCP segmentation, or want to craft the packets manually to check at which network point it gets discarded and what exact data offset triggers the filter.

There are numerous remote access systems like TeamViewer or AnyDesk, which are designed to provide attended access to the desktop. HOOGMOON is an attempt to create unattended Linux shell remote access system with similar ease of usage.

## How

Typical workflow:

1. The expert prepares the image once with email/Telegram credentials, by appending generic self-configuring provision data to the image file, and sends the file
2. The user under censorship imports image into VirtualBox and starts the VM
3. The VM generates random hostname on the first boot, connects to Tor and Psiphon networks, enables SSH access as Tor Hidden Service and over [SSH-J.com](https://ssh-j.com/) (with automatic tunneling via Tor or Psiphon)
4. The expert receives connection information from the VM over email or Telegram (using Tor or Psiphon as a proxy if direct access is filtered)
5. The expert connects to the VM SSH using SSH-J or Tor Hidden Service

## Solving motivational factor

Most of censorship monitoring projects ask the user to install some kind of software on their devices or hardware at their home, giving nothing in return. This is fine in case of technical savvy users, but causes only burden for others.

HOOGMOON tries to increase motivation of keeping the device/VM running by providing unrestricted Internet access using Tor or Psiphon networks (with auto-selection based on lowest latency between these methods) over Wi-Fi (hardware device) or local VPN (in a VM).  
While these methods may be too slow to everyday access, they are reliable backup alternative if the regular circumvention methods, such as VPN, suddenly stop working.
