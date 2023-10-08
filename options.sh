#!/bin/ash

options() {

    printf '\n ❯❯ %s:\n\n' "$1"
    shift 1
    exit='continue'
    set -- $@ "$exit"
    n=1
    while :; do
        eval "c=\${$n}"
        for i in $@; do
            if [ "$i" = "$exit" ]; then
                o="$(printf ' \e[32;1m%s ' '▶')"
            else
                eval "v=\${$i}"
                [ "$v" = 1 ] && o='[✔]' || o='[✘]'
            fi
            if [ "$i" = "$c" ]; then
                printf ' \e[7m %s %s \e[0m\n' "$o" "$i"
            else
                printf '  %s %s\e[0m \n' "$o" "$i"
            fi
        done
        read -rsn3 key
        case $key in
            $(printf '\e[A')) [ $n -gt 1 ] && n=$((n-1));;
            $(printf '\e[B')) [ $n -lt $# ] && n=$((n+1));;
            *)
                if [ "$c" = "$exit" ]; then
                    break
                else
                    eval "v=\${$c}" && export "$c"="$((1-$v))"
                fi
            ;;
        esac
        printf '\e[%sA' $#
    done

}
