Technical details
=================

# Provisioning

HOOGMOON includes custom provisioning subsystem. It is implemented as a set of additional scripts for OpenWrt's [uci-defaults](https://openwrt.org/docs/guide-developer/uci-defaults) subsystem, but could also include arbitrary files, such as OpenVPN configuration.

On the first boot, it does the following:

1. It looks for .tar.gz archive in the end of the system disk on hardcoded offset 512*246335
2. If offset 512*246335 contains "PROVISION" string, skip 512 bytes and unpack .tar.gz file to the `/`
3. Read and parse `/etc/config/provision` (it is assumed to be present in provision archive)
4. Execute all the UCI scripts from `uci_directory` variable in provision configuration file
5. Force-enable or force-disable services mentioned in the configuration file

All the additional configuration logic is done with UCI scripts inside the provision archive. These scripts could parse provision configuration file and setup the environment according to configured behavior. This typically include SSH connection setup, `hellothere` email/Telegram credentials, SSH allowed keys, OpenVPN configuration files, Wi-Fi hotspot configuration, custom Psiphon configuration for certain countries.

There are two concepts for provisioning the machine:

* Add all unique provision information (such as the hostname, SSH-J name, OpenVPN configuration) inside the provision archive, this should be used for provisioning the hardware clients, to make them keep all the information even after OS reset or clean install.
* Add only generic provision information inside the archive, this is for virtual machines, which allows to use a single pre-configured image every time you need a remote access: all new VMs would generate random hostname upon first boot, which you would receive in `hellothere` message along with connection information.

# SSH Connection

In a typical configuration, there are two types of SSH connections: incoming and tunnelled.

Incoming is your regular port listening behaviour. It is used for direct SSH connections (from LAN, or port forwarded, or direct via IPv6), as well as for Tor Hidden Service connections. This does not require special handling.

Tunnelled connection first require establishing connection to some kind of tunneling server, such as [SSH-J.com](https://ssh-j.com/), and wait for connection inside the tunnel. This is configured with `autossh` daemon, which monitors the connection and restarts it if needed. It is configured to connect to SSH-J directly, via Tor, and via Psiphon, whichever works.

Autossh configuration is stored in `/etc/config/autossh`. It is expected to be configured with provision script.

# Hellothere

`hellothere` is a custom set of scripts to send notification when the device is booted. The notification contains basic information of the machine, its IP address, as well as SSH connection information.

The notifications are sent to email or Telegram (or both), optionally via Tor or Psiphon tunneled connection.

Configuration is stored in `/etc/config/hellothere`. It is expected to be configured with provision script.

# Firewall configuration

By default, the first Ethernet interface `eth0` is considered a WAN port and all other physical interfaces are LAN ports.

LAN ports do not have inbound firewall restrictions, while WAN port blocks incoming connections by default, except for:

* SSH (TCP port 22) — allowed from everywhere
* OpenVPN (TCP port 1194) — allowed from everywhere
* Avahi (UDP port 5353) — allowed from `192.168.0.0/16`
* IPsec (ESP + UDP port 500, 4500) — allowed from `192.168.0.0/16`
* L2TP (UDP port 1701) — allowed from `192.168.0.0/16`
* PPTP (GRE + TCP port 1723) — allowed from `192.168.0.0/16`

Firewall is configured by `uci-defaults` scripts found in `/etc/uci-defaults/92-firewall-*`.

# User traffic redirection

Traffic redirection mechanism is a transparent proxy, which intercepts requests from the LAN zone (user connection over Wi-Fi or local VPN) and redirects them to Tor or Psiphon. It is managed by `v2ray` proxy daemon, using netfilter redirection rules `/etc/v2ray/v2ray-redirect-lan.nft`.  
Traffic is NOT redirected for the Linux shell itself, only for user access over VPN or Wi-Fi.

You can enable or disable redirection by starting or stopping `v2ray_redirect` service.

`v2ray` listens for connections to TCP port 5555, as well as TCP/UDP port 5553 for DNS requests, and tunnels Wi-Fi/local VPN user traffic to either Tor or Psiphon, whichever has a lower latency. The latency is tested every 3 minutes.

It supports only TCP traffic (with the exception for UDP DNS traffic), and it also rewrites DNS addresses to a fake range `198.18.0.0/15` and `fc00::/18`, without real DNS resolution for A/AAAA records, to reduce the latency.  
Other DNS records, such as MX, NS, SRV and others, are not handled by fakedns and requested from the DNS resolver `8.8.8.8` TCP over Tor/Psiphon. No DNS lookups for user traffic are ever performed in cleartext, to protect from DNS spoofing.

NOTE: while PPTP, L2TP and Wi-Fi are treated as a regular LAN zone, IPsec IKEv2 is a special case. When traffic redirection is disabled, there would be no internet access (no traffic forwarding) for IKEv2.

# Known issues & bugs

### IPsec IKEv2 is not in LAN zone

IPsec policies in general and IKEv2 connection configuration in particular is logically treated as a LAN connection but technically is still a WAN traffic. It is handled separetely with an additional `/etc/v2ray/wan-allow-ipsec.nft` netfilter rule, which force LAN zone input table lookup for IPsec-tagged traffic.

This is due to IPsec implementation in many OS, including Linux: it's not really a VPN as all other protocols, but an extra addition to traffic routing subsystem.

Unfortunately, the convenient XFRM interface configuration, which makes IPsec behave like a regular VPN, does not work properly with traffic redirection for some reason, this is probably a bug in XFRM interface implementation in Linux kernel.

### UDP traffic is explicitly blocked in transparent proxy

User traffic redirection does not support UDP protocol, except for DNS lookups. This is due to non-existent support for UDP in Tor, as well as in Psiphon in proxy mode.

While Psiphon in tunnel (`tun`) mode supports UDP, a non-premium version has restrictions on destination ports, which likely won't allow to use UDP traffic where it is most needed: online games, VoIP software, etc.

### PPTP/L2TP 4 connections limit

PPTP and L2TP protocols have a limit for 4 concurrent connections for user traffic redirection.
