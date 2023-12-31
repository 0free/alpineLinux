#!/bin/ash

timezone='Asia/Muscat'
ZFSpool='rpool'
mirror='https://uk.alpinelinux.org/alpine'

packages_list() {

    packages="
        #musl
        musl musl-dev musl-utils musl-fts musl-fts-dev musl-obstack musl-obstack-dev musl-nscd musl-nscd-dev musl-nscd-openrc musl-legacy-error
        #glibc
        gcompat
        #dbus
        dbus dbus-openrc dbus-libs dbus-x11 dbus-glib
        #ibus
        openrc-settingsd openrc-settingsd-openrc
        #udev
        udev-init-scripts udev-init-scripts-openrc
        #eudev
        eudev eudev-openrc eudev-libs
        #mesa
        mesa-dri-gallium
        #polkit/elogind
        polkit-openrc polkit-common polkit-elogind polkit-elogind-libs
        elogind elogind-openrc elogind-common
        #input
        xf86-input-evdev xf86-input-mtrack xf86-input-synaptics
        #base
        doas fakeroot file
        g++ gcc libc-dev patch make autoconf sed attr dialog which grep gawk pciutils usbutils findutils readline lsof less curl wget
        #bash
        bash bash-completion
        #util-linux
        util-linux util-linux-openrc util-linux-login util-linux-misc runuser
        #utilities
        openssl ncurses-dev
        #git
        git
        #compression
        brotli-libs zstd zlib zip lz4 lzo unzip xz bzip2 gzip
        #disks
        e2fsprogs gptfdisk dosfstools mtools
        ntfs-3g ntfs-3g-progs
        xfsprogs hfsprogs exfatprogs f2fs-tools
        udftools sfdisk sgdisk mmc-utils jfsutils
        udisks2
        #rsync
        rsync rsync-openrc
        #network
        networkmanager networkmanager-openrc
        networkmanager-common
        networkmanager-elogind
        #firewall
        nftables nftables-openrc
        firewalld firewalld-openrc
        #pipewire
        pipewire pipewire-libs pipewire-alsa pipewire-jack pipewire-pulse pipewire-tools pipewire-spa-tools pipewire-spa-vulkan pipewire-spa-bluez wireplumber
        #alsa
        alsaconf alsa-lib alsa-utils alsa-utils-openrc
        alsa-plugins-pulse alsa-plugins-jack alsa-ucm-conf 
        #bluetooth
        bluez-alsa bluez-alsa-openrc bluez-alsa-utils
        #intel-hda
        sof-firmware sof-bin
        #fonts
        font-cursor-misc font-misc-misc
        font-freefont font-noto-arabic
        font-liberation font-xfree86-type1
        font-cantarell
        #timezone
        tzdata
        #efi
        efibootmgr
        #reboot
        kexec-tools
        #process
        psmisc
        #apparmor
        apparmor apparmor-openrc apparmor-utils apparmor-pam
        "

    if grep -q btrfs /root/list; then
        packages="$packages
        #btrfs
        btrfs-progs btrfs-progs-extra btrfs-progs-libs
        snapper
        "
    fi

    if ! grep -q virtual /root/list; then
        packages="$packages
        #hardware
        bolt pciutils
        #firmware
        fwupd fwupd-openrc fwupd-efi
        #mesa
        mesa
        mesa-dri-gallium mesa-va-gallium mesa-vdpau-gallium
        mesa-gl mesa-glapi mesa-egl mesa-gles mesa-gbm
        mesa-vulkan-layers mesa-libd3dadapter9
        #intel-GPU
        mesa-vulkan-intel intel-media-driver
        #vulkan
        vulkan-loader vulkan-validation-layers
        #wireless
        wireless-regdb iwd iwd-openrc
        #network
        networkmanager-wwan networkmanager-wifi
        networkmanager-initrd-generator
        "

        if grep -q gnome /root/list; then
            packages="$packages
            #firmware
            gnome-firmware-updater
            "
        fi
    fi

    if grep -q gnome /root/list; then
        packages="$packages
        #gnome session
        gdm gdm-openrc mutter mutter-schemas
        gnome-desktop gnome-desktop-lang gnome-session
        gnome-shell gnome-shell-schemas gnome-menus
        gnome-control-center
        gnome-tweaks gnome-colors-common gsettings-desktop-schemas
        tracker
        #connector
        chrome-gnome-shell gnome-browser-connector
        #theme
        adwaita-icon-theme hicolor-icon-theme
        #gnome tools
        gnome-console gnome-disk-utility gnome-system-monitor file-roller
        #nautilus
        nautilus
        #text
        gedit py3-cairo aspell-en hunspell-en nuspell
        #gnome theme
        arc-dark-gtk4
        #network
        network-manager-applet
        "
    fi

    if grep -q kde /root/list; then
        packages="$packages
        #sddm
        sddm sddm-openrc sddm-kcm sddm-breeze
        #plasma
        plasma-desktop
        plasma-workspace plasma-workspace-lang plasma-workspace-libs
        plasma-settings plasma-systemmonitor plasma-browser-integration
        plasma-thunderbolt plasma-disks plasma-firewall
        #system
        kwrited systemsettings ksysguard polkit-kde-agent-1
        #theme
        breeze breeze-gtk breeze-icons
        #bluetooth
        bluedevil
        #power
        powerdevil
        #wayland
        kwayland-integration
        #network
        plasma-nm
        #firewall
        iproute2 net-tools
        #audio
        plasma-pa kpipewire kmix
        #kde
        kdialog kscreen kmenuedit konsole
        kde-gtk-config khotkeys xdg-desktop-portal-kde
        #file-manager
        dolphin dolphin-plugins kfind
        #text
        kate kate-common hunspell-en
        #archive
        ark
        "
    fi

    if grep -q wayfire /root/list; then
        packages="$packages
        adwaita-icon-theme
        wayfire wcm wf-config waybar havoc
        "
    fi

    if ! grep -q 'no-desktop' /root/list; then
        packages="$packages
        #wine
        wine-staging wine-mono wine_gecko
        #razer
        openrazer-driver-dkms razergenie
        #printer
        cups cups-openrc cups-pdf bluez-cups
        #driver
        xinput gkraken ccid solaar
        razercfg razercfg-gui razergenie openrazer
        piper
        "
    fi

    if grep -q workstation /root/list; then

        if grep -q gnome /root/list; then
            packages="$packages
            #colord
            colord colord-gtk
            #gnome apps
            gnome-software gnome-software-plugin-apk
            gnome-photos gnome-music gnome-clocks gnome-contacts gnome-calculator gnome-maps
            gnome-logs gnome-remote-desktop gnome-screenshot gnome-boxes gnome-calendar
            gnome-sound-recorder gnome-font-viewer gnome-colors gnome-bluetooth gnome-podcasts
            gnome-characters gnome-builder gnome-shortwave getting-things-gnome sushi simple-scan
            #config
            dconf
            #web
            epiphany
            #documents
            evince evince-nautilus
            #photos
            gthumb eog shotwell
            #mail
            geary
            #sound
            gnome-metronome lollypop
            #other
            glade ghex baobab confy
            #bluetooth
            blueman
            #chromecast
            gnomecast
            "
        fi

        if grep -q kde /root/list; then
            packages="$packages
            #plasma
            plasma-camera plasma-videoplayer plasma-phonebook
            plasma-remotecontrollers
            #kde
            kinfocenter kactivities kcron
            kde-cli-tools shelf knetattach kmail ktorrent kdeconnect akregator kphotoalbum
            kdeedu-data kalk rocs calligra marble clip
            buho vvave communicator qrca step kmousetool krename
            kcolorchooser kunitconversion
            #widgets
            kconfigwidgets
            #print
            print-manager
            #screen
            spectacle kruler
            #image
            gwenview
            #audio
            krecorder juk kwave elisa
            #video
            ffmpegthumbs kmediaplayer kdenlive dragon haruna
            #YouTube
            plasmatube audiotube
            #camera
            kamera kamoso
            #spelling
            sonnet
            #office
            kcalc okular skanlite
            #input
            plasma-remotecontrollers
            #draw
            kolourpaint
            #math
            cantor kalgebra kig kmplot
            #music
            minuet
            #hex
            okteta
            "
        fi

        packages="$packages
        #shell
        starship
        #thumbnail
        ffmpegthumbnailer
        #mkimage
        abuild alpine-sdk apk-tools mkinitfs xorriso squashfs-tools
        #fonts-tools
        font-manager font-viewer
        #office
        libreoffice-base libreoffice-common libreoffice-writer
        libreoffice-math libreoffice-calc libreoffice-draw
        libreoffice-lang-en_us libreoffice-lang-ar
        #google
        google-authenticator
        #mail
        thunderbird
        #music
        amberol musescore mixxx
        #audio
        ardour tenacity calf calf-jack calf-lv2
        #video-edit
        shotcut pitivi x265
        #video-subtitle
        gaupol
        #book
        foliate
        #openvpn
        openvpn openvpn-openrc openvpn-auth-pam networkmanager-openvpn
        #openvc
        opencv py3-opencv
        #python
        black
        #JavaScript
        npm nodejs nodejs-current esbuild reason
        #code
        code-oss lapce codeblocks qt-creator
        #code-format
        prettier tidyhtml
        #html/css-to-pdf
        weasyprint
        #screenshot
        flameshot
        #electronic
        kicad
        #screen
        obs-studio kooha peek
        #video
        mplayer totem celluloid
        #photos
        krita gimp inkscape gmic curtail
        #finance
        homebank
        #2d
        tiled
        #3d
        blender freecad godot leocad solvespace goxel
        #3d-printer
        cura
        #text-editor
        kakoune
        #mauikit
        mauikit mauikit-accounts mauikit-filebrowsing
        mauikit-imagetools mauikit-texteditor
        #bitcoin
        bitcoin bitcoin-openrc
        #game-emu
        pcsx2 dolphin-emu xwiimote
        #rust
        rust rustfmt cargo
        #go
        go
        #android
        gradle android-tools
        go-mtpfs scrcpy
        #iPhone/iPod/mac
        ifuse ideviceinstaller idevicerestore libirecovery libirecovery-progs
        libideviceactivation libimobiledevice libimobiledevice-progs
        #pdf
        corepdf pdfarranger poppler
        #drives
        onedrive onedrive-openrc
        #Corsair
        ckb-next
        #RGB
        openrgb
        #plan
        planner
        #music-player
        amberol sublime-music
        #music-server
        navidrome navidrome-openrc
        #youtube
        ffmpeg yt-dlp pipe-viewer-gtk
        audiotube tartube youtube-viewer-gtk
        #javascript/css
        minify
        #photos
        darktable
        #drawing
        drawing
        #remote
        remmina
        #touch
        touchegg touchegg-openrc
        #CPU
        corectrl
        #cctv
        zoneminder zoneminder-openrc
        #iso
        thumbdrives
        #torrent
        transmission
        #sync
        syncthing syncthing-openrc syncthing-utils syncthing-gtk
        "

        if grep -q gnome /root/list; then
            packages="$packages
            libreoffice-gnome
            "
        fi

    fi

    if grep -Eq 'server|workstation' /root/list; then
        packages="$packages
        #php
        phpmyadmin composer
        php83-apache2 php83-bcmath php83-bz2 php83-calendar php83-cgi php83-common php83-ctype php83-curl php83-dba php83-dbg php83-dev php83-doc php83-dom php83-embed php83-enchant php83-exif php83-ffi php83-fileinfo php83-fpm php83-ftp php83-gd php83-gettext php83-gmp php83-iconv php83-imap php83-intl php83-ldap php83-litespeed php83-mbstring php83-mysqli php83-mysqlnd php83-odbc php83-opcache php83-openssl php83-pcntl php83-pdo php83-pdo_dblib php83-pdo_mysql php83-pdo_odbc php83-pdo_pgsql php83-pdo_sqlite php83-pear php83-pgsql php83-phar php83-phpdbg php83-posix php83-pspell php83-session php83-shmop php83-simplexml php83-snmp php83-soap php83-sockets php83-sodium php83-sqlite3 php83-sysvmsg php83-sysvsem php83-sysvshm php83-tidy php83-tokenizer php83-xml php83-xmlreader php83-xmlwriter php83-xsl php83-zip
        "
    fi

    if grep -q server /root/list; then
        packages="$packages
        #system
        rsyslog rsyslog-openrc rsyslog-mysql rsyslog-tls rsyslog-http
        #SSL/TLS
        certbot
        #database
        mariadb
        #mail
        postfix postfix-openrc postfix-mysql postfix-pcre postfixadmin
        dovecot dovecot-openrc dovecot-submissiond dovecot-ldap
        dovecot-lmtpd dovecot-pop3d dovecot-sql dovecot-mysql
        opendkim opendkim-utils
        cyrus-sasl
        #tools
        imagemagick redis redis-openrc memcached memcached-openrc
        #server
        litespeed litespeed-openrc
        #cab
        cabextract
        #ip
        ip2location
        #font
        font-awesome font-awesome-brands font-awesome-free
        "
    fi

}

