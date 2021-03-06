#!/usr/bin/env bash

BUS_NUM="03"
DEV="0000:$BUS_NUM:00.0"
DEV_PRETTY="0000-$BUS_NUM-00-0"
DEV_DIR="$DEV_PRETTY.d/loop-aspm-policies"

POLICIES=("default" "performance" "powersave" "powersupersave")
CURRENT=$(cat /sys/module/pcie_aspm/parameters/policy | sed -n 's:.*\[\(.*\)\]:\1:p')

echo "Current ASPM policy: $CURRENT"

# Create output directory, then setup a control
echo "Created a control file to detect differences in settings"
mkdir -p $DEV_DIR
lspci -vvv -s $DEV > $DEV_DIR/control.txt


for policy in "${POLICIES[@]}"
do
	echo "Setting ASPM policy to $policy"
	echo $policy > /sys/module/pcie_aspm/parameters/policy
	lspci -vvv -s $DEV > $DEV_DIR/$policy-policy.txt
	git diff -b --no-index -- $DEV_DIR/control.txt $DEV_DIR/$policy-policy.txt
	echo "----"
done	

# Set policy back to original policy
echo $CURRENT > /sys/module/pcie_aspm/parameters/policy
lspci -vvv -s $DEV > $DEV_DIR/control-reset.txt

# Diff the start of the script to the final result. Settings SHOULD be the same
echo "Diff the control. No diff is good"
git diff -b --no-index -- $DEV_DIR/control.txt $DEV_DIR/control-reset.txt
