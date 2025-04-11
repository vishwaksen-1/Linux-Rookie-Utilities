#!/usr/bin/env bash

# This is a utility to toggle Bluetooth on/off.
# Note: It might not work for some users. You may need to modify the condition `| grep -i "PowerState: off";`
# based on the output of `bluetoothctl show` when run alone.
# you can best use it to set-up keyboard shortcuts to toggle Bluetooth on/off.

if bluetoothctl show | grep -i "PowerState: off"; then
    bluetoothctl power on
else
    bluetoothctl power off
fi
