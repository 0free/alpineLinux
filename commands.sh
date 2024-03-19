
search() {
    apk search
}

install() {
    doas apk add
}

remove() {
    doas apk del --purge
}

disk() {
    lsblk -o name,type,mountpoints,size,fsused,fsuse%,uuid,model
}

clean() {

    printf '%s\n' "❯ cleaning tmp"
    doas rm -rf /tmp/*
    doas rm -rf /var/tmp/*

    printf '%s\n' "❯ cleaning logs"
    doas find /var/log/* -type f -exec rm -f {} \;

    printf '%s\n' "❯ cleaning files"
    doas find / ! -path './proc/*' ! -path '/sys/kernel/debug/tracing/*' -type f \( -iname 'readme' -o -iname 'readme.txt' -o -iname '*.md' -o -iname '*.rst' -o -iname 'license' -o -iname 'license.txt' -o -iname '*.license' -o -iname '*.docbook' \) -exec rm -f {} \;

    if [ ~/.*_history ]; then
        sort -u -o ~/.*_history ~/.*_history
    fi

    doas apk del --purge grub* syslinux* *-doc

}

update() {

    if curl -so /dev/null alpinelinux.org; then

        printf '%s\n' "❯ updating alpineLinux packages"

        if [ -f /lib/apk/db/lock ]; then
            doas rm /lib/apk/db/lock
        fi

        doas apk cache sync
        doas apk cache clean
        doas apk fix
        doas apk update
        doas apk upgrade

        if [ -f /usr/bin/fwupdmgr ]; then
            doas fwupdmgr get-devices
            doas fwupdmgr refresh
            doas fwupdmgr get-updates
            doas fwupdmgr update
        fi

        if [ -f /opt/google/chrome/chrome ]; then
            update_google_chrome
        fi

        if [ -f /etc/profile.d/nvidia.sh ]; then
            nvidia
        fi

        if [ -f /etc/profile.d/zfs.sh ]; then
            update_zfs
        fi

        if [ -f /etc/profile.d/gummiboot.sh ]; then
            gummiboot
        fi

    fi

}
