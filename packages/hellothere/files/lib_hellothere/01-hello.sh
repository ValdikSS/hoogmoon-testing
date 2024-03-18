WANIP_INT=$(myip_int)

# Wait up to 60 seconds for internet to connect
for i in $(seq 60); do
  WANIP_EXT=$(myip_ext)
  [ "$WANIP_EXT" ] && break
  sleep 1
done

echo "$(date)"
echo -e "\xf0\x9f\x93\xa2 Hello, node $HOSTNAME (int $WANIP_INT / ext $WANIP_EXT) is alive!"
echo "Running on $MODEL."
echo 

exit 0
