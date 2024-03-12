#!/bin/ash

HOSTNAME=$1

cleanup() {
    rm -rf $tmp
}

makefile() {
    cat > $3
    chown $1 $3
    chmod $2 $3
}

add_service() {
    runlevel=$1
    mkdir -p $tmp/etc/runlevels/$runlevel/
    shift 2
    for i in $@; do
        if [ -f /etc/init.d/$i ]; then
            ln -sf /etc/init.d/$i $tmp/etc/runlevels/$runlevel/$i
        fi
    done
}

tmp=$(mktemp -d)
trap cleanup EXIT

mkdir -p $tmp/etc/

makefile root:root 0644 $tmp/etc/hostname <<EOF
$HOSTNAME
EOF

makefile root:root 0644 $tmp/etc/resolv.conf <<EOF
nameserver 1.0.0.1
EOF

makefile root:root 0644 $tmp/etc/locale.conf <<EOF
LANG='en_US.UTF-8'
EOF

mkdir -p $tmp/etc/network/
makefile root:root 0644 $tmp/etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

mkdir -p $tmp/etc/NetworkManager/
makefile root:root 0644 $tmp/etc/NetworkManager/NetworkManager.conf <<EOF
[main]
dhcp=internal
plugins=ifupdown,keyfile
[ifupdown]
managed=true
[device]
wifi.backend=iwd
EOF

mkdir -p $tmp/etc/apk/

makefile root:root 0644 $tmp/etc/apk/repositories <<EOF
https://uk.alpinelinux.org/alpine/latest-stable/main
https://uk.alpinelinux.org/alpine/latest-stable/community
EOF

makefile root:root 0644 $tmp/etc/apk/world <<EOF
EOF

set -- $apks_base $apks_desktop
for i in $@; do
    printf '%s\n' $i >> $tmp/etc/apk/world
done
sort -u -o $tmp/etc/apk/world $tmp/etc/apk/world

mkdir -p $tmp/etc/conf.d/
makefile root:root 0644 $tmp/etc/conf.d/hwclock <<EOF
clock="local"
clock_hctosys="NO"
clock_systohc="YES"
clock_args=""
EOF

mkdir -p $tmp/etc/profile.d/
makefile root:root 0644 $tmp/etc/profile.d/setup.sh <<EOF
#!/bin/ash
rm -f /etc/motd
cat > /usr/local/bin/setup <<END
if curl -so /dev/null alpinelinux.org; then
    printf '%s\n' '>>> downloading alpine linux setup script'
    curl -so /root/setup.sh https://raw.githubusercontent.com/0free/alpineLinux/edge/setup.sh
    ash /root/setup.sh
else
    printf '%s\n' 'no internet'
fi
END
chmod 0755 /usr/local/bin/setup
EOF

if [ $desktop = 'gnome' ]; then

    session_dbus  = '/usr/bin/dbus-run-session'
    session_gnome = '/usr/bin/gnome-session'
    session = '/usr/share/wayland-sessions/gnome-wayland.desktop'
    terminal = '/usr/bin/kgx'

    mkdir -p $tmp/etc/gdm/
    makefile root:root 0644 $tmp/etc/gdm/login.conf <<EOF
[daemon]
WaylandEnable=true
AutomaticLoginEnable=true
AutomaticLogin=root
EOF

    curl -so $tmp/etc/dconf.ini https://raw.githubusercontent.com/0free/alpineLinux/edge/dconf-settings.ini
    chown root:root $tmp/etc/dconf.ini
    chmod 0644 $tmp/etc/dconf.ini

    makefile root:root 0644 $tmp/etc/profile.d/gnome.sh <<EOF
#!/bin/ash
if [ -f /etc/dconf.ini ]; then
    dconf load / < /etc/dconf.ini && rm /etc/dconf.ini
fi
EOF

fi

add_service sysinit devfs procfs dmesg hwdrivers root mdev modloop udev udev-trigger udev-settle udev-postmount zfs-import zfs-mount

add_service boot modules cgroups mtab swap localmount sysctl hostname bootmisc networking machine-id ntpd hwclock swclock

add_service boot sysfs dbus efivars zfs-share zfs-zed zfs-load-key

add_service default syslog acpid crond iwd networkmanager networkmanager-dispatcher alsa bluez bluealsa bluetooth openrc-settingsd elogind polkit local gdm sddm lightdm

add_service shutdown mount-ro killprocs savecache

tar -c -C $tmp etc | gzip -9n > $HOSTNAME.apkovl.tar.gz

#end