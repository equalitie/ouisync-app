#!/bin/bash

# This script is meant to be used on the CI (Github Actions, etc...) to setup the emulated SD card
# for testing. Using it for other purposes is not recommended.

adb_opts="$@"

function adb_shell() {
    adb $adb_opts shell $@
}

echo "Format SD card on the connected Android device or emulator? [y/n]"
read -r reply

reply=$(echo "$reply" | tr '[:upper:]' '[:lower:]')

if [ $reply != "yes" -a $reply != "y" ]; then
    exit
fi

echo "Formatting SD card ..."

adoptable=$(adb_shell sm has-adoptable)
if [ $adoptable == "false" ]; then
    adb_shell sm set-force-adoptable true
fi

disk=
while true; do
    disk=$(adb_shell sm list-disks)

    if [ -n "$disk" ]; then
        break
    fi
done

adb_shell sm partition "$disk" public

if [ $adoptable == "false" ]; then
    volume=$(adb_shell sm list-volumes | grep public | cut -d' ' -f1)
    adb_shell sm format "$volume"
    adb_shell sm mount "$volume"
fi

echo "Done"