if service tor running; then
echo -en "\xf0\x9f\xa7\x85 Tor is running"

TORHOSTNAME=$(cat /etc/tor/hidden-ssh/hostname)
[ "$TORHOSTNAME" ] && echo -e ".\nConnect as:\nssh root@$TORHOSTNAME" \
|| echo ", but no hidden service is configured"

echo
fi 

exit 0
