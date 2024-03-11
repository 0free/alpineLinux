#!/bin/ash

clear && cd ~

set -- alpine-conf alpine-sdk apk-tools build-base busybox dosfstools fakeroot git mtools squashfs-tools xorriso grub grub-efi

list=''

for i in $@; do
   if ! grep -q $i /etc/apk/world; then
      set -- $list $i
   fi
done

if [ $list -ne '' ]; then
   doas apk add $list
fi

USER=$(whoami)

if ! groups | grep -q abuild; then
   doas addgroup abuild
fi

if ! groups $USER | grep -q abuild; then
   doas usermod -aG abuild $USER
fi

if [ ! -d ~/.abuild/ ]; then
   printf '\n' | abuild-keygen -i -a
fi

if [ ! -d ~/aports/ ]; then
   git clone --depth=1 --single-branch -b master https://gitlab.alpinelinux.org/alpine/aports.git
else
   cd ~/aports && git pull && cd ~
fi

curl -so ~/aports/scripts/apkovl.sh https://raw.githubusercontent.com/0free/alpineLinux/edge/apkovl.sh
chmod 700 ~/aports/scripts/apkovl.sh

export apks_base='alpine-base alpine-baselayout alpine-baselayout-data alpine-conf alpine-keys alpine-release alsa-lib alsa-plugins-jack alsa-plugins-pulse alsa-ucm-conf alsa-utils alsa-utils-openrc alsaconf apk-tools bash bcachefs-tools blkid bluez bluez-libs bluez-openrc btrfs-progs busybox busybox-binsh busybox-mdev-openrc busybox-openrc busybox-suid ca-certificates ca-certificates-bundle cairo cfdisk curl dbus dbus-daemon-launch-helper dbus-libs dbus-openrc dconf device-mapper-event-libs device-mapper-libs dialog dosfstools e2fsprogs e2fsprogs-libs efibootmgr efivar-libs elogind elogind-common elogind-openrc ethtool eudev eudev-hwids eudev-libs eudev-openrc exfatprogs f2fs-tools fakeroot file gawk gcompat glib hfsprogs hwdata hwdata-net hwdata-pci hwdata-pnp hwdata-usb ibus ibus-pyc icu-libs ifupdown-ng ifupdown-ng-ethtool iwd iwd-openrc linux-firmware-amd linux-firmware-amdgpu linux-firmware-i915 linux-firmware-intel linux-firmware-isci linux-firmware-other linux-firmware-rtl_bt linux-firmware-rtl_nic linux-firmware-rtlwifi linux-pam llvm15-libs lsblk mdev-conf mesa mesa-dri-gallium mesa-egl mesa-gbm mesa-gl mesa-glapi mesa-va-gallium mesa-vdpau-gallium mkinitfs mmc-utils mount mtdev mtools musl musl-fts musl-obstack musl-utils networkmanager networkmanager-common networkmanager-openrc networkmanager-wifi ntfs-3g ntfs-3g-libs ntfs-3g-progs openrc openrc-settingsd openrc-settingsd-openrc openssl pinentry pipewire pipewire-alsa pipewire-jack pipewire-libs pipewire-pulse pipewire-spa-bluez pipewire-spa-tools pipewire-spa-vulkan pipewire-tools polkit-common polkit-elogind polkit-elogind-libs polkit-openrc readline scanelf sfdisk sgdisk shadow tzdata udev-init-scripts udev-init-scripts-openrc udftools udisks2 udisks2-libs umount upower vulkan-loader wget wipefs wireless-regdb wireplumber wireplumber-libs wireplumber-logind xcb-util xf86-input-evdev xf86-input-mtrack xf86-input-synaptics xfsprogs xkbcomp xkeyboard-config zfs zfs-libs zfs-openrc zfs-udev'

if [ $desktop = 'gnome' ]; then
    export apks_desktop='adwaita-icon-theme font-cantarell gdm gdm-openrc gnome-autoar gnome-bluetooth gnome-bluetooth-libs gnome-console gnome-control-center gnome-desktop gnome-session gnome-settings-daemon gnome-shell gnome-shell-schemas gnome-system-monitor gsettings-desktop-schemas mutter mutter-schemas nautilus network-manager-applet polkit-gnome gedit'
fi

cat > ~/aports/scripts/mkimg.linux.sh <<EOF
profile_linux() {
   output_filename="alpineLinux-x64-$(date '+%Y-%b-%d')-$desktop.iso"
   output_format='iso'
   image_ext='iso'
   arch='x86_64'
   hostname='alpineLinux'
	initfs_cmdline='modules=loop,squashfs,sd-mod,usb-storage,btrfs,zfs,xfs,ext4'
	initfs_features='ata base bootchart btrfs cdrom ext4 mmc nvme raid scsi usb virtio xfs zfs'
	modloop_sign='yes'
   grub_mod='all_video disk part_gpt part_msdos linux normal configfile search search_label efi_gop fat iso9660 gzio'
   boot_addons=''
   initrd_ucode=''
   apkovl='./aports/scripts/apkovl.sh'
   kernel_flavors='lts'
   kernel_addons='zfs'
   kernel_cmdline='mitigations=off'
   apks="$apks_base $apks_desktop"
}
EOF

chmod 0700 ~/aports/scripts/mkimg.linux.sh

sed -i 's|linux-firmware wireless-regdb|linux-firmware-none|' ~/aports/scripts/mkimg.base.sh
sed -i 's|alpine-${profile_abbrev:-$PROFILE} $RELEASE $ARCH|alpineLinux|g' ~/aports/scripts/mkimg.base.sh
sed -i 's|timeout=1|timeout=0|' ~/aports/scripts/mkimg.base.sh
sed -i 's|timeout=1|timeout=0|' ~/aports/main/syslinux/update-extlinux.conf
sed -i 's|discover_retries = 5|discover_retries = 0|' ~/aports/main/busybox/0015-udhcpc-set-default-discover-retries-to-5.patch

sh ~/aports/scripts/mkimage.sh \
--profile linux \
--arch x86_64 \
--outdir ~/ \
--workdir ~/alpine \
--repository https://uk.alpinelinux.org/alpine/latest-stable/main \
--repository https://uk.alpinelinux.org/alpine/latest-stable/community

#end