#!/bin/bash

# ---------------------------
#
# Build the PACKAGES
#
# This script builds the packages from /packages directory,
# as well as any package from the official OpenWrt feed.
#
# This should be used if you need any custom packages not present
# in official OpenWrt or you need to rebuild it with different
# configuration flags or settings.
#
# ---------------------------

# Packages to build.
PACKAGES="
    hellothere
    psiphon
    tor-relay-scanner
    tor
    curl
    openvpn
    lft
    ppp
"

# Modifications to .config file to make
CONFTOGGLE="
    CONFIG_CCACHE=y
    CONFIG_LIBCURL_VERBOSE=y
"

# Additional packages to include in the directory, in case
# if the package Makefile contains several packages.
OUT_ADDITIONAL_PACKAGES="
    libcurl
    whob
"

#mkdir ~/.ssh
#echo 'ssh-j.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIiyFQuTwegicQ+8w7dLA7A+4JMZkCk8TLWrKPklWcRt' > ~/.ssh/known_hosts
#echo 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBOCu8JpEBHDcrhcMpyE16xzk7/D8QRDGqEDVEnAqR3WHOUAEsvgTxz41/oqoDd8OAAQkl971pkRgGYSeK6D0dc= valdikss' | sudo tee /root/.ssh/authorized_keys
#echo 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBOCu8JpEBHDcrhcMpyE16xzk7/D8QRDGqEDVEnAqR3WHOUAEsvgTxz41/oqoDd8OAAQkl971pkRgGYSeK6D0dc= valdikss' | tee ~/.ssh/authorized_keys
#ssh -o ExitOnForwardFailure=yes -o ServerAliveInterval=60 -NR github:22:localhost:22 valdikss@ssh-j.com || true

if [[ "$1" == "generic" ]]; then
    SDK_URL="https://downloads.openwrt.org/releases/22.03.6/targets/x86/generic/openwrt-sdk-22.03.6-x86-generic_gcc-11.2.0_musl.Linux-x86_64.tar.xz"
    SDK_SHA1SUM="4456c4a5c79ecbcaacd8b6fd2fcb519e1bd05896"
elif [[ "$1" == "legacy" ]]; then
    SDK_URL="https://downloads.openwrt.org/releases/22.03.6/targets/x86/legacy/openwrt-sdk-22.03.6-x86-legacy_gcc-11.2.0_musl.Linux-x86_64.tar.xz"
    SDK_SHA1SUM="33b762e4bb664e78a22a99d7fd7ef4590f31757b"
else
    echo "<$0> <generic/legacy>"
    exit 1
fi


# ---------------------------

SDK_FILE="${SDK_URL##*/}"
SDK_NAME="${SDK_FILE%.tar.xz}"

if [ ! -e "$SDK_FILE" ]; then
    wget --quiet "$SDK_URL"
    echo "$SDK_SHA1SUM" "$SDK_FILE" | sha1sum -c || { echo bad sha1sum; exit 1; }
fi

if [ ! -d "$SDK_NAME" ]; then
    tar axf "$SDK_FILE"
fi
cd "$SDK_NAME" || { echo No SDK directory && exit 2; }

PACKAGES=$(echo $PACKAGES)
CONFTOGGLE=$(echo $CONFTOGGLE)
OUT_ADDITIONAL_PACKAGES=$(echo $OUT_ADDITIONAL_PACKAGES)

# Patch feeds to the current branch.
# SDK includes hard-coded feed commit hash, but ImageBuilder builds
# whatever is current in the repository. This creates issues such as
# SDK compiles older version of the packet but ImageBuilder prefers newer
# version from the repository.
sed -i 's/\^.*/;openwrt-22.03/g' feeds.conf.default

# Update feeds
./scripts/feeds update -a && ./scripts/feeds install -a
# Copy the patches. Can't use cp here as the destination tree is all symlinks.
rsync -K -a ../packages/* package/feeds/packages/

# ---------------------------
# Patch OpenVPN Makefile to re-enable OpenSSL Engine support
sed -i 's/ --with-openssl-engine=no//' package/feeds/packages/openvpn/Makefile
# ---------------------------

# Generate default .config in a cache-friendly way
if [ ! -f ".config" ]; then
    make defconfig
fi

# Replace config options
for toggle in $CONFTOGGLE; do
    toggle_name="${toggle%=*}"
    toggle_value="${toggle#*=}"
    sed -i -e "s/# $toggle_name is not set/$toggle/" -e "s/^$toggle_name=.*/$toggle/" .config
done

# Use ccache to speed up building
make tools/ccache/compile -j$(nproc)

# Clean previous packages
rm -rf bin/*
# Compile all packages needed to be built
mkdir -p bin/outpkgs/

for pkg in $PACKAGES; do
    make package/$pkg/clean
    ls -la package/feeds/packages/$pkg/patches/
    make package/$pkg/compile -j$(nproc) || { echo Error compiling $pkg; exit 3; }

    cp bin/packages/*/packages/$pkg* bin/outpkgs/
done

for pkg in $OUT_ADDITIONAL_PACKAGES; do
    cp bin/packages/*/packages/$pkg* bin/outpkgs/
done

exit 0
