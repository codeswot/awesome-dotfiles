#!/bin/bash

# Aether Theme - Automated Rice Installer
# Targets: Hyprland, Waybar, Wofi, Dunst, SDDM

set -e

echo "🌌 Starting Aether Theme Installation..."

# 1. Update and Install System Dependencies
echo "📦 Installing system dependencies (Arch Linux / pacman)..."
sudo pacman -S --needed \
    hyprland hyprpaper hyprlock hypridle \
    waybar wofi dunst \
    brightnessctl pamixer playerctl \
    zsh ghostty iwd \
    sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg \
    ttf-jetbrains-mono-nerd ttf-commit-mono-nerd \
    network-manager-applet \
    libnotify \
    grim slurp wl-clipboard

# 2. Oh My Zsh and Plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "🐚 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. SDDM Theme Setup
echo "🎨 Setting up SDDM theme..."
SDDM_THEME_DIR="/usr/share/sddm/themes/aether"
if [ ! -d "$SDDM_THEME_DIR" ]; then
    sudo mkdir -p "$SDDM_THEME_DIR"
fi

# We expect the SDDM theme files to be in the repo root under sddm/
if [ -d "./sddm-aether" ]; then
    sudo cp -r ./sddm-aether/* "$SDDM_THEME_DIR/"
    echo "✓ SDDM theme copied."
else
    echo "⚠ SDDM source files (./sddm-aether) not found, skipping system copy."
fi

# 4. Enable Services
echo "⚙ Enabling system services..."
sudo systemctl enable --now iwd
sudo systemctl enable sddm

# 5. Final message
echo "✨ Installation complete!"
echo "Please restart your session or reboot to see full changes."
echo "Note: The wallpaper script ~/.config/hypr/scripts/wallpaper.sh will handle the background automatically."
