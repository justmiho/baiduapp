#!/bin/sh
#设备型号：
uname -a
#synodsinfo --user-agent 1
#系统版本：
syno_version
#synodsinfo --user-agent 1
#SN：
cat /proc/sys/kernel/syno_serial
#sysctl -a | grep syno_serial
#MAC：
cat /proc/sys/kernel/syno_mac_addresses
#sysctl -a | grep syno_mac_addresses