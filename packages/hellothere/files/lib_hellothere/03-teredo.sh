if service miredo running; then
echo -ne "\xf0\x9f\x95\xb5\xef\xb8\x8f Teredo is running"

# Wait up to 60 seconds for Teredo to connect
for i in $(seq 60); do
    eval $(ip -j addr show dev teredo | jsonfilter -e 'IPTEREDO=@[0].addr_info[0].local')
    [ "${IPTEREDO:0:1}" = "2" ] && break
    sleep 1
done
[ "${IPTEREDO:0:1}" = "2" ] \
    && echo -e ".\nConnect as:\nssh root@$IPTEREDO" \
    || echo ", but address is not configured."

echo
fi 

exit 0
