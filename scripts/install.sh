#!/bin/bash
# Installation script for Pwnagotchi Mode Switcher

set -e

echo "======================================"
echo "Pwnagotchi Mode Switcher Installer"
echo "======================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Error: Please run as root (use sudo)"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SWITCHER_SCRIPT="$SCRIPT_DIR/pwnagotchi-switcher.py"
INSTALL_PATH="/usr/local/bin/pwn-switch"

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    echo "Please install Python 3: sudo apt-get install python3"
    exit 1
fi

echo "Python 3 found: $(python3 --version)"
echo ""

# Make the switcher executable
echo "Making switcher executable..."
if ! chmod +x "$SWITCHER_SCRIPT"; then
    echo "Error: Failed to make switcher executable"
    exit 1
fi

# Create symbolic link
echo "Creating symbolic link at $INSTALL_PATH..."
if [ -e "$INSTALL_PATH" ]; then
    echo "Removing existing file/symlink..."
    rm "$INSTALL_PATH"
fi

if ! ln -s "$SWITCHER_SCRIPT" "$INSTALL_PATH"; then
    echo "Error: Failed to create symbolic link"
    echo "You can still use the switcher directly: python3 $SWITCHER_SCRIPT"
    exit 1
fi

echo ""
echo "======================================"
echo "Installation complete!"
echo "======================================"
echo ""
echo "You can now use the switcher with:"
echo "  pwn-switch status    - Check current mode"
echo "  pwn-switch auto      - Switch to AUTO mode"
echo "  pwn-switch ai        - Switch to AI mode"
echo "  pwn-switch manu      - Show MANU mode info"
echo "  pwn-switch restart   - Restart service"
echo ""
echo "Or use directly:"
echo "  sudo python3 $SWITCHER_SCRIPT status"
echo ""
