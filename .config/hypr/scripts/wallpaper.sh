#!/bin/bash
# Wait for the session to settle
sleep 1

# Kill any existing wallpaper processes
pkill hyprpaper
pkill swww

# Identity the physical wallpaper file
WP_FILE=$(readlink -f /home/codeswot/.config/omarchy/current/background)

# Start hyprpaper
hyprpaper &
sleep 0.5 

# Force preload and set via IPC to ensure it "sticks"
hyprctl hyprpaper preload "$WP_FILE"
hyprctl hyprpaper wallpaper ",$WP_FILE"
