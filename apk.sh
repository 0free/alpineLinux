#!/bin/ash

packages() {

    printf '%-11s %-33s %-39s\n\n' 'SIZE' 'PACKAGE' 'VERSION' > ~/apks-installed.txt

    for package in $(apk info); do

        info=$(apk info -s "$package")

        description=$(apk info -d "$package")

        version=$(printf '%s\n' "$description" | grep -Eo '^.*[a-z].*-r[0-9]')

        unit=$(printf '%s\n' "$info" | grep -Eo 'B$|KiB$|MiB$')

        size=$(printf '%s\n' "$info" | sed 's|.* size:||' | grep -Eo '[0-9]{1,4}')

        printf '%-11s %-33s %-39s\n' "$size""$unit" "$package" "$version" >> ~/apks-installed.txt

    done

    sort -hr ~/apks-installed.txt

}
