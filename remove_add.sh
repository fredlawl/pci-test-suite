#!/usr/bin/env bash

# Useful website for Linux ABI: 
# 	https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-bus-pci

BUS_NUM="03"
DEV="0000:$BUS_NUM:00.0"
DEV_PRETTY="0000-$BUS_NUM-00-0"
DEV_DIR="$DEV_PRETTY.d/add_remove"

mkdir -p $DEV_DIR
lspci -vvv -s $DEV > $DEV_DIR/before.txt

# Remove device
echo 1 > /sys/bus/pci/devices/$DEV/remove

# Rescan/Add Device
echo 1 > /sys/bus/pci/rescan
lspci -vvv -s $DEV > $DEV_DIR/after.txt

# If all goes well, there'll be no diff
git diff -b --no-index --  $DEV_DIR/before.txt $DEV_DIR/after.txt
