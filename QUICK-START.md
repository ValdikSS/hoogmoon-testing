HOOGMOON - Quick Start
======================

## How to use the project

1. Download the latest image from the Releases page
2. Clone the repository
3. Edit `provision` directory for your own needs. The minimal customization:
    - Set telegram/email configuration in `etc/config/hellothere`
    - Set `autossh_username` in `etc/config/provision`
    - Copy your SSH public key into `etc/dropbear/authorized_keys`)
4. Run `./provision_archive.sh`
5. Append `provision.tar.gz` into the image:  
`dd if=provision.tar.gz of=hoogmoon-image.img conv=notrunc bs=512 seek=246335`

If you haven't entered `hostname` value in provision configuration, make a copy of the image file and call it _autoprovision_. The host name will be auto-generated on the first run, that way you can distribute this file without any additional tuning per user.

If everything is configured properly, you'll receive the following text on your email/Telegram upon booting:

```
Mon Mar 18 14:12:25 UTC 2024
📢 Hello, node c86c459f (int 10.0.2.15 / ext 1.2.3.4) is alive!
Running on qemu-standard-pc-i440fx-piix-1996.

🧅 Tor is running.
Connect as:
ssh root@kv5dyivrhixeesx7pchbzet6bowdm6fm5pcw73fyblixozktxgwrfcad.onion

📟 AutoSSH is running
Connect as:
ssh -J dummy@ssh-j.com root@c86c459f
```

For SSH connection to Tor address, install `ncat` (`nmap`), run Tor on your PC and add the following into your local `~/.ssh/config`:

```
Host *.onion
  ProxyCommand ncat --proxy 127.0.0.1:9050 --proxy-type socks5 %h %p
```

To run _tmux_ session, execute `t`.

<br>

## How to compile your image from scratch

Only if you want to rebuild the image. Not needed to just use it.

1. Clone this repository on Github
2. Open repository's Actions →  Build **OpenWrt Packages** → Run workflow → press "Run workflow" button
3. Wait until all packages are built (Up to 1 hour for the first run, subsequent builds are faster)
4. Download the action artifacts (files)
5. Unpack the .ipk files into /packages (x86 into generic, viax86 into legacy). Make sure to copy only needed files, as there may be packaging variations (as in openvpn-mbedtls, openvpn-openssl, you need only one of these two)
6. Commit and push into the repository
7. Open repository's Actions →  Build **OpenWrt** → Run workflow → press "Run workflow" button
8. Wait until the firmware is built (≈7-15 minutes)
9. Download the artifact
