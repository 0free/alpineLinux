#!/bin/ash

install_office() {

    menu 'install Microsoft Office Pro Plus 2021 retail' bit '32bit' '64bit'

    [ $bit = '32bit' ] && bit='32' || bit='64'

    set -- 'Access' 'Excel' 'Lync' 'OneDrive' 'OneNote' 'Outlook' 'PowerPoint' 'Publisher' 'Teams' 'Word'

    if [ -f ~/Office2021/configuration.xml ]; then
        for i in $@; do
            if grep -q "$i" ~/Office2021/configuration.xml; then\
                export "$i"=0
            else
                export "$i"=1
            fi
        done
    else
        export Access=0
        export Excel=1
        export Lync=0
        export OneDrive=0
        export OneNote=0
        export Outlook=1
        export PowerPoint=1
        export Publisher=0
        export Teams=0
        export Word=1
    fi

    options 'install Microsoft Office Pro Plus 2021 packages' $@
    printf '\n'

    if [ ! -d ~/Office2021/ ]; then
        printf '%s\n' "❯ adding ~/Office2021/ folder"
        mkdir -p ~/Office2021/
    fi

    printf '%s\n' '❯ creating Office 2021 configuration'
    cat > ~/Office2021/configuration.xml <<EOF
<Configuration>
  <Add OfficeClientEdition="$bit">
    <Product ID="ProPlus2021Retail">
      <Language ID="en-us" />
EOF

    for i in $@; do
        eval "v=\${$i}"
        if [ "$v" = 0 ]; then
            cat >> ~/Office2021/configuration.xml <<EOF
      <ExcludeApp ID="$i" />
EOF
        fi
        unset "$i"
    done

    cat >> ~/Office2021/configuration.xml <<EOF
    </Product>
  </Add>
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Display Level="Full" AcceptEULA="TRUE" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
</Configuration>
EOF

if [ ! -f ~/Office2021/bin.exe ]; then
    printf '%s\n' '❯ downloading bin.exe'
    curl -so ~/Office2021/bin.exe https://raw.githubusercontent.com/0free/office/main/bin.exe
fi

if [ ! -f ~/Office2021/activate.bat ]; then
    printf '%s\n' '❯ downloading activate.bat'
    curl -so ~/Office2021/activate.bat https://raw.githubusercontent.com/0free/office/main/activate.bat
fi

if [ ! -f /usr/bin/wine	]; then
    printf '%s\n' '❯ installing wine'
    doas apk add wine-staging
fi

printf '%s\n' '❯ installing Office 2021 using wine'
wine64 ~/Office2021/bin.exe /configure configuration.xml

printf '%s\n' '❯ activating Office 2021 using wine'
wine64 ~/Office2021/activate.bat

}