menu() {

    printf '\n ❯❯ %s:\n\n' "$1"
    output=$2
    shift 2
    n=1
    while true; do
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
        printf -- '\e[%sA' $#
    done
    export "$output"="$c"

}

init_drive() {

    printf '%s\n' '❯ created by Saif AlSubhi'
    for i in $(seq 1 100); do printf -- '-%.0s' $i; done
    printf '\n'
    lsblk -o name,type,fstype,size,fsused,mountpoint,parttypename,label,model
    for i in $(seq 1 100); do printf -- '-%.0s' $i; done
    printf '\n'

    if [ ! -f /root/list ]; then
        printf "" > /root/list
    fi

    if ! grep -q 'drive=' /root/list; then
        set -- $(find /dev -name 'nvme[0-9]n[1-9]' -o -name 'sd[a-z]')
        menu 'select a drive' drive $@
        printf '%s\n' "drive=$drive" >> /root/list
        if find /dev | grep -Eq "$drive[p][1-9]|$drive[1-9]"; then
            set -- $(find $drive*)
            menu 'use the complete drive or select a root partition' partition $@
            if [ "$drive" -ne "$partition" ]; then
                rootDrive=$partition
                set -- $(find $drive*[1-9]* | grep -v $partition)
                if [ "$*" -ne "" ]; then
                    menu 'select a boot partition' bootDrive $@
                fi
                set -- $(find $drive*[1-9]* | grep-Ev "$rootDrive|$bootDrive")
                if [ "$*" -ne "''" ]; then
                    menu 'select a swap partition' swapDrive $@
                fi
            fi
        fi
    fi

    if ! grep -q 'swapSize=' /root/list; then
        set -- no-swap 2GiB 3GiB 4GiB 8GiB
        menu 'select swap partition size in MB' swapSize $@
        printf '%s\n' "swapSize=$swapSize" >> /root/list
    fi

    if ! grep -q 'filesystem=' /root/list; then
        set -- btrfs zfs xfs ext4
        menu 'select a filesystem' filesystem $@
        printf '%s\n' "filesystem=$filesystem" >> /root/list
    fi

}

init_system() {

    if ! grep -q 'computer=' /root/list; then
        set -- minimal miner server virtual workstation
        menu 'select a computer' computer $@
        printf '%s\n' "computer=$computer" >> /root/list
    fi

    if ! grep -q 'desktop=' /root/list; then
        set -- kde gnome wayfire no-desktop
        menu 'select a desktop' desktop $@
        printf '%s\n' "desktop=$desktop" >> /root/list
    fi

    if ! grep -q 'bootloader=' /root/list; then
        if [ "$filesystem" = zfs ]; then
            set -- gummiboot grub
        elif [ "$filesystem" = btrfs ]; then
            set -- gummiboot clover rEFInd grub
        else
            set -- gummiboot limine syslinux clover rEFInd grub
        fi
        menu 'select a bootloader' bootloader $@
        printf '%s\n' "bootloader=$bootloader" >> /root/list
    fi

    printf '\n'

}

init_user() {

    if ! grep -q 'user=' /root/list; then
        while ! printf '%s' $user | grep -Eiq '^[a-z_][-a-z0-9._-]*$'; do
            printf '❯ username: ' && read -r user
        done
        printf '%s\n' "user=$user" >> /root/list
    fi

    if ! grep -q 'password=' /root/list; then
        while ! printf '%s' $password | grep -Eiq '^[a-z0-9._-].{1,16}$'; do
            printf '❯ password: ' && read -r password
        done
        printf '%s\n' "password=$password" >> /root/list
    fi

    printf '\n'

}

setup_drive() {

    if ! df -Th | grep -v tmpfs | grep -q '/mnt'; then
        format_drive
    fi

    if ! df -Th | grep -v tmpfs | grep -q $rootDrive; then
        mount_root
    fi

    if ! df -Th | grep -v tmpfs | grep -q $bootDrive; then
        mount_boot
    fi

    if df -Th | grep -v tmpfs | grep -Eq "$rootDrive|$bootDrive"; then
        install_base
        change_root
    fi

}

format_drive() {

    if [ ! -f /usr/bin/sgdisk ]; then
        printf '%s\n' "❯ installing sgdisk"
        apk add sgdisk
    fi

    printf '%s\n' "❯ wiping filesystm"
    wipefs -a -f $drive
    printf '%s\n' "❯ deleting partitions"
    sgdisk -Z $drive
    printf '%s\n' "❯ creating GPT"
    sgdisk -o -U $drive

    printf '%s\n' "❯ creating boot partition"
    if grep -q virtual /root/list; then
        bootSize='100MiB'
    else
        bootSize='300MiB'
    fi
    sgdisk -n 0:0:+$bootSize -c 0:EFI -t 0:EF00 $drive
    i=1
    bootDrive=$(find $drive* | grep -E "$drive[$i]|$drive[p][$i]")
    printf '%s\n' "❯ creating boot filesystem"
    printf '%s\n' 'Y' | mkfs.vfat -F 32 -n BOOT $bootDrive
    sleep 1
    printf '%s\n' "bootDrive=$bootDrive" >> /root/list

    if printf '%s' $swapSize | grep -q GiB; then
        printf '%s\n' "❯ creating swap partition"
        sgdisk -n 0:0:+$swapSize -c 0:SWAP -t 0:8200 $drive
        i=$((i+1))
        swapDrive=$(find $drive* | grep -E "$drive[$i]|$drive[p][$i]")
        printf '%s\n' "❯ creating swap filesystem"
        mkswap $swapDrive
        printf '%s\n' "swapDrive=$swapDrive" >> /root/list
    fi

    printf '%s\n' "❯ creating root partition"
    if [ "$filesystem" = zfs ]; then
        sgdisk -n 0:0:0 -c 0:ZFS -t 0:BF00 $drive
    else
        sgdisk -n 0:0:0 -c 0:ROOT -t 0:8300 $drive
    fi
    i=$((i+1))
    rootDrive=$(find $drive* | grep -E "$drive[$i]|$drive[p][$i]")
    printf '%s\n' "rootDrive=$rootDrive" >> /root/list
    printf '%s\n' "❯ reading partitions"
    mdev -s && sleep 1

    printf '%s\n' "❯ creating root filesystem"
    if [ "$filesystem" = zfs ]; then
        create_zfs
    elif [ "$filesystem" = btrfs ]; then
        printf '%s\n' 'Y' | mkfs.btrfs  -f -L btrfs $rootDrive
    elif [ "$filesystem" = ext4 ]; then
        printf '%s\n' 'Y' | mkfs.ext4 -f -L ext4 $rootDrive
    elif [ "$filesystem" = xfs ]; then
        printf '%s\n' 'Y' | mkfs.xfs -f -L xfs $rootDrive
    fi

}

