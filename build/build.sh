#!/bin/bash

# ---------------------------
#
# Build the FIRMWARE IMAGE
#
# This script builds the .img disk file, x86 bootable image.
# All the packages in build/packages would be force-installed
# to the image, even if not mentioned in the PACKAGES variable.
#
# ---------------------------

if [[ "$1" == "generic" ]]; then
    IMAGE_URL="https://downloads.openwrt.org/releases/22.03.6/targets/x86/generic/openwrt-imagebuilder-22.03.6-x86-generic.Linux-x86_64.tar.xz"
    IMAGE_SHA1SUM="a16b0cccb812735027372f3b243ec6bb835bcbee"
elif [[ "$1" == "legacy" ]]; then
    IMAGE_URL="https://downloads.openwrt.org/releases/22.03.6/targets/x86/legacy/openwrt-imagebuilder-22.03.6-x86-legacy.Linux-x86_64.tar.xz"
    IMAGE_SHA1SUM="435e9a881cc6dec860ff0826b0c6ee721886b3d4"
else
    echo "<$0> <generic/legacy>"
    exit 1
fi

# OpenWrt device profile
PROFILE="generic"

# Packages to be included in the image
PACKAGES="luci
luci-ssl

curl
tcpdump
bind-dig
bind-host
coreutils-base64
xxd
less
nano-plus
htop
procps-ng-watch
ip-full
tc
ss
unshare
zram-swap
findutils-xargs
bash
pv

python3
scapy

openvpn-openssl
openvpn-easy-rsa
luci-app-openvpn
wireguard-tools
luci-app-wireguard

nmap-ssl
nping-ssl
ncat-ssl

mtr-json
iperf
iperf3
stunnel
hping3

arp-scan
arp-scan-database
iputils-arping

tmux
screen

autossh
sshpass
passh

kmod-ipvlan
kmod-macvlan

msmtp
whois
sipcalc
openssh-sftp-server
ucert

kmod-crypto-hw-padlock
libopenssl-padlock

avahi-nodbus-daemon

miredo
coturn
proxychains-ng
tor
v2ray-core
xl2tpd
pptpd

strongswan-charon
strongswan-swanctl
strongswan-mod-socket-default
strongswan-mod-aes
strongswan-mod-sha1
strongswan-mod-sha2
strongswan-mod-random
strongswan-mod-kernel-netlink
strongswan-mod-hmac
strongswan-mod-nonce
strongswan-mod-gmpdh
kmod-crypto-cbc
kmod-crypto-authenc
kmod-crypto-sha256
kmod-crypto-rng
kmod-crypto-echainiv
kmod-nft-xfrm

hostapd-basic
kmod-ath9k-htc
kmod-mt76x0u
kmod-rt2800-usb

kmod-usb-hid
kmod-fs-vfat

psiphon
tor-relay-scanner
hellothere
"

# Services to be disabled by default
DISABLED_SERVICES=""

# ---------------------------

IMAGE_FILE="${IMAGE_URL##*/}"
IMAGE_NAME="${IMAGE_FILE%.tar.xz}"

if [ ! -e "$IMAGE_FILE" ]; then
    wget --quiet "$IMAGE_URL"
    echo "$IMAGE_SHA1SUM" "$IMAGE_FILE" | sha1sum -c || { echo bad sha1sum; exit 1; }
fi

if [ ! -e "$IMAGE_NAME/.config" ]; then
    tar axf "$IMAGE_FILE"
fi

cd "$IMAGE_NAME"

# Copy package and firmware signing keys
cp ../keys/* . && cat key-build.pub > keys/$(./staging_dir/host/bin/usign -F -p key-build.pub)

# Copy custom packages into the ImageBuilder package feed
cp ../packages/$1/* packages/


# Patch ImageBuilder's Makefile to force-install local packages,
# just to make sure we'll have our own package versions in the image.
# NOTE: it will force-install ALL the packages in packages/ directory,
# even not mentioned in PACKAGES variable.
patch <<'EOF'
--- Makefile	2023-01-03 03:24:21.000000000 +0300
+++ Makefile	2023-06-13 16:57:23.768020555 +0300
@@ -167,6 +167,9 @@
 	$(OPKG) install $(firstword $(wildcard $(LINUX_DIR)/libc_*.ipk $(PACKAGE_DIR)/libc_*.ipk))
 	$(OPKG) install $(firstword $(wildcard $(LINUX_DIR)/kernel_*.ipk $(PACKAGE_DIR)/kernel_*.ipk))
 	$(OPKG) install $(BUILD_PACKAGES)
+	@echo
+	@echo Force-reinstalling local packages
+	$(OPKG) install --force-reinstall --force-downgrade $(wildcard $(PACKAGE_DIR)/*.ipk)
 
 prepare_rootfs: FORCE
 	@echo
EOF


PACKAGES=$(echo $PACKAGES)
DISABLED_SERVICES=$(echo $DISABLED_SERVICES)
# Change GRUB boot cmdline. Disable ACPI thermal (VIA bug) and vulnerability mitigations.
sed -i 's/CONFIG_GRUB_BOOTOPTS=.*/CONFIG_GRUB_BOOTOPTS="thermal.off=1 mitigations=off quiet"/' .config
# Disable generating of everything which is not squashfs disk image.
sed -i '/CONFIG_TARGET_ROOTFS_TARGZ=/c CONFIG_TARGET_ROOTFS_TARGZ=n' .config
sed -i '/CONFIG_TARGET_ROOTFS_EXT4FS=/c CONFIG_TARGET_ROOTFS_EXT4FS=n' .config
#sed -i -e '/## Place your custom/c src imagebuilder file:packages' -e '/src imagebuilder file:packages/d' repositories.conf

(LC_ALL=C date && git rev-parse HEAD) > ../files/etc/hoogmoon_version
LEGACYGENERIC="(LEGACY) "
[[ "$1" == "generic" ]] && LEGACYGENERIC="(GENERIC)"

echo \
"╭────────────────────────────────────────────────╮
│    H O O G M O O N    R O U T E R   $LEGACYGENERIC  │
╰────────────────────────────────────────────────╯
   v0.1, $(LC_ALL=C date), $(git rev-parse --short HEAD)
" > ../files/etc/banner

make image PROFILE="$PROFILE" PACKAGES="$PACKAGES" DISABLED_SERVICES="$DISABLED_SERVICES" FILES="../files" ADD_LOCAL_KEY=1
