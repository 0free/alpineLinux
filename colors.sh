#!/bin/ash

colors() {
    loop 30 39
    loop 40 49
    loop 90 99
    loop 100 109
}

loop() {
    textReset='\e[0m'
    i=$1
    while [ $i -ge $1 ] && [ $i -le $2 ]; do
        i=$((i+1))
        color="\e[${i}m"
        echo "$textReset\t$color $i "
    done
}
