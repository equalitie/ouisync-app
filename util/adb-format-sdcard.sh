#!/bin/bash

# This script is meant to be used on the CI (Github Actions, etc...) to setup the emulated SD card
# for testing. Using it for other purposes is not recommended.

echo "Format SD card on the connected Android device or emulator? [y/n]"
read -r reply

reply=$(echo "$reply" | tr '[:upper:]' '[:lower:]')

if [ $reply != "yes" -a $reply != "y" ]; then
    exit
fi

echo "Formatting SD card ..."

adoptable=$(adb shell sm has-adoptable)
if [ $adoptable == "false" ]; then
    adb shell sm set-force-adoptable true
fi

disk=
while true; do
    disk=$(adb shell sm list-disks)

    if [ -n "$disk" ]; then
        break
    fi
done

adb shell sm partition "$disk" public

if [ $adoptable == "false" ]; then
    volume=$(adb shell sm list-volumes | grep public | cut -d' ' -f1)
    adb shell sm format "$volume"
    adb shell sm mount "$volume"
fi

echo "Done"