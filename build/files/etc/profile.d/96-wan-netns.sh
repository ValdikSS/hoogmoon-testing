function netns_create {
    iface="$(uci get network.wan.device)"

    ip netns add "$iface"
    [ $? -ne 0 ] && echo "Namespace is already created! Run netns_destroy" && return 1
    ip link add link "$iface" name vl0 type macvlan
    ip link set vl0 netns "$iface"
    ip netns exec "$iface" ip link set vl0 up
    ip netns exec "$iface" udhcpc -i vl0 -q
}

function netns_enter {
    iface="$(uci get network.wan.device)"

    ip netns exec "$iface" unshare -m sh -c \
      'mount --bind /var/resolv.conf.d/resolv.conf.auto /tmp/resolv.conf && PS1='\''\[\e]0;\u@\h: \w\a\]\[\e[32m\]NETNS\[\e[0m\] \u@\h:\w\$ '\'' && exec sh'
}

function netns_destroy {
    iface="$(uci get network.wan.device)"

    ip netns exec "$iface" ip link del vl0
    ip netns del "$iface"
}