create_zfs() {

    if ! test zfs; then
        printf '%s\n' "❯ adding ZFS"
        apk add zfs zfs-libs
    fi
    zfs_modules='zcommon znvpair spl zavl zlua zunicode zzstd icp zfs'
    if ! lsmod | grep -qi zfs; then
        printf '%s\n' "❯ loading ZFS modules"
        modprobe -a "$zfs_modules"
        sleep 1
    fi
    if ! lsmod | grep -qi zfs; then
        printf '%s\n' 'ERROR: ZFS kernel module is missing'
        exit
    fi
    printf '%s\n' "❯ creating ZFS pool"
    zpool create -f -o ashift=12 -o \
    -o autotrim=on \
    -o cachefile=/etc/zfs/zpool.cache \
    -O logbias=throughput -O compression=lz4 \
    -O primarycache=metadata -O secondarycache=metadata -O sync=always \
    -O recordsize=8k -O dnodesize=8k \
    -O devices=off -O relatime=off -O atime=off -O normalization=formD \
    -O acltype=posixacl -O xattr=sa -O dedup=off \
    -O canmount=noauto -O mountpoint=/ -R /mnt $ZFSpool $rootDrive
    printf '%s\n' "❯ checking ZFS pool"
    zpool status
    set_zfs

}

set_zfs() {

    printf '%s\n' "❯ setting ZFS pool as rootfs"
    zpool set bootfs=$ZFSpool $ZFSpool
    printf '%s\n' "❯ setting ZFS cache"
    mkdir -p /mnt/etc/zfs/
    cp /etc/zfs/zpool.cache /mnt/etc/zfs/zpool.cache
    chmod a-w /mnt/etc/zfs/zpool.cache
    chattr +i /mnt/etc/zfs/zpool.cache
    printf '%s\n' "❯ adding ZFS options"
    mkdir -p /mnt/etc/modprobe.d/
    cat > /mnt/etc/modprobe.d/zfs.conf <<EOF
options zfs l2arc_noprefetch=0
options zfs l2arc_write_max=536870912
options zfs l2arc_write_boost=1073741824
options zfs l2arc_headroom=12
options zfs zfs_arc_max=536870912
options zfs zfs_arc_min=268435456
options zfs zfs_prefetch_disable=0
options zfs zfs_top_maxinflight=320
options zfs zfs_txg_timeout=15
options zfs zfs_vdev_scheduler=deadline
options zfs zfs_vdev_async_read_min_active=8
options zfs zfs_vdev_async_read_max_active=32
options zfs zfs_vdev_async_write_min_active=8
options zfs zfs_vdev_async_write_max_active=32
options zfs zfs_vdev_sync_write_min_active=8
options zfs zfs_vdev_sync_write_max_active=32
options zfs zfs_vdev_sync_read_min_active=8
options zfs zfs_vdev_sync_read_max_active=32
EOF

}

mount_root() {

    if grep -q zfs /root/list; then
        printf '%s\n' "❯ exporting zpool"
        zpool export $ZFSpool
        printf '%s\n' "❯ importing zpool"
        zpool import $ZFSpool -d $rootDrive -R /mnt
        printf '%s\n' "❯ mounting zfs dataset"
        zfs mount -a
    else
        printf '%s\n' "❯ mounting root drive"
        mount -t $filesystem $rootDrive /mnt
    fi
    if ! df -Th | grep -v tmpfs | grep -q '/mnt$'; then
        printf '%s\n' "ERROR: root drive is not mounted"
        exit
    fi
    mkdir -p /mnt/boot/

}

mount_boot() {

    if [ -f /lib/modules/"$(uname -r)"/kernel/fs/efivarfs/efivarfs.ko.gz ]; then
        printf '%s\n' "❯ loading efivarfs kernel module"
        modprobe efivarfs
    fi

    if [ -f /lib/modules/"$(uname -r)"/kernel/drivers/firmware/efi/efivars.ko.gz ]; then
        printf '%s\n' "❯ loading efivars kernel module"
        modprobe efivars
    fi

    printf '%s\n' "❯ mounting boot drive"
    mount -t vfat $bootDrive /mnt/boot
    mkdir -p /mnt/boot/efi/boot/

}

install_base() {

    printf '%s\n' "❯ creating repositories"
    cat > /etc/apk/repositories <<EOF
#$mirror/latest-stable/main
#$mirror/latest-stable/community
$mirror/edge/main
$mirror/edge/community
$mirror/edge/testing
EOF

    printf '%s\n' "❯ installing alpine-base"
    apk add --root=/mnt/ --initdb alpine-base --keys-dir /etc/apk/keys --repositories-file /etc/apk/repositories

    printf '%s\n' "❯ copying repositories"
    cp /etc/apk/repositories /mnt/etc/apk/

    printf '%s\n' "❯ adding CloudFlare DNS"
    cat > /mnt/etc/resolv.conf <<EOF
nameserver 1.0.0.1
EOF

    printf '%s\n' "❯ chmod 666 /dev/null"
    chmod 666 /mnt/dev/null

}

change_root() {

    printf '%s\n' "❯ copying install script"
    cp /root/list /mnt/root/
    cp /root/setup.sh /mnt/root/

    printf '%s\n' "❯ changing root"

    mount --bind /dev /mnt/dev
    mount --bind /sys /mnt/sys
    mount --bind /proc /mnt/proc
    mount --bind /run /mnt/run
    mount --bind /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars

    printf '%s' '0' > /mnt/root/chroot
    chroot /mnt /bin/ash /root/setup.sh

}

set_fstab() {

    printf '%s\n' "❯ setting fstab"

    entry="tmpfs /tmp tmpfs defaults,nosuid,nodev 0 0"
    printf '%s\n' "$entry" > /etc/fstab

    if grep -q zfs /root/list; then
        entry="#$ZFSpool / $filesystem rw,nodev,noauto,xattr,zfsutil,posixacl 0 1"
    elif grep -q btrfs /root/list; then
        entry="$(blkid $rootDrive -o export | grep ^UUID=) / $filesystem rw,ssd,nofail,discard=async,noatime,commit=64,autodefrag,compress=zstd:10 0 1"
    else
        entry="$(blkid $rootDrive -o export | grep ^UUID=) / $filesystem rw,ssd,nofail,discard=async,noatime,commit=64,autodefrag,compress=zstd:10 0 1"
    fi

    printf '%s\n' "$entry" >> /etc/fstab

    printf '%s\n' "$(blkid $bootDrive -o export | grep ^UUID=) /boot vfat rw,noatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro 0 2" >> /etc/fstab

    if grep -q swapDrive /root/list; then
        printf '%s\n' "$(blkid $swapDrive -o export | grep ^UUID=) none swap sw 0 0" >> /etc/fstab
    fi

    printf '%s' '1' > /root/chroot

}

install_linux() {

    if grep -q virtual /root/list; then
        list='linux-virt'
        if grep -q zfs /root/list; then
            list="$list zfs-virt"
        fi
    else
        if grep -q zfs /root/list; then
            list='linux-lts zfs-lts'
        else
            list='linux-lts linux-edge'
        fi
        if grep -m1 'model name' /proc/cpuinfo | grep -q 'AMD'; then
            list="$list amd-ucode"
        fi
        if grep -m1 'model name' /proc/cpuinfo | grep -q 'Intel'; then
            list="$list intel-ucode"
        fi
        #linux-tools
        list="$list cpupower cpupower-openrc linux-tools-gpio linux-tools-iio linux-tools-spi perf bpftool linux-tools-tmon linux-tools-usbip linux-tools-usbip-openrc"
    fi

    if grep -q zfs /root/list; then
        list="$list zfs zfs-openrc zfs-libs zfs-udev"
    fi

    printf '%s\n' "❯ installing linux"
    apk update
    apk fix
    apk add $list

    printf '%s' '2' > /root/chroot

}

install_packages() {

    printf '%s\n' "❯ packages list"
    packages_list
    list=''
    for p in $packages; do
        if ! printf $p | grep -q '^#'; then
            list="$list $p"
        fi
    done
    printf '%s\n' "❯ installing packages"
    apk update
    apk fix
    apk add $list

    printf '%s' '3' > /root/chroot

}

disable_root() {

    printf '%s\n' "❯ disabling root login"
    passwd -l root
    sed -i 's|:/bin/ash|:/sbin/nologin|' /etc/passwd

    printf '%s' '4' > /root/chroot

}

