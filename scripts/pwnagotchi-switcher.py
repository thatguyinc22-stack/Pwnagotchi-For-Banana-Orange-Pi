#!/usr/bin/env python3
"""
Pwnagotchi Mode Switcher
A utility to switch between Pwnagotchi operational modes on Orange Pi/Banana Pi

Modes:
- AUTO: Automatic mode for passive WiFi handshake collection
- AI: AI-powered mode with reinforcement learning
- MANU: Manual mode for management and maintenance
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

# Configuration paths
AUTO_MODE_FLAG = "/root/.pwnagotchi-auto"

class PwnagotchiSwitcher:
    """Main switcher class for Pwnagotchi mode management"""
    
    def __init__(self):
        self.current_mode = self._detect_current_mode()
    
    def _detect_current_mode(self):
        """Detect the current Pwnagotchi mode"""
        if os.path.exists(AUTO_MODE_FLAG):
            return "AUTO"
        # Check if USB data connection is active (MANU mode indicator)
        try:
            result = subprocess.run(['lsusb'], capture_output=True, text=True)
            if 'Ethernet' in result.stdout or 'RNDIS' in result.stdout:
                return "MANU"
        except Exception:
            pass
        return "AI"
    
    def switch_to_auto(self):
        """Switch to AUTO mode"""
        print("Switching to AUTO mode...")
        try:
            Path(AUTO_MODE_FLAG).touch()
            print(f"Created {AUTO_MODE_FLAG}")
            print("AUTO mode enabled. Pwnagotchi will start in AUTO mode on next boot.")
            print("You may need to restart the pwnagotchi service or reboot.")
            return True
        except PermissionError:
            print(f"Error: Permission denied when creating {AUTO_MODE_FLAG}")
            print("Please run with sudo or as root.")
            return False
        except Exception as e:
            print(f"Error: Failed to create AUTO mode flag: {e}")
            return False
    
    def switch_to_ai(self):
        """Switch to AI mode"""
        print("Switching to AI mode...")
        try:
            if os.path.exists(AUTO_MODE_FLAG):
                os.remove(AUTO_MODE_FLAG)
                print(f"Removed {AUTO_MODE_FLAG}")
            print("AI mode enabled. Pwnagotchi will use AI on next boot.")
            print("You may need to restart the pwnagotchi service or reboot.")
            return True
        except PermissionError:
            print(f"Error: Permission denied when removing {AUTO_MODE_FLAG}")
            print("Please run with sudo or as root.")
            return False
        except Exception as e:
            print(f"Error: Failed to remove AUTO mode flag: {e}")
            return False
    
    def switch_to_manu(self):
        """Switch to MANU mode"""
        print("Switching to MANU mode...")
        print("To enter MANU mode, connect your device via USB data port to a computer.")
        print("MANU mode is hardware-triggered by the USB connection type.")
        return True
    
    def get_status(self):
        """Get current Pwnagotchi status"""
        print("=" * 50)
        print("Pwnagotchi Switcher Status")
        print("=" * 50)
        print(f"Current Mode: {self.current_mode}")
        print(f"AUTO Flag Present: {os.path.exists(AUTO_MODE_FLAG)}")
        
        # Check if pwnagotchi service is running
        try:
            result = subprocess.run(
                ['systemctl', 'is-active', 'pwnagotchi'],
                capture_output=True, 
                text=True
            )
            service_status = result.stdout.strip()
            print(f"Pwnagotchi Service: {service_status}")
        except Exception as e:
            print(f"Could not check service status: {e}")
        
        print("=" * 50)
        return True
    
    def restart_service(self):
        """Restart the pwnagotchi service"""
        print("Restarting pwnagotchi service...")
        try:
            subprocess.run(['systemctl', 'restart', 'pwnagotchi'], check=True)
            print("Pwnagotchi service restarted successfully.")
            return True
        except subprocess.CalledProcessError as e:
            print(f"Failed to restart service: {e}")
            return False
        except Exception as e:
            print(f"Error: {e}")
            return False


def main():
    """Main entry point for the switcher"""
    parser = argparse.ArgumentParser(
        description='Pwnagotchi Mode Switcher for Orange Pi/Banana Pi',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s status              Show current mode and status
  %(prog)s auto                Switch to AUTO mode
  %(prog)s ai                  Switch to AI mode
  %(prog)s manu                Switch to MANU mode
  %(prog)s restart             Restart pwnagotchi service
        """
    )
    
    parser.add_argument(
        'command',
        choices=['status', 'auto', 'ai', 'manu', 'restart'],
        help='Command to execute'
    )
    
    args = parser.parse_args()
    
    # Check if running as root
    if os.geteuid() != 0 and args.command != 'status':
        print("Error: This script must be run as root (use sudo)")
        print("Only 'status' command can be run without root privileges")
        sys.exit(1)
    
    switcher = PwnagotchiSwitcher()
    
    # Execute command
    if args.command == 'status':
        switcher.get_status()
    elif args.command == 'auto':
        switcher.switch_to_auto()
    elif args.command == 'ai':
        switcher.switch_to_ai()
    elif args.command == 'manu':
        switcher.switch_to_manu()
    elif args.command == 'restart':
        switcher.restart_service()


if __name__ == "__main__":
    main()
