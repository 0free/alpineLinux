#!/bin/ash

menu() {

    printf '\n ❯❯ %s:\n\n' "$1"
    output=$2
    shift 2
    n=1
    while :; do
        eval "c=\${$n}"
        for i in "$@"; do
            if [ "$i" = "$c" ]; then
                printf ' \e[7m ❯ %s \e[0m\n' "$i"
            else
                printf '  ❯ %s \n' "$i"
            fi
        done
        read -rsn3 key
        case $key in
            $(printf '\e[A')) [ $n -gt 1 ] && n=$((n-1));;
            $(printf '\e[B')) [ $n -lt $# ] && n=$((n+1));;
            '') break;;
        esac
        printf '\e[%sA' $#
    done
    export "$output"="$c"

}
