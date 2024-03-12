#!/bin/ash

get_kernel_version() {

    export version=$(grep '^VERSION = ' $1 | grep -Eo '[0-9]+')
    export patchLevel=$(grep '^PATCHLEVEL = ' $1 | grep -Eo '[0-9]+')
    export subLevel=$(grep '^SUBLEVEL = ' $1 | grep -Eo '[0-9]+')

    if [ $subLevel = 0 ]; then
        export kernel="$version.$patchLevel"
    else
        export kernel="$version.$patchLevel.$subLevel"
    fi

    if grep '^EXTRAVERSION =' $1 | grep -qEo 'rc[0-9]+'; then
        export extraVersion=$(grep '^EXTRAVERSION =' $1 | grep -Eo '\-rc[0-9]+')
        export kernel="$kernel$extraVersion"
    else
        export extraVersion=''
    fi

    rm $1

}

kernel() {

    if curl -so /dev/null git.kernel.org; then

        makefile='https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/Makefile'

        printf '%s\n' '❯ getting linux kernel Torvalds release'
        url="$makefile"
        curl -so ~/Makefile $url
        get_kernel_version ~/Makefile
        set -- "build linux-$kernel Torvalds"

        makefile='https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/Makefile'

        printf '%s\n' '❯ getting linux kernel mainline release'
        url="$makefile"
        curl -so ~/Makefile $url
        get_kernel_version ~/Makefile
        set -- "$@" "build linux-$kernel mainline"

        printf '%s\n' '❯ getting linux kernel stable release'
        if printf $kernel | grep -q '\-rc'; then
            patchLevel=$((patchLevel-1))
        fi
        url="$makefile?h=linux-$version.$patchLevel.y"
        curl -so ~/Makefile $url
        get_kernel_version ~/Makefile
        set -- "$@" "build linux-$kernel stable"

        printf '%s\n' '❯ getting linux kernel rolling release'
        url="$makefile?h=linux-rolling-stable"
        curl -so ~/Makefile $url
        get_kernel_version ~/Makefile
        set -- "$@" "build linux-$kernel rolling"

        printf '%s\n' '❯ getting linux kernel LTS release'
        url="$makefile?h=linux-rolling-lts"
        curl -so ~/Makefile $url
        get_kernel_version ~/Makefile
        set -- "$@" "build linux-$kernel LTS"

    fi

    for k in $(find /boot/initramfs-* | sed 's|/boot/initramfs-||'); do
        if printf $k | grep -Eq '^[1-9]'; then
            set -- "$@" "delete linux-$k"
        fi
    done

    menu 'select' choice "$@"

    kernel=$(printf "$choice" | sed 's|.* linux-||' | sed 's| .*||')
    version=$(printf $kernel | grep -Eo '^[0-9]+')
    patchLevel=$(printf $kernel | sed "s|$version.||" | grep -Eo '^[0-9]+')
    subLevel=$(printf $kernel | sed "s|$version.$patchLevel||" | sed 's|\-.*||' | grep -Eo '[0-9]+' || printf 0)

    if printf $kernel | grep -q '\-rc'; then
        extraVersion=$(printf $kernel | sed 's|.*-|-|')
        file="linux-$kernel.tar.gz"
        url="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/$file"
    else
        file="linux-$kernel.tar.xz"
        url="https://cdn.kernel.org/pub/linux/kernel/v$version.x/$file"
        extraVersion=''
    fi

    if printf "$choice" | grep -q 'build linux-'; then

        if [ ! -d ~/linux-$kernel/ ]; then
            if [ ! -f ~/$file ]; then
                printf '%s\n' "❯ downloading linux-$kernel src"
                curl -o ~/$file $url
            fi
            if [ -f ~/$file ]; then
                printf '%s\n' "❯ extracting linux-$kernel src"
                tar -xaf ~/$file -C ~/ && rm ~/$file
            fi
        fi

        if [ -d ~/linux-$kernel ]; then

            printf '%s\n' '❯ installing required packages'
            set -- linux-headers elfutils-dev openssl-dev bison flex
            doas apk add $@

            printf '%s\n' "❯ configuring linux-$kernel"
            if [ -f ~/linux-$kernel/.config ]; then
                cp ~/linux-$kernel/.config ~/config-linux-$kernel
            else
                url="https://raw.githubusercontent.com/0free/linux/6/config-linux-$kernel"
                if curl -so /dev/null $url; then
                    curl -so ~/linux-$kernel/.config $url
                else
                    cd ~/linux-$kernel/ && make -j$(nproc) prepare
                fi
            fi

            cd ~/linux-$kernel/ && make -j$(nproc) menuconfig

            printf '%s\n' "❯ making linux-$kernel"
            cd ~/linux-$kernel/ && doas make -j$(nproc) ARCH=x86_64

            kernelVersion="$version.$patchLevel.$subLevel$extraVersion"

            printf '%s\n' "❯ deleting /lib/modules/linux-$kernelVersion/"
            doas rm -rf /lib/modules/linux-$kernelVersion/

            printf '%s\n' "❯ installing linux-$kernel modules"
            cd ~/linux-$kernel/ && doas make -j$(nproc) ARCH=x86_64 modules_install
            cd ~

            printf '%s\n' "❯ shortcuts"
            doas rm -rf /lib/modules/$kernelVersion/build
            doas rm -rf /lib/modules/$kernelVersion/source
            doas ln -sf /lib/modules/$kernelVersion/build /usr/src/linux-headers-$kernel

            printf '%s\n' "❯ adding linux-headers shortcuts"
            doas ln -sf /usr/src/linux-headers-$kernel /lib/modules/$kernelVersion/build

            printf '%s\n' "❯ copying vmlinuz image"
            doas cp ~/linux-$kernel/.config /boot/config-$kernelVersion
            doas cp ~/linux-$kernel/System.map /boot/System.map-$kernelVersion
            doas cp ~/linux-$kernel/arch/x86_64/boot/bzImage /boot/vmlinuz-$kernelVersion

            printf '%s\n' "❯ making linux-$kernel initial ramdisk"
            doas mkinitfs -b / -c /etc/mkinitfs/mkinitfs.conf -f /etc/fstab -o /boot/initramfs-$kernelVersion $kernelVersion

            printf '%s\n' "❯ installing linux-$kernel-headers"
            doas rm -rf /usr/src/linux-headers-$kernel/
            cd ~/linux-$kernel/ && doas make headers_install ARCH=x86_64 INSTALL_HDR_PATH=/usr/src/linux-headers-$kernel

            printf '%s\n' "❯ deleting linux-$kernel src"
            #doas rm -r ~/linux-$kernel/

            if [ ! -f /boot/loader/entries/linux-$kernelVersion.conf ]; then
                printf '%s\n' "❯ adding gummiboot entry"
                cat > ~/linux-$kernelVersion.conf <<EOF
title linux-$kernelVersion
architecture x64
linux /vmlinuz-$kernelVersion
initrd /initramfs-$kernelVersion
EOF
                for file in /boot/loader/entries/linux-*.conf; do
                    if grep -qh '^options ' $file; then
                        set -- $(grep -h '^options ' $file)
                        printf '%s' "$*" >> ~/linux-$kernelVersion.conf
                        break
                    fi
                done
                doas cp ~/linux-$kernelVersion.conf /boot/loader/entries/
                rm ~/linux-$kernelVersion.conf
            fi

        fi

    fi

    if printf "$choice" | grep -q 'delete linux-*'; then
        kernel=$(printf "$choice" | sed 's|delete linux-||')
        printf '%s\n' "❯ deleting linux-$kernel"
        doas rm -f /boot/*-$kernel
        doas rm -f /boot/loader/entries/linux-$kernel.conf
        doas rm -rf /lib/modules/$kernel/
        kernel=$(printf "$kernel" | sed 's|.0-|-|')
        doas rm -rf /usr/src/linux-headers-$kernel/
        doas rm -rf ~/linux-$kernel/
    fi

    printf '%s\n' "❯ cleaning packages"
    #doas apk del $@

    unset version
    unset patchLevel
    unset subLevel
    unset extraVersion
    unset kernel
    unset url

}