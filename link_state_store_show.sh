#!/usr/bin/env bash

BUS_NUM="03"
DEV_NUM="1c.3"
DEV="0000:$BUS_NUM:00.0"
DEV_REAL="0000:00:$DEV_NUM"
DEV_PRETTY="0000-$BUS_NUM-00-0"
DEV_DIR="$DEV_PRETTY.d/link_state_store_show"

mkdir -p $DEV_DIR
lspci -vvv -s $DEV > $DEV_DIR/before.txt


# Get the current link state
LINK_STATE="$(cat /sys/devices/pci0000:00/$DEV_REAL/power/link_state)"
echo "Link state: $LINK_STATE"

# Set the state to it's current state
echo $LINK_STATE > /sys/devices/pci0000:00/$DEV_REAL/power/link_state
echo "Set link state"

lspci -vvv -s $DEV > $DEV_DIR/after.txt

# If all goes well, there'll be no diff
git diff -b --no-index -- $DEV_DIR/before.txt $DEV_DIR/after.txt
