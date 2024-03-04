#!/bin/ash

f=/root/list
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
        #zsh
        zsh
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
        bcachefs-tools
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

    if grep -q btrfs $f; then
        packages="$packages
        #btrfs
        btrfs-progs btrfs-progs-extra btrfs-progs-libs
        snapper
        "
    fi

    if ! grep -q virtual $f; then
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
        if grep -q gnome $f; then
            packages="$packages
            #firmware
            gnome-firmware-updater
            "
        fi
    fi

    if grep -q gnome $f; then
        packages="$packages
        #gnome
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
        #gnome-tools
        gnome-console gnome-disk-utility gnome-system-monitor file-roller
        #nautilus
        nautilus
        #text
        gedit py3-cairo aspell-en hunspell-en nuspell
        #theme
        arc-dark-gtk4
        #network
        network-manager-applet
        "
    fi

    if grep -q kde $f; then
        packages="$packages
        #sddm
        sddm sddm-openrc sddm-kcm sddm-breeze
        #plasma
        plasma-desktop
        plasma-workspace plasma-workspace-lang plasma-workspace-libs
        plasma-settings plasma-systemmonitor plasma-browser-integration
        plasma-thunderbolt plasma-disks plasma-firewall
        #system
        kwrited systemsettings polkit-kde-agent-1
        #theme
        breeze breeze-gtk breeze-icons5
        #bluetooth
        bluedevil
        #power
        powerdevil
        #network
        plasma-nm
        #firewall
        iproute2 net-tools
        #audio
        plasma-pa kpipewire kmix
        #kde
        kdialog kscreen kmenuedit konsole
        kde-gtk-config xdg-desktop-portal-kde
        #file-manager
        dolphin dolphin-plugins kfind
        #text
        kate kate-common hunspell-en
        #archive
        ark
        "
    fi

    if grep -q hyprland $f; then
        packages="$packages
        lightdm lightdm-openrc lightdm-gtk-greeter
        hyprland hyprland-protocols
        waybar swaylock havoc
        "
    fi

    if ! grep -Eq "no-desktop|virtual|server" $f; then
        packages="$packages
        #wine
        wine-staging
        #razer
        razergenie razergenie openrazer
        razercfg razercfg-gui razercfg-openrc
        #printer
        cups cups-openrc cups-pdf bluez-cups
        #driver
        xinput gkraken ccid solaar
        piper
        "
    fi

    if grep -q workstation $f; then

        if grep -q gnome $f; then
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

        if grep -q kde $f; then
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

        if grep -q gnome $f; then
            packages="$packages
            libreoffice-gnome
            "
        fi

    fi

    if grep -Eq 'server|workstation' $f; then
        packages="$packages
        #php
        phpmyadmin composer
        php83-apache2 php83-bcmath php83-bz2 php83-calendar php83-cgi php83-common php83-ctype php83-curl php83-dba php83-dbg php83-dev php83-doc php83-dom php83-embed php83-enchant php83-exif php83-ffi php83-fileinfo php83-fpm php83-ftp php83-gd php83-gettext php83-gmp php83-iconv php83-imap php83-intl php83-ldap php83-litespeed php83-mbstring php83-mysqli php83-mysqlnd php83-odbc php83-opcache php83-openssl php83-pcntl php83-pdo php83-pdo_dblib php83-pdo_mysql php83-pdo_odbc php83-pdo_pgsql php83-pdo_sqlite php83-pear php83-pgsql php83-phar php83-phpdbg php83-posix php83-pspell php83-session php83-shmop php83-simplexml php83-snmp php83-soap php83-sockets php83-sodium php83-sqlite3 php83-sysvmsg php83-sysvsem php83-sysvshm php83-tidy php83-tokenizer php83-xml php83-xmlreader php83-xmlwriter php83-xsl php83-zip
        "
    fi

    if grep -q server $f; then
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
    lsblk -o name,type,fstype,size,fsused,mountpoint,parttypename,label,model | grep -E "^NAME|^nvme.*|sd.*"
    for i in $(seq 1 100); do printf -- '-%.0s' $i; done
    printf '\n'

    if [ ! -f list ]; then
        printf '%s\n' "" > list
    fi

    if ! grep -q 'drive=' list; then

        set -- $(find /dev -name 'nvme[0-9]n[1-9]' -o -name 'sd[a-z]')

        menu 'select a drive' drive $@

        printf '%s\n' "drive=$drive" >> list

        if find /dev | grep -Eq "$drive[p][1-9]|$drive[1-9]"; then

            set -- $(find $drive*)

            menu 'use this drive or select a root partition' partition $@

            if [ "$drive" -ne "$partition" ]; then

                rootDrive=$partition

                set -- $(find $drive*[1-9]* | grep -v $partition)

                if [ "$*" -ne "" ]; then
                    menu 'select a boot partition' bootDrive $@
                fi

                set -- $(find $drive*[1-9]* | grep-Ev "$rootDrive|$bootDrive")

                if [ "$*" -ne "" ]; then
                    menu 'select a recovery partition' recoveryDrive $@
                fi

                set -- $(find $drive*[1-9]* | grep-Ev "$rootDrive|$bootDrive|$recoveryDrive")

                if [ "$*" -ne "" ]; then
                    menu 'select a swap partition' swapDrive $@
                fi

            fi

        fi

    fi

    if ! grep -q 'swapSize=' list; then
        set -- no-swap 2GiB 4GiB 8GiB 16GiB
        menu 'select swap partition size' swapSize $@
        printf '%s\n' "swapSize=$swapSize" >> list
    fi

    if ! grep -q 'recoverySize=' list; then
        set -- no-recovery 2GiB 4GiB 8GiB
        menu 'select recovery partition size' recoverySize $@
        printf '%s\n' "recoverySize=$recoverySize" >> list
    fi

    if ! grep -q 'filesystem=' list; then
        set -- ext4 xfs bcachefs btrfs zfs
        menu 'select a filesystem' filesystem $@
        printf '%s\n' "filesystem=$filesystem" >> list
    fi

}