create_user() {

    if id $user >/dev/null 2>&1; then
        printf '%s\n' "❯ deleting $user"
        userdel -r $user
    fi
    printf '%s\n' "❯ adding wheel to doas"
    sed -i 's|# permit persist :wheel|permit persist :wheel|' /etc/doas.conf
    chmod 0400 /etc/doas.conf
    printf '%s\n' "❯ creating user"
    printf '%s\n%s\n' $password $password | adduser -h /home/$user -s /bin/ash -G wheel $user
    usermod -aG input,audio,video,netdev,usb,disk $user
    mkdir -p /var/mail/$user/
    HOME="/home/$user"
    mkdir -p $HOME/.config/autostart/
    mkdir -p $HOME/.local/

    printf '%s' '5' > /root/chroot

}

add_service() {

    run_level=$1
    shift 1
    for i in $@; do
        if [ -f /etc/init.d/$i ]; then
            rc-update -q add $i $run_level
        fi
    done

}

enable_services() {

    printf '%s\n' "❯ enabling services"
    #openrc
    add_service sysinit 'devfs procfs dmesg hwdrivers root'
    add_service boot 'modules cgroups mtab swap localmount sysctl hostname bootmisc networking machine-idntpd hwclock swclock'
    add_service default 'local'
    add_service shutdown 'mount-ro killprocs savecache'
    #busybox
    add_service sysinit 'mdev'
    add_service boot 'syslog'
    add_service default 'acpid crond'
    #rsyslog
    add_service boot 'rsyslog'
    #udev
    add_service sysinit 'udev udev-trigger udev-settle udev-postmount'
    #zfs
    add_service sysinit 'zfs-import zfs-mount'
    add_service boot 'zfs-share zfs-zed zfs-load-key'
    #apparmor
    add_service boot apparmor
    #seatd
    add_service boot 'seatd'
    #dbus
    add_service boot 'dbus'
    add_service default 'openrc-settingsd'
    #logind
    add_service default 'elogind'
    #polkit
    add_service default 'polkit'
    #musl
    add_service default 'nscd'
    #networkmanager
    add_service default 'networkmanager networkmanager-dispatcher'
    #firewall
    add_service default 'nftables firewalld'
    #alsa
    add_service default 'alsa'
    #bluez
    add_service default 'bluetooth bluealsa'
    #rsync
    add_service default 'rsyncd'
    #wireless
    add_service default 'iwd'
    #firmware
    add_service default 'fwupd'
    #login-manager
    add_service default 'gdm lightdm sddm'
    #linux-tools
    add_service default 'cpupower'
    add_service boot 'usbip'
    #printer
    add_service default 'cupsd'
    #database
    add_service default 'mariadb'
    #web-server
    add_service default 'litespeed'
    #mail-server
    add_service default 'postfix dovecot opendkim'
    #openvpn
    add_service default 'openvpn'
    #rpcbind
    add_service default 'rpcbind'
    #syncthing
    add_service default 'syncthing'

    printf '%s' '6' > /root/chroot

}

