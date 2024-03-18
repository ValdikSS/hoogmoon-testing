alias 'tcurl'='curl --proxy socks5h://127.0.0.1:9050'
alias 'pcurl'='curl --proxy socks5h://127.0.0.1:10050'
alias 'g'='grep -F'
alias 'eg'='grep -E'
alias 'blockstat'='awk '\''{print "Read KBs:", int($3 * 512 / 1000), "\nWritten KBs:", int($7 * 512 / 1000)}'\'' /sys/class/block/sda/stat'
alias 'assoclist'='iwinfo wlan0 assoclist'

function mkcd() {
  mkdir -pv "$1" && cd "$1"
}

function stop() {
  service "$1" stop
}

function start() {
  service "$1" start
}

function restart() {
  service "$1" restart
}

function reload() {
  service "$1" reload
}

function status() {
  service "$1" status
}
