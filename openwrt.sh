#!/bin/ash

openwrt() {

    if curl -so /dev/null alpinelinux.org; then
        if [ -d ~/openwrt ]; then
            cd ~/openwrt && git pull
            cd ~/openwrt && ./scripts/feeds update -a
            cd ~/openwrt && ./scripts/feeds install -a
            cd ~/openwrt && make -j$(nproc) menuconfig
            cd ~/openwrt && make -j$(nproc)
        else
            git clone -b master https://git.openwrt.org/openwrt/openwrt.git ~/openwrt/
            printf '%s\n' 'src-git packages https://git.openwrt.org/feed/packages.git' > ~/openwrt/feeds.conf
            printf '%s\n' 'src-git luci https://git.openwrt.org/project/luci.git' >> ~/openwrt/feeds.conf
            printf '%s\n' 'src-git targets https://github.com/openwrt/targets.git' >> ~/openwrt/feeds.conf
            set -- coreutils diffutils tar musl-libintl musl-fts-dev musl-obstack-dev argp-standalone
            doas apk add $@
            openwrt
        fi
    fi

}