configure_alpine() {

    printf '%s\n' "❯ configuring openRC"

    sed -i 's|#unicode=.*|unicode="YES"|' /etc/rc.conf
    sed -i 's|#rc_parallel=.*|rc_parallel="YES"|' /etc/rc.conf
    sed -i 's|#rc_interactive=.*|rc_interactive="NO"|' /etc/rc.conf
    sed -i 's|#rc_shell=.*|rc_shell=/bin/sh|' /etc/rc.conf
    sed -i 's|#rc_depend_strict=.*|rc_depend_strict="NO"|' /etc/rc.conf
    sed -i 's|#rc_logger=.*|rc_logger="YES"|' /etc/rc.conf
    sed -i 's|#rc_env_allow=.*|rc_env_allow="*"|' /etc/rc.conf
    sed -i 's|#rc_hotplug=.*|rc_hotplug="!net.*"|' /etc/rc.conf
    sed -i 's|#rc_send_sighup=.*|rc_send_sighup="YES"|' /etc/rc.conf
    sed -i 's|#rc_timeout_stopsec=.*|rc_timeout_Stopsec="0"|' /etc/rc.conf
    sed -i 's|#rc_send_sigkill=.*|rc_send_sigkill="YES"|' /etc/rc.conf
    sed -i 's|rc_tty_number=.*|rc_tty_number=0|' /etc/rc.conf

    printf '%s\n' "❯ setting timezone"
    if [ -f /usr/share/zoneinfo/$timezone ]; then
        install -Dm 0644 /usr/share/zoneinfo/$timezone /etc/localtime
        printf '%s\n' $timezone > /etc/timezone
    fi

    printf '%s\n' "❯ setting hostname"
    printf '%s\n' 'alpineLinux' > /etc/hostname
    printf '%s\n' "127.0.0.1 localhost alpineLinux" > /etc/hosts
    printf '%s\n' "::1       localhost alpineLinux" >> /etc/hosts

    printf '%s\n' "❯ adding interfaces"
    cat > /mnt/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

auto wlan0
iface wlan0 inet dhcp
EOF

    printf '%s\n' "❯ configuring NetworkManager"
    if [ -d /etc/NetworkManager/ ]; then
        cat > /etc/NetworkManager/NetworkManager.conf <<EOF
[main]
dhcp=internal
plugins=ifupdown,keyfile
[ifupdown]
managed=true
[device]
wifi.backend=iwd
EOF
    fi

    printf '%s\n' "❯ configuring alpineLinux"

    rm -f /etc/profile.d/color_prompt.sh.disabled
    rm -f /etc/motd

    if [ -f /etc/conf.d/hwclock ]; then
        cat > /etc/conf.d/hwclock <<EOF
clock="local"
clock_hctosys="NO"
clock_systohc="YES"
clock_args=""
EOF
    fi

    printf '%s\n' "❯ setting locales"
    cat > /etc/locale.conf <<EOF
LANG=en_US.UTF-8
EOF

    cat > /etc/profile.d/locale <<EOF
export CHARSET=\${CHARSET:-UTF-8}
export LANG=\${LANG:-C.UTF-8}
export LC_COLLATE=\${LC_COLLATE:-C}
EOF

    if ! grep -q snd_seq /etc/modules; then
        printf '%s\n' snd_seq >> /etc/modules
    fi

    printf '%s\n' "❯ configuring pipewire"
    mkdir -p $HOME/.config/pipewire/
    cp /usr/share/pipewire/*.conf $HOME/.config/pipewire/

    printf '%s\n' "❯ disabling IPv6"
    printf '%s\n' 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/01-disable-ipv6.conf

    printf '%s\n' "❯ configuring firewalld"
    sed -i 's|^#.*||' /etc/firewalld/firewalld.conf

    printf '%s\n' "❯ setting ~/"
    chown -R $user:wheel $HOME/
    chown -R $user:wheel $HOME/.config/
    chmod -R 700 $HOME/
    chmod -R 700 $HOME/.config/

    printf '%s' '7' > /root/chroot

}

setup_desktop() {

    if [ -f /usr/bin/gnome-session ]; then
        run_session='/usr/bin/gnome-session'
        session='/usr/share/wayland-sessions/gnome-wayland.desktop'
    fi

    if [ -f /usr/bin/startplasma-wayland ]; then
        run_session='/usr/bin/startplasma-wayland'
        session='/usr/share/wayland-sessions/plasma.desktop'
    fi

    if [ -f /usr/bin/wayfire ]; then
        run_session='/usr/bin/wayfire'
        session='/usr/share/wayland-sessions/wayfire.desktop'
        printf '%s\n' "❯ downloading wayfire ini"
        url="https://raw.githubusercontent.com/0free/alpineLinux/edge/wayfire.ini"
        curl -so $HOME/.config/wayfire.ini $url
    fi

    if [ ! -d /usr/share/icons/windows-11-icons/ ]; then
        printf '%s\n' "❯ cloning Windows-11-icons"
        git clone https://github.com/0free/windows-11-icons.git $HOME/windows-11-icons/
        cp -r $HOME/windows-11-icons/* /usr/share/icons/
        rm -r $HOME/windows-11-icons/
    fi

    if grep -q gnome /root/list; then
        if [ ! -f $HOME/dconf-settings.ini ]; then
            printf '%s\n' "❯ downloading dconf-settings"
            curl -so $HOME/dconf.ini https://raw.githubusercontent.com/0free/alpineLinux/edge/dconf-settings.ini
            printf '%s\n' "❯ loading dconf-settings"
            dconf load / < $HOME/dconf.ini
            printf '%s\n' "❯ removing dconf-settings"
            rm $HOME/dconf.ini
        fi
    fi

    if grep -q kde /root/list; then
        mkdir -p /etc/sddm.conf.d/
        if [ ! -d $HOME/.config/kde.org/ ]; then
            printf '%s\n' "❯ cloning KDE settings"
            git clone https://github.com/0free/KDE-plasma.git $HOME/kde/
            printf '%s\n' "❯ configuring KDE"
            cp -r $HOME/kde/config/* $HOME/.config/
            cp -r $HOME/kde/local/* $HOME/.local/
            rm -r $HOME/kde/
        fi
    fi

    if [ -f /etc/sddm.conf ]; then
        cat > /etc/sddm.conf <<EOF
[Autologin]
User=$user
[Theme]
Current=breeze
EOF
    fi

    if [ -f /usr/bin/lightdm ]; then
        configure_lightdm
    fi

    printf '%s\n' "❯ adding session start"
    cat > /etc/local.d/session.start <<EOF
[ \$DISPLAY = '' ] && export DISPLAY=:0
[ \$WAYLAND_DISPLAY = '' ] && export WAYLAND_DISPLAY=wayland-0
[ \$XDG_SESSION_TYPE = '' ] && export XDG_SESSION_TYPE=wayland
[ \$QT_QPA_PLATFORM = '' ] && export QT_QPA_PLATFORM=wayland
[ \$XDG_RUNTIME_DIR = '' ] && export XDG_RUNTIME_DIR=/run/user/$(id -u $user)
. /etc/profile
EOF

    chmod 0755 /etc/local.d/session.start

    printf '%s\n' "❯ wayland environment"
    cat > /etc/environment <<EOF
XDG_SESSION_TYPE=wayland
GDK_BACKEND=wayland
QT_QPA_PLATFORM=wayland-egl
QT_WAYLAND_FORCE_DPI=physical
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
MOZ_ENABLE_WAYLAND=1
EOF

    printf '%s' '8' > /root/chroot

}

configure_lightdm() {

    printf '%s\n' "❯ configuring lightdm"
    if grep -q xfce /root/list; then
        sed -i 's|#autologin-session=.*|autologin-session=/usr/share/xsessions/xfce.desktop|' /etc/lightdm/lightdm.conf
    fi
    sed -i "s|auth.*sufficient.*|auth sufficient pam_succeed_if.so user ingroup nopasswdlogin|" /etc/pam.d/lightdm
    sed -i "s|#allow-guest=.*|allow-guest=false|" /etc/lightdm/lightdm.conf
    sed -i "s|#autologin-guest=.*|autologin-guest=false|" /etc/lightdm/lightdm.conf
    sed -i "s|#autologin-user=.*|autologin-user=$user|" /etc/lightdm/lightdm.conf
    sed -i "s|#autologin-user-timeout=.*|autologin-user-timeout=0|" /etc/lightdm/lightdm.conf
    sed -i "s|#autologin-in-background=.*|autologin-in-background=false|" /etc/lightdm/lightdm.conf
    sed -i "s|#user-session=.*|user-session=default|" /etc/lightdm/lightdm.conf
    sed -i "s|#greeter-session=.*|greeter-session=lightdm-gtk-greeter|" /etc/lightdm/lightdm.conf

}

add_scripts() {

    if ! grep -q virtual /root/list; then
        build_zfs
        install_nvidia
    fi

    custom_kernel
    google_chrome
    install_lutris

    if grep -q server /root/list; then
        setup_mariadb
        install_webserver
    elif grep -q miner /root/list; then
        install_miner
    else
        create_iso
        install_office
        openwrt
    fi

    printf '%s' '9' > /root/chroot

    setup_bootloader

}

build_zfs() {

    printf '%s\n' "❯ downloading zfs-src script"
    url='https://raw.githubusercontent.com/0free/alpineLinux/edge/zfs.sh'
    curl -so /etc/profile.d/zfs.sh $url

}

install_nvidia() {

    printf '%s\n' "❯ downloading nvidia-src script"
    url='https://raw.githubusercontent.com/0free/alpineLinux/edge/nvidia.sh'
    curl -so /etc/profile.d/nvidia.sh $url

}

custom_kernel() {

    printf '%s\n' "❯ downloading kernel script"
    url='https://raw.githubusercontent.com/0free/alpineLinux/edge/kernel.sh'
    curl -so /etc/profile.d/kernel.sh $url

}

google_chrome() {

    printf '%s\n' "❯ downloading google-chrome script"
    url='https://raw.githubusercontent.com/0free/alpineLinux/edge/google-chrome.sh'
    curl -so /etc/profile.d/google-chrome.sh $url

}

install_lutris() {

    printf '%s\n' "❯ downloading lutris script"
    url='https://raw.githubusercontent.com/0free/alpineLinux/edge/lutris.sh'
    curl -so /etc/profile.d/lutris.sh $url

}

setup_mariadb() {

    printf '%s\n' "❯ setting mariadb"
    mkdir -p /var/lib/mysql/
    chown -R mysql:mysql /var/lib/mysql/
    mkdir -p /var/log/mysql/
    chown -R mysql:mysql /var/log/mysql/
    /etc/init.d/mariadb setup
    printf '%s\n' "❯ adding mariadb script"
    cat > /etc/profile.d/mariadb.sh <<EOF
#!/bin/ash
install_db() {
    /etc/init.d/mariadb setup
    /usr/bin/mysql_install_db --defaults-file=/var/mysql.cnf
}
EOF

}

install_webserver() {

    mkdir -p /web/server/

    cat > /etc/profile.d/qwik.sh <<EOF
#!/bin/ash
install-qwik() {
    doas mkdir -p /web/qwik/
    doas apk add npm
    doas apk add nodejs nodejs-current
    npm install -g qwik
    npm install -g create-qwik
    npm create qwik@latest
}
EOF

    cat > /etc/profile.d/nodeJS.sh <<EOF
#!/bin/ash
install-nodejs() {
    doas apk add nodejs nodejs-current
}
EOF

    cat > /web/server/app.js <<EOF
const https = require('https')
const path = require('path')
const fs = require('fs')
const hostname = '127.0.0.1'
const port = 443
const ssl = {
    key: fs.readFileSync('./ssl/key.pem'),
    cert: fs.readFileSync('./ssl/cert.pem'),
}
const server = https.createServer(ssl,function(req,res){
    res.statusCode = 200;
    res.setHeader('Content-Type','text/html')
    fs.readFile('./index.php',function(error,data){
        if(error){
            res.writeHead(404)
            res.write('file not found')
        }else{
            res.write(data)
        }
        res.end()
    })
})
server.listen(port,hostname,function(error){
    if(error){
        console.log('something went wrong',error)
    }else{
        console.log('server is listening on port ' + hostname + ':' + port)
    }
})
EOF

    cat > $HOME/.config/autostart/nodeJS.desktop <<EOF
[Desktop Entry]
Name=NodeJS
Type=Application
Exec=node /web/server/app.js
}
EOF

}

install_miner() {

    printf '%s\n' "❯ getting latest T-Rex release from github"
    version=$(curl -s https://api.github.com/repos/trexminer/T-Rex/releases/latest | grep '"tag_name":' | sed -E 's|.*"([^"]+)".*|\1|')

    if [ ! -f /usr/bin/t-rex ]; then
        printf '%s\n' "❯ downloading T-Rex $version"
        curl -o /root/trex.tar.gz https://trex-miner.com/download/t-rex-$version-linux.tar.gz
        printf '%s\n' "❯ extracting T-Rex $version"
        tar -xzf /root/trex.tar.gz t-rex -C /usr/bin/
        printf '%s\n' "❯ deleting T-Rex file"
        rm /root/trex.tar.gz
    fi

    if grep -q gnome /root/list; then
        cat > $HOME/.config/autostart/terminal.desktop <<EOF
[Desktop Entry]
Name=terminal
Type=Application
Exec=kgx -e t-rex -c ~/config
X-GNOME-Autostart-enabled=true
EOF
    fi

    if grep -q kde /root/list; then
        cat > $HOME/.config/autostart/konsole.desktop <<EOF
[Desktop Entry]
Name=konsole
Type=Application
Exec=konsole -e t-rex -c ~/config
EOF
    fi

    chmod +x $HOME/.config/autostart/*.desktop

    cat > /etc/profile.d/trex.sh << EOF
#!/bin/ash
version='$version'
trex() {
    if curl -so /dev/null alpinelinux.org; then
        if [ ! -f ~/config ]; then
            printf '%s\n' "❯ downloading t-rex config file"
            curl -o ~/config https://raw.githubusercontent.com/0free/t-rex/\$version/config
        fi
        update
        /usr/bin/t-rex -c ~/config
        xdg-open 127.0.0.1:8080
    fi
}
update_trex() {
    latest=\$(curl -s https://api.github.com/repos/trexminer/T-Rex/releases/latest | grep '"tag_name":' | sed -E 's|.*"([^"]+)".*|\1|')
    if ! grep -q '\$latest' /etc/profile.d/trex.sh; then
        printf '%s\n' "❯ downloading T-Rex \$latest"
        curl -o ~/trex.tar.gz trex-miner.com/download/t-rex-\$latest-linux.tar.gz
        printf '%s\n' "❯ extracting T-Rex \$latest"
        doas tar -xzf trex.tar.gz t-rex -C /usr/bin/
        doas sed -i "s|^version='.*'|version='\$latest'|" /etc/prfile.d/trex.sh
        printf '%s\n' "❯ deleting T-Rex file"
        rm ~/trex.tar.gz
    fi
}
EOF

}

create_iso() {

    printf '%s\n' "❯ addining iso script"
    url="https://raw.githubusercontent.com/0free/alpineLinux/edge/menu.sh"
    curl -so /etc/profile.d/menu.sh $url
    url="https://raw.githubusercontent.com/0free/alpineLinux/edge/iso.sh"
    curl -so /etc/profile.d/iso.sh $url

}

install_office() {

    printf '%s\n' "❯ addining office script"
    url="https://raw.githubusercontent.com/0free/alpineLinux/edge/options.sh"
    curl -so /etc/profile.d/options.sh $url
    url="https://raw.githubusercontent.com/0free/alpineLinux/edge/office.sh"
    curl -so /etc/profile.d/office.sh $url

}

openwrt() {

    printf '%s\n' "❯ downloading openwrt script"
    url="https://raw.githubusercontent.com/0free/alpineLinux/edge/openwrt.sh"
    curl -so /etc/profile.d/openwrt.sh $url

}

make_initramfs() {

    printf '%s\n' "❯ installing mkinitfs"
    modules=''
    for module in $(basename -a -s .modules /etc/mkinitfs/features.d/*.modules); do
        modules="$modules $module"
    done

    if grep -q virtual /root/list; then
        modules="$modules vboxvideo virtio-gpu vmvga vmwgfx"
    else
        modules="$modules intel_agp i915"
        modules="$modules amdgpu"
    fi

    printf '%s\n' "❯ configuring mkinitfs"
    printf '%s' "features=\"$modules \"" > /etc/mkinitfs/mkinitfs.conf

    for k in $(ls /lib/modules/ | grep [0-9]); do
        printf '%s\n' "❯ building linux $k initial ramdisk"
        mkinitfs -b / -c /etc/mkinitfs/mkinitfs.conf -f /etc/fstab -o /boot/initramfs-$(printf '%s' $k | sed 's|.*-||') $k
    done

    printf '%s' '10' > /root/chroot

}

setup_bootloader() {

    find_windows

    if grep -q zfs /root/list; then
        param="root=$ZFSpool"
    else
        param="root=$(blkid $rootDrive -o export | grep ^UUID=)"
    fi

    param="$param rootfstype=$filesystem rw loglevel=3 mitigations=off apparmor=1 security=apparmor"

    if [ -f /usr/libexec/fwupd/efi/fwupdx64.efi ]; then
        firmware_update
    fi

    if grep -q zfs /root/list; then
        install_ZFSBootMenu
    fi

    if grep -q gummiboot /root/list; then
        install_gummiboot
    elif grep -q syslinux /root/list; then
        install_syslinux
    elif grep -q limine /root/list; then
        install_limine
    elif grep -q grub /root/list; then
        install_grub
    elif grep -q rEFInd /root/list; then
        install_refind
    elif grep -q clover /root/list; then
        install_clover
    fi

    printf '%s' '11' > /root/chroot

}

find_windows() {

    printf '%s\n' "❯ looking for Windows"
    for d in /dev/*; do
        if [ ! -d $d ]; then
            if printf '%s' $d | grep -Eq '/dev/nvme[0-9]n[1-9]p1$|/dev/sd[a-z]1$'; then
                p=$d
                if [ "$p" -ne "$bootDrive" ]; then
                    mkdir -p /windows/
                    mount -r $p /windows/
                    if [ -f /windows/EFI/Microsoft/Boot/BCD ]; then
                        printf '%s\n' "❯ copying Windows Boot Manager"
                        cp -rlf /windows/* /boot/
                        windowsDrive=$d
                        windowsBoot=$p
                        printf '%s\n' "windowsDrive=$d" >> /root/list
                        printf '%s\n' "windowsBoot=$p" >> /root/list
                    fi
                    umount /windows/
                    if [ -d /windows/ ]; then
                        rm -r /windows/
                    fi
                fi
            fi
        fi
    done

}

firmware_update() {

    mkdir -p /boot/firmware/
    cp /usr/libexec/fwupd/efi/fwupdx64.efi /boot/firmware/
    version=$(apk search -e fwupd)
    cat > /etc/profile.d/fwupd.sh <<EOF
#!/bin/ash
version='$version'
update_firmware() {
    latest=\$(apk search -e fwupd)
    if ! grep -q \$latest /etc/profile.d/fwupd.sh; then
        doas cp /usr/libexec/fwupd/efi/fwupdx64.efi /boot/firmware/
        doas sed -i "s|^version='.*'|version='\$latest'|" /etc/profile.d/fwupd.sh
    else
        printf '%s\n' '❯ fwupd is up-to-date'
    fi
}
EOF

}

install_ZFSBootMenu() {

    cat > /etc/profile.d/ZFSBootMenu.sh << EOF
#!/bin/ash
version=''
ZFSBootMenu() {
    if curl -so /dev/null alpinelinux.org; then
        printf '%s\n' "❯ getting latest ZFSBootMenu release from github"
        latest=\$(curl -s https://api.github.com/repos/zbm-dev/zfsbootmenu/releases/latest | grep '"tag_name":' | sed -E 's|.*"([^"]+)".*|\1|')
        if [ ! -f /boot/ZFSBootMenu/bootx64.efi ]; then
            download_ZFSBootMenu
        fi
        if [ ! -f /boot/loader/entries/ZFSBootMenu.conf ]; then
            cat > /boot/loader/entries/ZFSBootMenu_EFI.conf <<END
title ZFSBootMenu EFI
END
            cat > /boot/loader/entries/ZFSBootMenu_release.conf <<END
title ZFSBootMenu
linux /vmlinux-bootmenu
initrd /initramfs-bootmenu.img
END
        fi
        if ! grep -q "\$latest" <<< \$version; then
            download_ZFSBootMenu
        fi
        doas sed -i "s|^version='.*'|version='\$latest'|" /etc/prfile.d/ZFSBootMenu.sh
    fi
}
download_ZFSBootMenu() {
    printf '%s\n' "❯ downloading ZFSBootMenu-\$latest EFI"
    curl -Lo /boot/ZFSBootMenu/bootx64.efi https://github.com/zbm-dev/zfsbootmenu/releases/download\$latest/zfsbootmenu-release-x86_64-\$latest-vmlinuz.EFI
    printf '%s\n' "❯ downloading ZFSBootMenu \$latest Release"
    curl -Lo ~/ZFSBootMenu.tar.gz https://github.com/zbm-dev/zfsbootmenu/releases/download/\$latest/zfsbootmenu-release-x86_64-\$latest.tar.gz
    printf '%s\n' "❯ extracting ZFSBootMenu \$latest"
    tar -xzf ~/ZFSBootMenu.tar.gz /zfsbootmenu-release-x86_64-\$latest/initramfs-bootmenu.img -C /boot/
    tar -xzf ~/ZFSBootMenu.tar.gz /zfsbootmenu-release-x86_64-\$latest/vmlinuz-bootmenu.img -C /boot/
    printf '%s\n' "❯ deleting tar.gz file"
    rm ~/ZFSBootMenu.tar.gz
}
EOF

}

install_gummiboot() {

    printf '%s\n' "❯ installing gummiboot"
    apk add gummiboot
    cp /usr/lib/gummiboot/gummibootx64.efi	/boot/efi/boot/bootx64.efi

    efibootmgr -c -d $drive -p 1 -t 0 -L 'gummiboot' -l '\efi\boot\bootx64.efi'

    printf '%s\n' "❯ adding entries to gummiboot"
    mkdir -p /boot/loader/entries/

    if [ "$windowsDrive" -ne '' ]; then
        cat > /boot/loader/entries/windows.conf <<EOF
title Windows
efi /EFI/Microsoft/Boot/BOOTMGFW.EFI
options "root=$(blkid $windowsBoot -o export | grep ^UUID=)"
EOF
    fi

    for i in $(find /boot/initramfs-* | sed 's|/boot/initramfs-||'); do
        entry="/boot/loader/entries/linux-$i.conf"
        cat > $entry <<EOF
title alpineLinux $i
linux /vmlinuz-$i
initrd /initramfs-$i
options $param
EOF
        if [ -f /boot/intel-ucode.img ]; then
            sed -i "s|vmlinuz-$i|vmlinuz-$i\ninitrd /intel-ucode.img|" $entry
        fi
        if [ -f /boot/amd-ucode.img ]; then
            sed -i "s|vmlinuz-$i|vmlinuz-$i\ninitrd /amd-ucode.img|" $entry
        fi
    done

    if [ -f /boot/fwupd/fwupdx64.efi ]; then
        printf '%s\n' "❯ adding fwupd to gummiboot"
        cat > /boot/loader/entries/fwupd.conf <<EOF
title firmware-update
efi /fwupd/fwupdx64.efi
EOF
    fi

    if [ -f /boot/ZFSBootMenu/zfsbootmenu.efi ]; then
        printf '%s\n' "❯ addding ZFSBootMenu to gummiboot"
        cat > /boot/loader/entried/ZFSBootMenu.conf <<EOF
title ZFSBootMenu
efi /boot/ZFSBootMenu/bootx64.efi
EOF
    fi

    if [ -f /boot/loader/entries/linux-lts.conf ]; then
        default='linux-lts.conf'
    fi
    if [ -f /boot/loader/entries/linux-virt.conf ]; then
        default='linux-virt.conf'
    fi
    cat >> /boot/loader/loader.conf <<EOF
default $default
timeout 1
console-mode auto
EOF

    version=$(apk search -e gummiboot)
    cat > /etc/profile.d/gummiboot.sh <<EOF
#!/bin/ash
version='$version'
gummiboot() {
    latest=\$(apk search -e gummiboot)
    if ! grep -q "\$latest" /etc/profile.d/gummiboot.sh; then
        doas install -Dm0711 /usr/lib/gummiboot/gummibootx64.efi /boot/efi/boot/bootx64.efi
        doas sed -i "s|^version='.*'|version='\$latest'|" /etc/profile.d/gummiboot.sh
    else
        printf '%s\n' "❯ gummiboot is up-to-date"
    fi
}
EOF

}

install_syslinux() {

    printf '%s\n' "❯ installing syslinux"
    apk add syslinux
    extlinux --install /boot
    dd bs=440 conv=notrunc count=1 if=/usr/share/syslinux/gptmbr.bin of=$drive

    cp /usr/share/syslinux/efi64/* /boot/efi/boot/
    mv /boot/efi/boot/syslinux.efi /boot/efi/boot/bootx64.efi

    efibootmgr -c -d $drive -p 1 -t 0 -L 'syslinux' -l '\efi\boot\bootx64.efi'

    printf '%s\n' "❯ configuring extlinux"
    sed -i "s|overwrite=1|overwrite=0|" /etc/update-extlinux.conf
    sed -i "s|root=.*|root=$(blkid $rootDrive -o export | grep ^UUID=)|" /etc/update-extlinux.conf

    cat > /boot/extlinux.conf <<EOF
timeout 1
prompt 1
MENU TITLE 'a l p i n e  L i n u x'
MENU AUTOBOOT 'booting in # seconds'
default 'alpineLinux LTS'
EOF

    if [ -f /boot/vmlinuz-virt ]; then
        cat >> /boot/extlinux.conf <<EOF
label 'alpineLinux virt'
      linux /vmlinuz-virt
      initrd /initramfs-virt
      append $param
EOF
    fi
    if [ -f /boot/vmlinuz-edge ]; then
        cat >> /boot/extlinux.conf <<EOF
label 'alpineLinux edge'
      linux /vmlinuz-edge
      initrd /initramfs-edge
      append $param
EOF
    fi
    if [ -f /boot/vmlinuz-lts ]; then
        cat >> /boot/extlinux.conf <<EOF
label 'alpineLinux LTS'
      linux /vmlinuz-lts
      initrd /initramfs-lts
      append $param
EOF
    fi

    cp /boot/extlinux.conf /boot/syslinux/syslinux.cfg

}

install_limine() {

    printf '%s\n' "❯ installing limine bootloader"
    apk add limine-x86_64
    cp /usr/share/limine/BOOTX64.EFI /boot/efi/boot/bootx64.efi

    efibootmgr -c -d $drive -p 1 -t 0 -L 'limine' -l '\efi\boot\bootx64.efi'

    version=$(apk search -e limine-x86_64)
    cat > /etc/profile.d/limine.sh <<EOF
#!/bin/ash
version='$version'
limine() {
    latest=\$(apk search -e limine-x86_64)
    if ! grep -q "\$latest" /etc/profile.d/limine.sh; then
        doas install -Dm0711 /usr/share/limine/BOOTX64.EFI /boot/efi/boot/bootx64.efi
        doas sed -i "s|^version='.*'|version='\$latest'|" /etc/profile.d/limine.sh
    else
        printf '%s\n' "❯ limine bootloader is up-to-date"
    fi
}
EOF

    cat > /boot/limine/limine.cfg <<EOF
DEFAULT_ENTRY=1
TIMEOUT=1
VERBOSE=no
TERM_WALLPAPER=boot:///background.png
TERM_BACKDROP=008080
:alpineLinux
    PROTOCOL=linux
    KERNEL_PATH=boot:///vmlinuz-lts
    CMDLINE=$param
    MODULE_PATH=boot:///initramfs-lts
:Windows
    PROTOCOL=chainload
    IMAGE_PATH=boot:///EFI/Microsoft/Boot/bootmgfw.efi
EOF

}

install_grub() {

    printf '%s\n' "❯ installing grub package"
    apk fix
    apk add grub grub-efi
    printf '%s\n' "❯ installing grub bootloader"
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id='GRUB' $drive

    mkdir -p /boot/grub/themes/

    if [ ! -d /boot/grub/themes/grub-theme/ ]; then
        printf '%s\n' "❯ cloning grub-theme"
        git clone https://github.com/0free/grub-theme.git $HOME/grub-theme/
        rm -r $HOME/grub-theme/.git/
        mv $HOME/grub-theme/ /boot/grub/themes/
    fi

    sed -i "s|CLASS=\".*\"|CLASS=\"--class \$( . /etc/os-release; printf '%s\n' \"$ID\")\"|" /etc/grub.d/10_linux
    sed -i "s|menuentry \'\$LABEL\'|menuentry \'\$LABEL\' --class efi|" /etc/grub.d/30_uefi-firmware

    cat > /etc/default/grub <<EOF
loglevel=0
GRUB_DEFAULT=0
GRUB_TIMEOUT=1
GRUB_SAVEDEFAULT=true
GRUB_DISABLE_RECOVERY=true
GRUB_THEME="/boot/grub/themes/grub-theme/theme.txt"
GRUB_DISABLE_OS_PROBER=false
GRUB_DISABLE_SUBMENU=y
GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX=""
GRUB_GFXMODE=1280x720,1920x1080,auto
EOF

    sed -i "s|GRUB_CMDLINE_LINUX=\"\"|GRUB_CMDLINE_LINUX=\"$param\"|" /etc/default/grub

    list="search"
    list="$list msdospart part_msdos part_gpt part_apple"
    list="$list usb usb_keyboard"
    list="$list linux chain btrfs xfs fat exfat ntfs"
    list="$list gfxterm gfxmenu"

    if grep -q zfs /root/list; then
        list="$list zfs zfscrypt zfsinfo"
        sed -i "s|rpool=.*|rpool=$ZFSpool|" /etc/grub.d/10_linux
        sed -i 's|stat -f -c %T /|printf '%s' zfs|' /usr/sbin/grub-mkconfig
    fi

    printf '\n%s\n' "GRUB_PRELOAD_MODULES=\"$list\"" >> /etc/default/grub

    printf '%s\n' "❯ making grub config"
    grub-mkconfig -o /boot/grub/grub.cfg

    printf '%s\n' "❯ checking grub-probe"
    grub-probe /
    grub-probe -t fs -d $rootDrive
    grub-probe -t fs_label -d $rootDrive

    printf '%s\n' "❯ creating Windows efi record"
    efibootmgr -c -d "$windowsDrive" -p 1 -t 0 -L "Windows" -l '\Boot\bootx64.efi'

}

install_refind() {

    printf '%s\n' "❯ installing rEFInd bootloader"
    apk add refind
    refind-install --yes --root /boot/rEFInd/
    cp /usr/share/refind/refind_x64.efi /boot/efi/boot/bootx64.efi

    printf '%s\n' "❯ copying rEFInd icons"
    mkdir -p /boot/rEFInd/icons/
    cp /usr/share/refind/icons/* /boot/rEFInd/

    efibootmgr -c -d $drive -p 1 -t 0 -L 'rEFInd' -l '\efi\boot\bootx64.efi'

    printf '%s\n' "❯ copying rEFInd drivers"
    mkdir -p /boot/rEFInd/drivers_x64/
    cp /usr/share/refind/drivers_x86_64/*.efi /boot/rEFInd/drivers_x64/
    printf '%s\n' "❯ downloading efifs drivers"
    version=$(curl -s https://api.github.com/repos/pbatard/efifs/releases/latest | grep '"tag_name":' | sed -E 's|.*"([^"]+)".*|\1|')
    curl -Lo /boot/rEFInd/drivers_x64/xfs_x64.efi https://github.com/pbatard/efifs/releases/download/$version/xfs_x64.efi
    curl -Lo /boot/rEFInd/drivers_x64/zfs_x64.efi https://github.com/pbatard/efifs/releases/download/$version/zfs_x64.efi

    printf '%s\n' "❯ configuring rEFInd bootloader"
    if [ "$windowsDrive" -ne '' ]; then
        uuid=$(blkid $windowsBoot -o export | grep ^UUID= | sed 's|UUID=||')
        cat >> /boot/rEFInd/refind.conf <<EOF
menuentry "Windows Boot Manager" {
    icon \rEFInd\icons\os_win8.png
    volume $uuid
    loader \EFI\Boot\bootx64.efi
    options ''
}
menuentry "Windows Boot" {
    icon \rEFInd\icons\os_win8.png
    volume $uuid
    loader \EFI\Microsoft\Boot\BOOTMGFW.EFI
    options ''
}
menuentry "Windows 11" {
    icon \rEFInd\icons\os_win8.png
    volume $uuid
    loader \Windows\Boot\EFI\bootmgfw.efi
    options ''
}
EOF
    fi

    uuid=$(blkid $bootDrive -o export | grep ^UUID= | sed 's|UUID=||')

    if [ -f /boot/initramfs-virt ]; then
        cat >> /boot/rEFInd/refind.conf <<EOF
menuentry "alpineLinux virt" {
    icon /rEFInd/icons/os_linux.png
    volume $uuid
    loader /vmlinuz-virt
    initrd /initramfs-virt
    options $param
}
EOF
    fi

    if [ -f /boot/initramfs-edge ]; then
        cat >> /boot/rEFInd/refind.conf <<EOF
menuentry "alpineLinux edge" {
    icon /rEFInd/icons/os_linux.png
    volume $uuid
    loader /vmlinuz-edge
    initrd /initramfs-edge
    options $param initrd=/amd-ucode.img initrd=/intel-ucode.img
}
EOF
    fi

    if [ -f /boot/initramfs-lts ]; then
        cat >> /boot/rEFInd/refind.conf <<EOF
menuentry "alpineLinux LTS" {
    icon /rEFInd/icons/os_linux.png
    volume $uuid
    loader /vmlinuz-lts
    initrd /initramfs-lts
    options $param initrd=/amd-ucode.img initrd=/intel-ucode.img
}
EOF
    fi

    sed -i 's|timeout 20|timeout 2|' /boot/rEFInd/refind.conf
    sed -i 's|#loglevel 1|loglevel 0|' /boot/rEFInd/refind.conf
    sed -i 's|#enable_mouse|enable_mouse|' /boot/rEFInd/refind.conf
    sed -i 's|#mouse_size 16|mouse_size 16|' /boot/rEFInd/refind.conf
    sed -i 's|#mouse_speed 4|mouse_speed 4|' /boot/rEFInd/refind.conf
    sed -i 's|#use_graphics_for .*|use_graphics_for osx,linux,windows|' /boot/rEFInd/refind.conf
    sed -i 's|#scan_driver_dirs .*|scan_driver_dirs /rEFInd/drivers_x64|' /boot/rEFInd/refind.conf
    sed -i 's|#scanfor|scanfor|' /boot/rEFInd/refind.conf
    sed -i 's|#extra_kernel_version_strings |extra_kernel_version_strings linux-lts,linux-edge,linux-virt,|' /boot/rEFInd/refind.conf

}

install_clover() {

    if [ ! -d $HOME/CloverBootLoader/ ]; then
        printf '%s\n' "❯ cloning CloverBootLoader"
        git clone https://github.com/0free/CloverBootLoader.git $HOME/CloverBootLoader/
        rm -r $HOME/CloverBootLoader/.git/
        printf '%s\n' "❯ copying clover bootloader"
        cp -rlf $HOME/CloverBootLoader/* /boot/
        rm -r $HOME/CloverBootLoader/
        printf '%s\n' "❯ downloading efifs drivers"
        version=$(curl -s https://api.github.com/repos/pbatard/efifs/releases/latest | grep '"tag_name":' | sed -E 's|.*"([^"]+)".*|\1|')
        curl -Lo /boot/efi/clover/drivers/off/btrfs_x64.efi https://github.com/pbatard/efifs/releases/download/$version/btrfs_x64.efi
        curl -Lo /boot/efi/clover/drivers/off/ntfs_x64.efi https://github.com/pbatard/efifs/releases/download/$version/ntfs_x64.efi
        curl -Lo /boot/efi/clover/drivers/off/xfs_x64.efi https://github.com/pbatard/efifs/releases/download/$version/xfs_x64.efi
        curl -Lo /boot/efi/clover/drivers/off/zfs_x64.efi https://github.com/pbatard/efifs/releases/download/$version/zfs_x64.efi
    fi
    efibootmgr -c -d $drive -p 1 -t 0 -L 'clover' -l '\efi\boot\bootx64.efi'

}

custom_commands() {

    printf '%s\n' "❯ downloading setup script"
    url='https://raw.githubusercontent.com/0free/alpineLinux/edge/setup.sh'
    curl -so /usr/local/bin/setup $url
    chmod 0711 /usr/local/bin/setup

    printf '%s\n' "❯ downloading disk script"
    url='https://raw.githubusercontent.com/0free/alpineLinux/edge/disk.sh'
    curl -so /usr/bin/disk $url
    chmod 0711 /usr/bin/disk

    printf '%s\n' "❯ downloading shell script"
    url='https://raw.githubusercontent.com/0free/alpineLinux/edge/shell.sh'
    curl -so /etc/profile.d/shell.sh $url

    printf '%s\n' "❯ downloading apk script"
    url='https://raw.githubusercontent.com/0free/alpineLinux/edge/apk.sh'
    curl -so /etc/profile.d/apk.sh $url

    cat > /etc/profile.d/commands.sh <<EOF
export LC_ALL='C.UTF-8'
if printf '%s' \$WAYLAND_DISPLAY | grep -q 'wayland-0'; then
    export GTK_IM_MODULE=ibus
fi
search() {
    apk search
}
install() {
    doas apk add
}
remove() {
    doas apk del
}
disk() {
    lsblk -o name,type,mountpoints,size,fsused,fsuse%,uuid,model
}
clean() {
    printf '%s\n' "❯ cleaning tmp"
    doas rm -rf /tmp/*
    doas rm -rf /var/tmp/*
    printf '%s\n' "❯ cleaning logs"
    doas rm -f /var/log/*
    printf '%s\n' "❯ cleaning files"
    doas find / ! -path './proc/*' -type f -iname 'readme' -o -iname 'readme.txt' -o -iname '*.md' -o -iname '*.rst' -o -iname 'license' -o -iname 'license.txt' -o -iname '*.license' -o -iname '*.docbook' -exec rm -f {} \;
    if [ ~/.*_history ]; then
        sort -u -o ~/.*_history ~/.*_history
    fi
EOF

    if grep -Eq 'grub|syslinux' /root/list; then
        cat >> /etc/profile.d/commands.sh <<EOF
}
EOF
    else
        cat >> /etc/profile.d/commands.sh <<EOF
    doas apk del grub* syslinux* *-doc
}
EOF
    fi

    if [ -f /usr/bin/yt-dlp ]; then
    cat >> /etc/profile.d/commands.sh <<EOF
youtube() {
    yt-dlp -o '~/%(title)s.%(ext)s' -f 'bv[vcodec~="^((he|a)vc|h26[45])"][height<=1080][fps<=60]+ba' --merge-output-format mp4 --downloader ffmpeg --external-downloader ffmpeg --external-downloader-args ffmpeg:'-ss 00:00:00 -to 03:00:00'
}
EOF
    fi

    cat >> /etc/profile.d/commands.sh <<EOF
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
EOF

    if [ -f /etc/profile.d/trex.sh ]; then
        cat >> /etc/profile.d/commands.sh <<EOF
        if [ -f /etc/profile.d/trex.sh ]; then
            trex
        fi
EOF
    fi

    if [ -f /etc/profile.d/gummiboot.sh ]; then
        cat >> /etc/profile.d/commands.sh <<EOF
        if [ -f /etc/profile.d/gummiboot.sh ]; then
            gummiboot
        fi
EOF
    fi

    if [ -f /etc/profile.d/limine.sh ]; then
        cat >> /etc/profile.d/commands.sh <<EOF
        if [ -f /etc/profile.d/limine.sh ]; then
            limine
        fi
EOF
    fi

    if [ -f /etc/profile.d/fwupd.sh ]; then
        cat >> /etc/profile.d/commands.sh <<EOF
        if [ -f /etc/profile.d/fwupd.sh ]; then
            update_firmware
        fi
EOF
    fi

    cat >> /etc/profile.d/commands.sh <<EOF
    fi
}
EOF

    printf '%s' '12' > /root/chroot

}

finish() {

    printf '%s\n' "❯ fixing /etc/profile.d/*.sh"
    sed -i 's|\r||g' /etc/profile.d/*.sh

    printf '%s\n' "❯ cleaning packages"
    apk del '*-doc'

    printf '%s\n' "❯ cleaning files"
    rm -rf /var/tmp/*
    find / ! -prune -type f -iname 'readme' -o -iname 'readme.txt' -o -iname '*.md' -o -iname 'license' -o -iname 'license.txt' -o -iname '*.license' -o -iname '*.docbook' -o -iname 'authors' -o -iname 'copying' -exec rm {} \;

    printf '%s\n' "❯ installation is completed"
    printf '%s' 'reboot' > /root/chroot

}

reboot() {

    printf '%s\n' "❯ un-mounting /mnt/*"
    for d in /mnt/run /mnt/sys /mnt/dev /mnt/proc /mnt/boot; do
        if df -Thx tmpfs | grep -q $d; then
            umount $d
        fi
    done

    printf '%s\n' "❯ cleaning /root/"
    rm -rf /mnt/root/*

    printf '%s\n' "❯ un-mounting /mnt"
    umount -R /mnt

    if df -Thx tempfs | grep -q zfs; then
        printf '%s\n' "❯ exporting ZFS pool"
        zpool export -a
    fi

    printf '%s\n' '--> press ENTER to reboot'
    printf '%s\n' '' | reboot -f || exit

}

set -e

if [ -f /mnt/lib/apk/db/lock ]; then
    rm /mnt/lib/apk/db/lock
fi

if [ -f /root/list ]; then
    drive=$(. /root/list; printf '%s' $drive)
    filesystem=$(. /root/list; printf '%s' $filesystem)
    bootDrive=$(. /root/list; printf '%s' $bootDrive)
    swapDrive=$(. /root/list; printf '%s' $swapDrive)
    rootDrive=$(. /root/list; printf '%s' $rootDrive)
    bootloader=$(. /root/list; printf '%s' $bootloader)
    windowsDrive=$(. /root/list; printf '%s' $windowsDrive)
    windowsBoot=$(. /root/list; printf '%s' $windowsBoot)
    user=$(. /root/list; printf '%s' $user)
    password=$(. /root/list; printf '%s' $password)
    HOME="/home/$user"
fi

if [ -f /mnt/root/chroot ]; then
    change_root
else
    if [ -f /root/chroot ]; then
        while true; do
            step=$(cat /root/chroot)
            case $step in
                '0') set_fstab;;
                '1') install_linux;;
                '2') install_packages;;
                '3') disable_root;;
                '4') create_user;;
                '5') enable_services;;
                '6') configure_alpine;;
                '7') setup_desktop;;
                '8') add_scripts;;
                '9') make_initramfs;;
                '10') setup_bootloader;;
                '11') custom_commands;;
                '12') finish;;
                'reboot') reboot;;
            esac
        done
    else
        if df -Th | grep -v tmpfs | grep -q /mnt; then
            if ! df -Th | grep -v tmpfs | grep -q /mnt/boot; then
                mount_boot
            fi
            install_base
            change_root
        else
            clear
            init_drive
            init_system
            init_user
            setup_drive
        fi
    fi
fi

#end