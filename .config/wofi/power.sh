#!/bin/bash

if pgrep -x "wofi" > /dev/null
then
    pkill -x wofi
    exit 0
fi

# Define options with Nerd Font icons
lock="󰌾  Lock"
shutdown="⏻  Shutdown"
reboot="  Reboot"
suspend="󰤄  Suspend"
logout="󰍃  Logout"

options="$lock\n$shutdown\n$reboot\n$suspend\n$logout"
chosen=$(echo -e "$options" | wofi --show dmenu --style ~/.config/wofi/style.css --prompt "Select Power Option")

case "$chosen" in
    "$lock") hyprlock ;;
    "$shutdown") systemctl poweroff ;;
    "$reboot") systemctl reboot ;;
    "$suspend") systemctl suspend ;;
    "$logout") hyprctl dispatch exit ;;
esac
