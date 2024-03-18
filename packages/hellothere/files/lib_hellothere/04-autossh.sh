if service autossh running; then
  local username="$(uci -q get provision.@provision[0].autossh_username)"
  [ ! "$username" ] && username="someuser"

  echo -ne "\xf0\x9f\x93\x9f AutoSSH is running"
  echo
  echo "Connect as:"
  echo "ssh -J $username@ssh-j.com root@$HOSTNAME"

  echo
fi

exit 0
