#!/bin/ash

version=''

install_lutris() {

    set -- python3 protobuf wine wine-mono

    printf '%s\n' '❯ installing lutris dependencies'
    doas apk add $@

    pip install -U moddb

    url="https://github.com/lutris/lutris/releases/download/v$version/lutris_$version_all.deb"

    printf '%s\n' "❯ getting latest lutris release from github"

    version=$(curl -s https://api.github.com/repos/lutris/lutris/releases/latest | grep '"tag_name":' | sed -E 's|.*"([^"]+)".*|\1|')

    file='data.tar.gz'

    if [ ! -f ~/$file ]; then
        if [ ! -f ~/lutris.deb ]; then
            printf '%s\n' "❯ downloading lutris $version"
            curl -Lo ~/lutris.deb $url
        fi
        if [ -f ~/lutris.deb ]; then
            printf '%s\n' "❯ extracting lutris $version"
            ar -x ~/lutris.deb $file
        fi
        if [ -f ~/$file ]; then
            printf '%s\n' "❯ deleting lutris.deb file"
            rm ~/lutris.deb
        fi
    fi

    if [ -f ~/$file ]; then

        printf '%s\n' "❯ re-installing tar"
        doas apk fix --force-overwrite tar

        printf '%s\n' "❯ extracting $file"
        tar -xf ~/$file ./usr/games/
        tar -xf ~/$file ./usr/lib/
        tar -xf ~/$file ./usr/share/applications/
        tar -xf ~/$file ./usr/share/icons/
        tar -xf ~/$file ./usr/share/lutris/

        printf '%s\n' "❯ removing $file"
        rm ~/$file

        printf '%s\n' "❯ copying lutris $version"
        doas cp -f ~/usr/games/* /usr/games/
        doas cp -rf ~/usr/lib/* /usr/lib/
        doas cp -f ~/usr/share/applications/* /usr/share/applications/
        doas cp -rf ~/usr/share/icons/* /usr/share/icons/
        doas cp -rf ~/usr/share/lutris/* /usr/share/

        printf '%s\n' "❯ removing un-needed folder"
        rm -r ~/usr/

        doas sed -i "s|^version='.*'|version='$version'|" /etc/profile.d/lutris.sh

    fi

}

update_lutris() {

    printf '%s\n' '❯ getting latest Lutris release from github'
    latest=$(curl -s https://api.github.com/repos/lutris/lutris/releases/latest | grep '"tag_name":' | sed -E 's|.*"([^"]+)".*|\1|')

    if ! grep -q "$latest" /etc/profile.d/lutris.sh; then
        install_lutris
    else
        printf '%s\n' '❯ Lutris is up-to-date'
    fi

}
