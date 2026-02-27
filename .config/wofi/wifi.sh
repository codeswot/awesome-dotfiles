#!/bin/bash

# Ensure wofi doesn't spam start
if pgrep -x "wofi" > /dev/null
then
    pkill -x wofi
    exit 0
fi

STATION=$(iwctl station list | sed 's/\x1b\[[0-9;]*m//g' | grep -o "wlan[0-9]" | head -n 1)

if [ -z "$STATION" ]; then
    notify-send -i network-wireless-error "Wi-Fi" "No wireless device found"
    exit 1
fi

# Get available networks and strip ANSI
# Logic: 
# 1. First find the connected SSID by looking for ">"
# 2. Then list all SSIDs
# 3. If SSID matches connected one, add tag
CONNECTED_SSID=$(iwctl station "$STATION" get-networks | sed 's/\x1b\[[0-9;]*m//g' | awk '/^[ \t]*>[ \t]*/ {
    sub(/^[ \t]*>[ \t]*/, "");
    match($0, /psk|open|8021x/);
    ssid = substr($0, 1, RSTART-1);
    gsub(/[ \t]+$/, "", ssid);
    print ssid;
    exit;
}')

LIST=$(iwctl station "$STATION" get-networks | sed 's/\x1b\[[0-9;]*m//g' | awk -v active="$CONNECTED_SSID" '
    /psk|open|8021x/ {
        # Regular networks
        line = $0;
        gsub(/^[ \t*>]*/, "", line);
        match(line, /psk|open|8021x/);
        ssid = substr(line, 1, RSTART-1);
        gsub(/[ \t]+$/, "", ssid);
        
        if (ssid != "" && !seen[ssid]++) {
            if (active != "" && ssid == active) {
                print ssid "  [connected]";
            } else {
                print ssid;
            }
        }
    }
')

# Apply user-requested dimensions (500x400)
CHOSEN=$(echo -e "$LIST" | wofi --show dmenu --style ~/.config/wofi/style.css --prompt "Wi-Fi" --width 500 --height 400 --cache-file /dev/null)

if [ -z "$CHOSEN" ]; then
    exit 0
fi

# Clean SSID
SSID=$(echo "$CHOSEN" | sed 's/  \[connected\]//')

if echo "$CHOSEN" | grep -q "connected"; then
    notify-send -i network-wireless "Wi-Fi" "Already connected to $SSID"
    exit 0
fi

notify-send -i network-wireless "Wi-Fi" "Connecting to $SSID..."

# Step 2: Connection Logic
IS_KNOWN=$(iwctl known-networks list | sed 's/\x1b\[[0-9;]*m//g' | grep -w "^  $SSID")

if [ -n "$IS_KNOWN" ]; then
    iwctl station "$STATION" connect "$SSID"
else
    # PASSWORD PROMPT: Locked icon in prompt, height 200.
    # Wofi doesn't show the prompt icon if it's too long, so keep it clean.
    # Using small width for a modal feel.
    # Switch to direct dmenu mode for password selection to bypass wofi search entry behaviors
    PASS=$(wofi --dmenu --password --style ~/.config/wofi/style-password.css --prompt "󰌾 Password" --width 400 --height 100 --cache-file /dev/null --conf /dev/null)
    
    if [ -z "$PASS" ]; then exit 0; fi
    iwctl station "$STATION" connect "$SSID" --passphrase "$PASS"
fi

# Final verification
sleep 2
if iwctl station "$STATION" show | grep -q "connected"; then
    notify-send -i network-wireless "Wi-Fi" "Successfully connected to $SSID"
else
    notify-send -i network-wireless-error "Wi-Fi" "Failed to connect to $SSID. Check passphrase."
fi
