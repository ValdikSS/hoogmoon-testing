function myip {                                                             
    curl -s -f --max-time 15 https://ipv4-internet.yandex.net/api/v0/ip | awk -F '"' '{print $2}'
}
