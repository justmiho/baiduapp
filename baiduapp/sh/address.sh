#!/bin/sh
#MAC：
if [ -f "/etc/machine-id" ]; then
    cat /proc/sys/kernel/syno_mac_addresses /etc/machine-id | tr -d "\n"
else
    cat /proc/sys/kernel/syno_mac_addresses
fi
