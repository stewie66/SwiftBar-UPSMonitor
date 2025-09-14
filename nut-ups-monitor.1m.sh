#!/bin/bash

# SwiftBar NUT UPS Monitor
# Monitors UPS status using upsc command
# Configure your UPS ID and address below
UPS_ADDRESS="ups@192.168.50.170"
# Location of upsc command
UPSC_PATH="/opt/homebrew/bin/upsc"

# Get UPS data
UPS_DATA=$($UPSC_PATH $UPS_ADDRESS 2>/dev/null)

# Check if upsc command succeeded
if [ $? -ne 0 ] || [ -z "$UPS_DATA" ]; then
    echo "⚡❌"
    echo "---"
    echo "UPS: Offline or Unreachable"
    echo "Check connection to $UPS_ADDRESS"
    exit 0
fi

# Extract required information
MODEL=$(echo "$UPS_DATA" | grep "ups.model:" | cut -d: -f2- | xargs)
MFR=$(echo "$UPS_DATA" | grep "ups.mfr:" | cut -d: -f2- | xargs)
CHARGE=$(echo "$UPS_DATA" | grep "battery.charge:" | cut -d: -f2- | xargs)
BATTERYSTATUS=$(echo "$UPS_DATA" | grep "battery.status:" | cut -d: -f2- | xargs)
UPSSTATUS=$(echo "$UPS_DATA" | grep "ups.status:" | cut -d: -f2- | xargs)
LOAD=$(echo "$UPS_DATA" | grep "ups.load:" | cut -d: -f2- | xargs)
RUNTIME=$(echo "$UPS_DATA" | grep "battery.runtime:" | cut -d: -f2- | xargs)

# Convert runtime from seconds to minutes
if [ -n "$RUNTIME" ] && [ "$RUNTIME" -gt 0 ]; then
    RUNTIME_MINUTES=$((RUNTIME / 60))
    RUNTIME_FORMATTED="${RUNTIME_MINUTES} min"
else
    RUNTIME_FORMATTED="N/A"
fi

# Set appropriate emoji based on status
case $UPSSTATUS in
    "OL") EMOJI="⚡" ;;
    "OB") EMOJI="🔋" ;;
    "LB") EMOJI="🪫" ;;
    "CHRG") EMOJI="🔌" ;;
    *) EMOJI="❓" ;;
esac

# Create status text
if [ "$UPSSTATUS" = "OL" ]; then
    STATUS_TEXT="Online"
elif [ "$UPSSTATUS" = "OB" ]; then
    STATUS_TEXT="On Battery"
elif [ "$UPSSTATUS" = "LB" ]; then
    STATUS_TEXT="Low Battery"
elif [ "$UPSSTATUS" = "CHRG" ]; then
    STATUS_TEXT="Charging"
else
    STATUS_TEXT="$UPSSTATUS"
fi

# Display in SwiftBar
echo "$EMOJI $UPSSTATUS"
echo "---"
echo "MFR: $MFR"
echo "Model: $MODEL"
echo "Battery Charge: $CHARGE%"
echo "Battery Status: $BATTERYSTATUS"
echo "Load: $LOAD%"
echo "Runtime: $RUNTIME_FORMATTED"
echo "---"
echo "Refresh | refresh=true"
echo "Open Terminal | shell=open param1=-a param2=Terminal"