init_system() {

    if ! grep -q 'computer=' $f; then
        set -- minimal miner server virtual workstation
        menu 'select a computer' computer $@
        printf '%s\n' "computer=$computer" >> $f
    fi

    if ! grep -q 'desktop=' $f; then
        set -- kde gnome hyprland no-desktop
        menu 'select a desktop' desktop $@
        printf '%s\n' "desktop=$desktop" >> $f
    fi

    printf '\n'

}

init_user() {

    if ! grep -q 'user=' $f; then
        while ! printf '%s' $user | grep -Eiq '^[a-z_][-a-z0-9._-]*$'; do
            printf '❯ username: ' && read -r user
        done
        printf '%s\n' "user=$user" >> $f
    fi

    if ! grep -q 'password=' $f; then
        while ! printf '%s' $password | grep -Eiq '^[a-z0-9._-].{1,16}$'; do
            printf '❯ password: ' && read -r password
        done
        printf '%s\n' "password=$password" >> $f
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

    if printf '%s' $recoverySize | grep -q GiB; then
        if ! df -Th | grep -q "^$recoveryDrive"; then
            mount_recovery
        fi
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
    if grep -q virtual $f; then
        bootSize='100MiB'
    else
        bootSize='512MiB'
    fi

    sgdisk -n 0:0:+$bootSize -c 0:EFI -t 0:EF00 $drive

    i=1

    bootDrive=$(find $drive* | grep -E "$drive[$i]|$drive[p][$i]")

    printf '%s\n' "❯ creating boot filesystem"
    printf '%s\n' 'Y' | mkfs.vfat -F 32 -n BOOT $bootDrive
    sleep 1

    printf '%s\n' "bootDrive=$bootDrive" >> $f

    if printf '%s' $recoverySize | grep -q 'GiB'; then

        printf '%s\n' "❯ creating recovery partition"
        sgdisk -n 0:0:+ $recoverySize -c 0:RECOVERY -t 0:8300 $drive
        i=$((i+1))
        recoveryDrive=$(find $drive* | grep -E "$drive[$i]|$drive[p][$i]")
        printf '%s\n' "recoveryDrive=$recoveryDrive" >> list
        printf '%s\n' "❯ creating recovery filesystem"
        printf '%s\n' 'Y' | mkfs.ext4 -L RECOVERY $recoveryDrive

    fi

    if printf '%s' $swapSize | grep -q 'GiB'; then

        printf '%s\n' "❯ creating swap partition"
        sgdisk -n 0:0:+$swapSize -c 0:SWAP -t 0:8200 $drive
        i=$((i+1))
        swapDrive=$(find $drive* | grep -E "$drive[$i]|$drive[p][$i]")
        printf '%s\n' "❯ creating swap filesystem"
        mkswap $swapDrive
        printf '%s\n' "swapDrive=$swapDrive" >> $f
    
    fi

    printf '%s\n' "❯ creating root partition"

    if [ "$filesystem" = zfs ]; then
        sgdisk -n 0:0:0 -c 0:ZFS -t 0:BF00 $drive
    else
        sgdisk -n 0:0:0 -c 0:ROOT -t 0:8300 $drive
    fi

    i=$((i+1))

    rootDrive=$(find $drive* | grep -E "$drive[$i]|$drive[p][$i]")

    printf '%s\n' "rootDrive=$rootDrive" >> $f

    printf '%s\n' "❯ reading partitions"
    mdev -s && sleep 1

    printf '%s\n' "❯ creating root filesystem"

    if [ "$filesystem" = 'zfs' ]; then
        create_zfs
    elif [ "$filesystem" = 'becachefs' ]; then
        bcachefs format --compression=lz4 $rootDrive
    elif [ "$filesystem" = 'btrfs' ]; then
        printf '%s\n' 'Y' | mkfs.btrfs  -f -L btrfs $rootDrive
    elif [ "$filesystem" = 'ext4' ]; then
        printf '%s\n' 'Y' | mkfs.ext4 -L ext4 $rootDrive
    elif [ "$filesystem" = 'xfs' ]; then
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
    -O recordsize=16k -O dnodesize=16k \
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

    if grep -q zfs $f; then
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

mount_recovery() {

    mkdir -p /mnt/recovery

    printf '%s\n' "❯ mounting recovery drive"
    mount -t ext4 $recoveryDrive /mnt/recovery

    if ! df -Th | grep -q '/mnt/recovery'; then
        printf '%s\n' "ERROR: recovery drive is not mounted"
        exit
    fi

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

    printf '%s\n' "❯ installing alpine-base to root"
    apk add --root=/mnt/ --initdb alpine-base --keys-dir /etc/apk/keys --repositories-file /etc/apk/repositories

    printf '%s\n' "❯ copying repositories"
    cp /etc/apk/repositories /mnt/etc/apk/

    printf '%s\n' "❯ adding CloudFlare DNS"
    cat > /mnt/etc/resolv.conf <<EOF
nameserver 1.0.0.1
EOF

    printf '%s\n' "❯ chmod 666 /dev/null"
    chmod 666 /mnt/dev/null

    if printf '%s' $recoverySize | grep -q GiB; then

        printf '%s\n' "❯ installing alpine-base to recovery"
        apk add --root=/mnt/recovery/ --initdb alpine-base --keys-dir /etc/apk/keys --repositories-file /etc/apk/repositories

        printf '%s\n' "❯ copying repositories"
        cp /etc/apk/repositories /mnt/recovery/etc/apk/

        printf '%s\n' "❯ adding CloudFlare DNS"
        cat > /mnt/recovery/etc/resolv.conf <<EOF
nameserver 1.0.0.1
EOF

        printf '%s\n' "❯ chmod 666 /dev/null"
        chmod 666 /mnt/recovery/dev/null

    fi

}

change_root() {

    if ! grep -q 'step=' $f; then
        printf '\n%s' 'step=0' >> $f
        printf '%s\n' "❯ copying $f"
        cp $f /mnt/root/
    fi

    printf '%s\n' "❯ copying install script"
    cp /root/setup.sh /mnt/root/

    printf '%s\n' "❯ changing root"

    mount --bind /dev /mnt/dev
    mount --bind /sys /mnt/sys
    mount --bind /proc /mnt/proc
    mount --bind /run /mnt/run
    mount --bind /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars

    chroot /mnt /bin/ash /root/setup.sh

}

set_fstab() {

    printf '%s\n' "❯ setting fstab"

    rootUUID="$(blkid $rootDrive -o export | grep '^UUID=')"

    entry="$rootUUID / $filesystem rw,ssd,noatime,autodefrag 0 1"

    printf '\n%s\n' "$entry" > /etc/fstab

    bootUUID="$(blkid $bootDrive -o export | grep '^UUID=')"

    entry="$bootUUID /boot vfat rw,ssd,noatime,autodefrag 0 2"

    printf '\n%s\n' "$entry" >> /etc/fstab

    if grep -q 'recoveryDrive=' $f; then

        recoveryUUID="$(blkid $recoveryDrive -o export | grep '^UUID=')"

        entry="$recoveryUUID /recovery $filesystem rw,ssd,noatime,autodefrag 0 3"

        printf '\n%s\n' "$entry" >> /etc/fstab

    fi

    if grep -q 'swapDrive=' $f; then

        swapUUID="$(blkid $swapDrive -o export | grep '^UUID=')"

        entry="$swapUUID none swap sw 0 0"

        printf '\n%s\n' "$entry" >> /etc/fstab

    fi

    entry="binfmt_misc /proc/sys/fs/binfmt_misc binfmt_misc 0 4"
    printf '\n%s\n' "$entry" >> /etc/fstab

    sed -i 's|step=.*|step=1|' $f

}

install_linux() {

    if grep -q virtual $f; then
        list='linux-virt'
        if grep -q zfs $f; then
            list="$list zfs-virt"
        fi
    else
        if grep -q zfs $f; then
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
        list="$list cpupower cpupower-openrc linux-tools-gpio linux-tools-iio linux-tools-spi perf linux-tools-tmon linux-tools-usbip linux-tools-usbip-openrc"
    fi

    if grep -q zfs $f; then
        list="$list zfs zfs-openrc zfs-libs zfs-udev"
    fi

    printf '%s\n' "❯ installing linux"
    apk update
    apk fix
    apk add $list

    sed -i 's|step=.*|step=2|' $f

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

    sed -i 's|step=.*|step=3|' $f

}

disable_root() {

    printf '%s\n' "❯ disabling root login"
    passwd -l root
    sed -i 's|:/bin/ash|:/sbin/nologin|' /etc/passwd

    sed -i 's|step=.*|step=4|' $f

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
    usermod -aG input,audio,video,netdev,disk $user
    mkdir -p /var/mail/$user/
    HOME="/home/$user"
    mkdir -p $HOME/.config/autostart/
    mkdir -p $HOME/.local/

    printf '%s\n' "❯ changing config folder"
    mkdir -p /$user/cache/
    mkdir -p /$user/config/
    mkdir -p /$user/data/
    chown -R $user:wheel /$user/
    chmod -R 755 /$user/

    cat > /etc/profile.d/0user.sh <<EOF
XDG_CACHE_HOME="${XDG_CACHE_HOME:=$user/cache}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=/$user/config}"
XDG_DATA_HOME="${XDG_DATA_HOME:=$user/data}"
EOF

    sed -i 's|step=.*|step=5|' $f

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
    add_service boot 'apparmor'
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
    add_service default 'gdm greetd lightdm sddm'
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

    sed -i 's|step=.*|step=6|' $f

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
    cat > /etc/network/interfaces <<EOF
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

    sed -i 's|step=.*|step=7|' $f

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

    if [ -f /usr/bin/Hyprland ]; then
        run_session='/usr/bin/Hyprland'
        session='/usr/share/wayland-sessions/hyprland.desktop'
    fi

    if [ ! -d /usr/share/icons/windows-11-icons/ ]; then
        printf '%s\n' "❯ cloning Windows-11-icons"
        git clone https://github.com/0free/windows-11-icons.git $HOME/windows-11-icons/
        cp -r $HOME/windows-11-icons/* /usr/share/icons/
        rm -r $HOME/windows-11-icons/
    fi

    if grep -q gnome $f; then
        if [ ! -f $HOME/dconf-settings.ini ]; then
            printf '%s\n' "❯ downloading dconf-settings"
            curl -so $HOME/dconf.ini https://raw.githubusercontent.com/0free/alpineLinux/edge/dconf-settings.ini
            printf '%s\n' "❯ loading dconf-settings"
            dconf load / < $HOME/dconf.ini
            printf '%s\n' "❯ removing dconf-settings"
            rm $HOME/dconf.ini
        fi
    fi

    if grep -q kde $f; then
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

    if [ -f /usr/sbin/greetd ]; then
        configure_greetd
    fi

    sed -i 's|step=.*|step=8|' $f

}

configure_lightdm() {

    printf '%s\n' "❯ configuring lightdm"

    if grep -q hyprland $f; then
        sed -i 's|#autologin-session=.*|autologin-session=/usr/share/wayland-sessions/hyprland.desktop|' /etc/lightdm/lightdm.conf
    fi

    sed -i "s|#allow-guest=.*|allow-guest=false|" /etc/lightdm/lightdm.conf
    sed -i "s|#autologin-guest=.*|autologin-guest=false|" /etc/lightdm/lightdm.conf
    sed -i "s|#autologin-user=.*|autologin-user=$user|" /etc/lightdm/lightdm.conf
    sed -i "s|#autologin-user-timeout=.*|autologin-user-timeout=0|" /etc/lightdm/lightdm.conf
    sed -i "s|#autologin-in-background=.*|autologin-in-background=false|" /etc/lightdm/lightdm.conf
    sed -i "s|#user-session=.*|user-session=default|" /etc/lightdm/lightdm.conf
    sed -i "s|#greeter-session=.*|greeter-session=lightdm-gtk-greeter|" /etc/lightdm/lightdm.conf

}

configure_greetd() {

    printf '%s\n' "❯ configuring greetd"

    if grep -q hyprland /root/list; then
        sed -i 's|# exec-once = .*|exec-once = regreet|' /usr/share/hyprland/hyprland.conf
        command='/usr/bin/Hyprland  --config /usr/share/hyprland/hyprland.conf'
    fi

    cat > /etc/greetd/config.toml <<EOF
[terminal]
vt=1
[initial_session]
command="$command"
user=$user
[default_session]
command="$command"
user=$user
EOF

    cat > /etc/greetd/regreet.toml <<EOF
[background]
path = "/usr/share/backgrounds/greeter.jpg"
fit = "Contain"
[env]
ENV_VARIABLE = ""
[GTK]
application_prefer_dark_theme = true
cursor_theme_name = "Adwaita"
font_name = "Cantarell 16"
icon_theme_name = "Adwaita"
theme_name = "Adwaita"
[commands]
reboot = [ "loginctl", "reboot" ]
poweroff = [ "loginctl", "poweroff" ]
login = [ "loginctl", "login" ]
EOF

    url='https://raw.githubusercontent.com/shnaps/dotfiles/main/packages/greetd/regreet.css'
    curl -so /etc/greetd/regreet.css $url

    regreet --config /etc/greetd/regreet.toml
    regreet --style /etc/greetd/regreet.css

}

add_scripts() {

    if ! grep -q virtual $f; then
        build_zfs
        install_nvidia
    fi

    custom_kernel
    google_chrome
    install_lutris

    if grep -q server $f; then
        setup_mariadb
        install_webserver
    elif grep -q miner $f; then
        install_miner
    else
        create_iso
        install_office
        openwrt
    fi

    sed -i 's|step=.*|step=9|' $f

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

    if grep -q gnome $f; then
        cat > $HOME/.config/autostart/terminal.desktop <<EOF
[Desktop Entry]
Name=terminal
Type=Application
Exec=kgx -e t-rex -c ~/config
X-GNOME-Autostart-enabled=true
EOF
    fi

    if grep -q kde $f; then
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
    modules='ata base btrfs cdrom dhcp ext4 f2fs keymap kms lvm mmc network nvme scsi usb virtio wireguard xfs zfs'

    if grep -q virtual $f; then
        modules="$modules vboxvideo virtio-gpu vmvga vmwgfx"
    else
        modules="$modules intel_agp i915"
        modules="$modules amdgpu"
    fi

    printf '%s\n' "❯ configuring mkinitfs"
    printf '%s' "features=\"$modules \"" > /etc/mkinitfs/mkinitfs.conf

    for k in $(ls /lib/modules/ | grep [0-9]); do
        printf '%s\n' "❯ building linux $k initial ramdisk"
        mkinitfs -b / -c /etc/mkinitfs/mkinitfs.conf -o /boot/initramfs-$(printf '%s' $k | sed 's|.*-||') $k
    done

    sed -i 's|step=.*|step=10|' $f

}

setup_bootloader() {

    find_windows

    if grep -q zfs $f; then
        param="root=$ZFSpool"
    else
        param="root=$(blkid $rootDrive -o export | grep '^UUID=')"
    fi

    param="$param rootfstype=$filesystem rw loglevel=3 mitigations=off apparmor=1 security=apparmor"

    if [ -f /usr/libexec/fwupd/efi/fwupdx64.efi ]; then
        firmware_update
    fi

    if grep -q zfs $f; then
        install_ZFSBootMenu
    fi

    install_gummiboot

    sed -i 's|step=.*|step=11|' $f

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
                        printf '%s\n' "windowsDrive=$d" >> $f
                        printf '%s\n' "windowsBoot=$p" >> $f
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
options "root=$(blkid $windowsBoot -o export | grep '^UUID=')"
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

    if grep -Eq 'grub|syslinux' $f; then
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

    sed -i 's|step=.*|step=12|' $f

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

    sed -i 's|step=.*|step=13|' $f

}

unmount() {

    printf '%s\n' "❯ un-mounting /mnt/*"
    for d in /mnt/run /mnt/sys /mnt/dev /mnt/proc /mnt/boot; do
        if df -Th | grep -q $d; then
            umount $d
        fi
    done

    printf '%s\n' "❯ cleaning /root/"
    rm -rf /mnt/root/*

    if df -Th | grep -q '/mnt'; then
        printf '%s\n' "❯ un-mounting /mnt"
        umount -R /mnt
    fi

    if df -Th | grep -q zfs; then
        printf '%s\n' "❯ exporting ZFS pool"
        zpool export -a
    fi

    sed -i 's|step=.*|step=14|' $f

}

set -e

if [ ! -f $f ]; then
    if [ ! -f /usr/local/bin/setup ]; then
        printf '%s\n' "❯ downloading setup"
        url='https://raw.githubusercontent.com/0free/alpineLinux/edge/setup'
        curl -so /usr/local/bin/setup $url
        chmod 0755 /usr/local/bin/setup
    fi
fi

if [ -f /mnt/lib/apk/db/lock ]; then
    rm /mnt/lib/apk/db/lock
fi

if [ -f /mnt$f ]; then

    if grep -q 'step=' /mnt$f; then

        change_root

    fi

fi

if [ -f $f ]; then

    if grep -q 'password=' $f; then

        drive=$(. $f; printf '%s' $drive)
        filesystem=$(. $f; printf '%s' $filesystem)
        bootDrive=$(. $f; printf '%s' $bootDrive)
        swapDrive=$(. $f; printf '%s' $swapDrive)
        rootDrive=$(. $f; printf '%s' $rootDrive)
        recoveryDrive="$(. $f; printf '%s' $recoveryDrive)"
        windowsDrive=$(. $f; printf '%s' $windowsDrive)
        windowsBoot=$(. $f; printf '%s' $windowsBoot)
        user=$(. $f; printf '%s' $user)
        password=$(. $f; printf '%s' $password)
        HOME="/home/$user"

    fi

    if grep -q 'step=' $f; then

        while true; do
            case $(. $f; printf '%s' $step) in
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
                *) break;;
            esac
        done

        if [ "$(. $f; printf '%s' $step)" = '13' ]; then
            unmount
            exit
        fi

        if [ "$(. $f; printf '%s' $step)" = '14' ]; then
            reboot
        fi

    fi

    if df -Th | grep -v tmpfs | grep -q /mnt; then

        if ! df -Th | grep -v tmpfs | grep -q /mnt/boot; then
            mount_boot
        fi

        install_base
        change_root

    fi

else

        clear
        init_drive
        init_system
        init_user
        setup_drive
        install_base
        change_root

fi

#end