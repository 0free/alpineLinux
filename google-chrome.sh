#!/bin/ash

install_google_chrome() {

    set -- alsa-lib at-spi2-core brotli-libs cairo ca-certificates cups-libs curl dbus-libs desktop-file-utils eudev-libs expat ffmpeg-libavcodec ffmpeg-libavdevice ffmpeg-libavfilter ffmpeg-libavformat ffmpeg-libavutil ffmpeg-libpostproc ffmpeg-libswresample ffmpeg-libswscale font-liberation gcompat gdk-pixbuf glib gtk+3.0 icu-libs jsoncpp lcms2 libatk-1.0 libatk-bridge-2.0 libatomic libcurl libdav1d libdrm libevent libexpat libffi libgcc libjpeg-turbo libpng libpulse libstdc++ libwebp libwoff2enc libx11 libxcb libxcomposite libxdamage libxext libxfixes libxkbcommon libxml2 libxshmfence libxrandr libxtst libxslt mesa-gbm nspr nss opus pango perl pipewire-libs qt5-qtbase qt5-qtbase-x11 shared-mime-info vulkan-loader wayland-libs-client xdg-utils wget zlib

    printf '%s\n' "❯ installing google-chrome dependencies"
    #doas apk add --no-cache $@

    if [ ! -f /usr/bin/google-chrome-stable ]; then
        printf '%s\n' "❯ adding google-signing-key"
        curl -so ~/google-key.pub https://dl-ssl.google.com/linux/linux_signing_key.pub
        doas gpg2 --allow-weak-key-signatures --batch --import ~/google-key.pub
        rm ~/google-key.pub
    fi

    if [ ! -f ~/data.tar.xz ]; then
        if [ ! -f ~/google-chrome.deb ]; then
            printf '%s\n' "❯ downloading google-chrome-stable"
            site='https://dl.google.com/linux/chrome/deb'
            file="$(curl -s $site/dists/stable/main/binary-amd64/Packages | grep '/google-chrome-stable' | sed 's|Filename: ||')"
            url="$site/$file"
            curl -so ~/google-chrome.deb $url
        fi
        if [ -f ~/google-chrome.deb ]; then
            printf '%s\n' "❯ extracting .deb file"
            ar x ~/google-chrome.deb data.tar.xz
        fi
        if [ -f ~/data.tar.xz ]; then
            printf '%s\n' "❯ removing .deb file"
            rm ~/google-chrome.deb
        fi
    fi

    if [ -f ~/data.tar.xz ]; then

        printf '%s\n' "❯ re-installing tar"
        doas apk fix --force-overwrite tar

        printf '%s\n' "❯ extracting data.tar.xz"
        tar -xJf ~/data.tar.xz ./opt/
        tar -xJf ~/data.tar.xz ./usr/share/applications/google-chrome.desktop

        printf '%s\n' "❯ removing data.tar.xz"
        rm ~/data.tar.xz

        printf '%s\n' "❯ copying google-chrome"
        doas mkdir -p /opt/google/chrome/
        doas cp -rf ~/opt/google/chrome/* /opt/google/chrome/
        doas cp -f ~/usr/share/applications/google-chrome.desktop /usr/share/applications/
        doas chmod 4755 /opt/google/chrome/chrome-sandbox

        printf '%s\n' "❯ linking google-chrome to /usr/bin/"
        cat > ~/google-chrome-stable <<EOF
#!/bin/ash
/opt/google/chrome/chrome --password-store=detect --no-sandbox --no-zygote --no-first-run --disable-logging --disable-gpu-vsync --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=PlatformHEVCDecoderSupport
EOF

        doas install -Dm0755 ~/google-chrome-stable /usr/bin/google-chrome-stable
        rm ~/google-chrome-stable

        printf '%s\n' "❯ removing un-needed folders"
        rm -r ~/opt/ ~/usr/
        doas rm -rf /opt/google/chrome/cron/

        printf '%s\n' "❯ adding icons"
        for logo in /opt/google/chrome/product_logo_*.png; do
            i=$(printf '%s' $logo | sed 's|/opt/google/chrome/product_logo_||')
            i=$(printf '%s' $i | sed 's|.png||')
            doas install -Dm644 $logo /usr/share/icons/hicolor/$i/apps/google-chrome.png
        done

        printf '%s\n' "❯ removing duplicates"
        doas rm /opt/google/chrome/product_logo_*.png

    fi

}

update_google_chrome() {

    printf '%s\n' "❯ getting current google-chrome-stable version"
    version=$(/opt/google/chrome/chrome --product-version)
    if printf '%s' $version | grep -Eq '^[1-9]'; then
        printf '%s\n' "❯ getting latest google-chrome-stable version"
    latest=$(curl -s https://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages | grep '/google-chrome-stable' | grep -oE '[1-9].*[0-9]' | sed 's|-.*||')
        if printf '%s' $version | grep -q $latest; then
        printf '%s\n' "❯ google-chrome is up-to-date"
        else
            install_google_chrome
        fi
    fi

}