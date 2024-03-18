#!/bin/sh

# Add default gateway for LAN routing table, instead
# of using default main routing table.
# This allows to run OpenVPN connection for the LAN,
# without interfering with the regular internet link
# for the censorship researcher.

/sbin/ip route add default dev "$dev" table 100
/sbin/ip -6 route add default dev "$dev" table 100
