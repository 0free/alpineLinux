#!/bin/ash

version=''

install_zfs() {

    if ! lsmod | grep -q zfs; then

        printf '%s\n' '❯ installing zfs-src'
        set -- zfs-src autoconf automake util-linux-dev linux-virt-dev portablexdr-dev libtirpc-dev musl-libintl musl-dev
        doas apk add $@

        printf '%s\n' '❯ autogen.sh'
        cd /usr/src/zfs/ && doas ash autogen.sh
        printf '%s\n' '❯ ./configure'
        cd /usr/src/zfs/ && doas ./configure
        printf '%s\n' '❯ make distclean'
        cd /usr/src/zfs/ && doas make distclean
        printf '%s\n' '❯ making zfs'
        cd /usr/src/zfs/ && doas make -s -j$(nproc)
        printf '%s\n' '❯ installing zfs'
        cd /usr/src/zfs/ && doas make install

        for k in $(ls /lib/modules/ | grep [0-9]); do
            if printf $k | grep -q '.*-.*-.*'; then
                k=$(printf $k | sed 's|.*-||')
            else
                kernel=$k
            fi
            printf '%s\n' "❯ building linux-$k initial ramdisk"
            doas mkinitfs -b / -c /etc/mkinitfs/mkinitfs.conf -f /etc/fstab -o /boot/initramfs-$k $kernel
        done

        doas sed -i "s|^version='.*'|version='$current'|" /etc/profile.d/zfs.sh

        printf '%s\n' '❯ removing zfs-src'
        #doas apk del zfs-src

    fi

}

update_zfs() {

    current=$(apk search -e zfs-src)
    if ! grep -q $current /etc/profile.d/zfs.sh; then
        install_zfs
    else
        printf '%s\n' '❯ zfs is up-to-date'
    fi

}