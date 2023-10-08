#!/bin/ash

version=''

nvidia() {

    if find /lib/modules/ -type f -name nvidia.ko.gz | grep -q nvidia; then
        if grep -q $(apk search -e nvidia-src) /etc/profile.d/nvidia.sh; then
            printf '%s\n' '❯ nvidia driver is up-to-date'
        else
            install_modules
        fi
    else
        install_modules
    fi

}

install_modules() {

    printf '%s\n' '❯ installing nvidia-src'
    doas apk add nvidia-src

    printf '%s\n' '❯ building nvidia kernel modules'
    make modules -j$(nproc) TARGET_ARCH=x86_64

    printf '%s\n' '❯ installing nvidia kernel modules'
    doas make modules_install -j$(nproc) TARGET_ARCH=x86_64

    if ! grep -q 'nvidia' /etc/mkinitfs/mkinitfs.conf; then
        printf '%s\n' '❯ adding nVidia kernel modules'
        modules=' nvidia nvidia_modeset nvidia_uvm nvidia_drm nvidia_peermem'
        doas sed -i "s|\"$| $modules\"|" /etc/mkinitfs/mkinitfs.conf
    fi

    for k in $(ls /lib/modules/ | grep [0-9]); do
        if printf $k | grep -q '.*-.*-.*'; then
            k=$(printf $k | sed 's|.*-||')
        else
            kernel=$k
        fi
        printf '%s\n' "❯ building linux-$k initial ramdisk"
        doas mkinitfs -b / -c /etc/mkinitfs/mkinitfs.conf -f /etc/fstab -o /boot/initramfs-$k $kernel
    done

    doas sed -i "s|^version='.*'|version='$(apk search -e nvidia-src)'|" /etc/profile.d/nvidia.sh

    printf '%s\n' '❯ removing nvidia-src'
    doas apk del nvidia-src

}
