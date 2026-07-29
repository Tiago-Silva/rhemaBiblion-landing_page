#!/bin/sh
# Uninstaller script for RhemaBiblion AppImage and local data databases
set -e

echo "=== RhemaBiblion Linux Uninstaller ==="

# Confirm with the user
read -p "Deseja realmente desinstalar o RhemaBiblion e apagar todos os bancos de dados locais e notas de estudo? [s/N]: " confirm
if [ "$confirm" != "s" ] && [ "$confirm" != "S" ]; then
    echo "Operação cancelada pelo usuário."
    exit 0
fi

# 1. Detect privilege level and paths
if [ "$EUID" -ne 0 ]; then
    echo "Uninstalling for local user..."
    INSTALL_DIR="$HOME/.local/share/rhemabiblion"
    BIN_DIR="$HOME/.local/bin"
    ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"
    DESKTOP_DIR="$HOME/.local/share/applications"
    
    # Tauri user data directory (databases, notes, lexicon, imported books)
    USER_DATA_DIR="$HOME/.local/share/com.tiago.rhemabiblion"
    
    echo "Removing user shortcuts and binaries..."
    rm -rf "$INSTALL_DIR"
    rm -f "$BIN_DIR/rhemabiblion"
    rm -f "$ICON_DIR/rhemabiblion.png"
    rm -f "$DESKTOP_DIR/rhemabiblion.desktop"
    
    echo "Removing local SQLite databases and settings ($USER_DATA_DIR)..."
    rm -rf "$USER_DATA_DIR"
    
    # Update local desktop cache
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

else
    echo "Uninstalling system-wide (requires root)..."
    INSTALL_DIR="/opt/rhemabiblion"
    BIN_DIR="/usr/local/bin"
    ICON_DIR="/usr/share/icons/hicolor/512x512/apps"
    DESKTOP_DIR="/usr/share/applications"
    
    echo "Removing system-wide shortcuts and binaries..."
    rm -rf "$INSTALL_DIR"
    rm -f "$BIN_DIR/rhemabiblion"
    rm -f "$ICON_DIR/rhemabiblion.png"
    rm -f "$DESKTOP_DIR/rhemabiblion.desktop"
    
    echo "Wiping root app data..."
    rm -rf "/root/.local/share/com.tiago.rhemabiblion"
    
    # Clean database directory for all system users
    echo "Wiping databases and notes for all users in /home..."
    for user_dir in /home/*; do
        if [ -d "$user_dir/.local/share/com.tiago.rhemabiblion" ]; then
            echo "Cleaning data in $user_dir"
            rm -rf "$user_dir/.local/share/com.tiago.rhemabiblion"
        fi
    done
    
    # Update system desktop cache
    update-desktop-database /usr/share/applications 2>/dev/null || true
    gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
fi

echo "=========================================="
echo "RhemaBiblion foi completamente desinstalado!"
echo "Todos os bancos de dados e atalhos foram removidos."
echo "=========================================="
