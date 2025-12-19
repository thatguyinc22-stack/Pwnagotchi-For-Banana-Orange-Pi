# OrangePiPwn Integration Guide

## Quick Start for Your ZorangePiPwn Repository

This guide helps you integrate the Pwnagotchi platform into your existing ZorangePiPwn repository, creating a dual-mode system.

## Step 1: Copy Files to Your Repository

Copy these newly created files from the Pwnagotchi-For-Banana-Orange-Pi repo to your zorangepipwn repo:

```bash
# From this repo to your zorangepipwn repo
cp INTEGRATION_PLAN.md /path/to/zorangepipwn/
cp scripts/orangepipwn-mode /path/to/zorangepipwn/scripts/
cp scripts/usb-gadget-setup.sh /path/to/zorangepipwn/scripts/
cp systemd/usb-gadget.service /path/to/zorangepipwn/systemd/
cp config/default-config.toml /path/to/zorangepipwn/config/
```

## Step 2: Copy Pwnagotchi Core Components

You need to copy the entire Pwnagotchi Python package:

```bash
# Create the pwnagotchi core directory in your repo
mkdir -p /path/to/zorangepipwn/orangepipwn/pwnagotchi_core

# Copy the pwnagotchi Python modules
cp -r pwnagotchi/* /path/to/zorangepipwn/orangepipwn/pwnagotchi_core/

# Copy bin files
cp bin/pwnagotchi /path/to/zorangepipwn/bin/

# Copy builder data (systemd services, scripts)
cp -r builder/data/* /path/to/zorangepipwn/builder/data/

# Copy requirements
cp requirements.txt /path/to/zorangepipwn/requirements-pwnagotchi.txt

# Copy setup.py as reference
cp setup.py /path/to/zorangepipwn/setup-pwnagotchi.py
```

## Step 3: Create a New Setup Script

Create a new `setup.py` in your zorangepipwn repo that combines both systems:

```python
#!/usr/bin/env python3
from setuptools import setup, find_packages
import os
import shutil
import glob

def install_system_files():
    """Install systemd services and scripts"""
    
    # Install mode switcher
    shutil.copy('scripts/orangepipwn-mode', '/usr/local/bin/orangepipwn-mode')
    os.chmod('/usr/local/bin/orangepipwn-mode', 0o755)
    
    # Install USB gadget script
    shutil.copy('scripts/usb-gadget-setup.sh', '/usr/local/bin/usb-gadget-setup.sh')
    os.chmod('/usr/local/bin/usb-gadget-setup.sh', 0o755)
    
    # Install systemd services
    services = [
        'systemd/usb-gadget.service',
        'builder/data/etc/systemd/system/pwnagotchi.service',
        'builder/data/etc/systemd/system/bettercap.service',
    ]
    
    for service in services:
        if os.path.exists(service):
            shutil.copy(service, '/etc/systemd/system/')
    
    # Install config
    os.makedirs('/etc/orangepipwn', exist_ok=True)
    if not os.path.exists('/etc/orangepipwn/config.toml'):
        shutil.copy('config/default-config.toml', '/etc/orangepipwn/config.toml')
    
    # Create directories
    os.makedirs('/var/lib/orangepipwn', exist_ok=True)
    os.makedirs('/var/log/orangepipwn', exist_ok=True)
    os.makedirs('/opt/orangepipwn/payloads/hid', exist_ok=True)
    os.makedirs('/opt/orangepipwn/payloads/mass_storage', exist_ok=True)
    os.makedirs('/opt/orangepipwn/payloads/network', exist_ok=True)
    
    # Reload systemd
    os.system('systemctl daemon-reload')
    
    print("OrangePiPwn installed successfully!")
    print("Run 'sudo orangepipwn-mode init' to complete setup")

setup(
    name='orangepipwn',
    version='1.0.0',
    description='Dual-mode WiFi auditing and USB attack platform for Orange Pi',
    author='Your Name',
    license='GPL3/MIT',
    packages=find_packages(),
    install_requires=[
        'pycryptodome==3.9.4',
        'requests>=2.21.0',
        'PyYAML>=5.3.1',
        'scapy>=2.4.3',
        'toml>=0.10.0',
        'flask>=1.0.2',
        'flask-cors>=3.0.7',
    ],
    entry_points={
        'console_scripts': [
            'orangepipwn=orangepipwn.cli:main',
        ],
    },
    include_package_data=True,
)

if __name__ == '__main__':
    install_system_files()
```

## Step 4: Update Your README.md

Add this section to your zorangepipwn README:

```markdown
## Dual-Mode Operation

OrangePiPwn now supports two operating modes:

### Mode 1: Pwnagotchi (WiFi Auditing)
- Automated WiFi handshake capture
- AI-powered learning
- WPA/WPA2 handshake collection
- Display interface support
- Web interface on port 8080

### Mode 2: USB Gadget (Attack Platform)
- HID keyboard/mouse emulation
- Mass storage emulation
- USB network sharing
- P4wnP1-style payloads

### Switching Modes

```bash
# Switch to Pwnagotchi mode
sudo orangepipwn-mode set pwnagotchi
sudo reboot

# Switch to USB Gadget mode
sudo orangepipwn-mode set usb-gadget
sudo reboot

# Check current status
orangepipwn-mode status
```
```

## Step 5: Installation Instructions for Users

Add this to your repo documentation:

```markdown
## Installation

### Prerequisites

```bash
sudo apt update
sudo apt install -y \
    python3 python3-pip git build-essential \
    libnetfilter-queue-dev libffi-dev libssl-dev \
    python3-dev libpcap-dev dnsmasq
```

### Install OrangePiPwn

```bash
# Clone repository
git clone https://github.com/yourusername/zorangepipwn.git
cd zorangepipwn

# Install
sudo python3 setup.py install

# Initialize
sudo orangepipwn-mode init

# Choose your mode
sudo orangepipwn-mode set pwnagotchi  # or usb-gadget

# Reboot
sudo reboot
```

### Post-Installation

#### For Pwnagotchi Mode:
1. Edit `/etc/pwnagotchi/config.toml`
2. Configure WiFi settings
3. Set your display type (if using one)
4. Enable plugins as needed

#### For USB Gadget Mode:
1. Edit `/etc/orangepipwn/config.toml`
2. Configure USB gadget settings
3. Add payloads to `/opt/orangepipwn/payloads/`
```

## Step 6: Create Example Payload

Create an example HID payload in your repo:

```bash
mkdir -p payloads/hid/examples
```

Create `payloads/hid/examples/hello-world.sh`:

```bash
#!/bin/bash
# Simple HID payload example
# Opens terminal and types "Hello World"

HID_DEVICE="/dev/hidg0"

# Function to send keystrokes
send_key() {
    echo -ne "\x00\x00$1\x00\x00\x00\x00\x00" > $HID_DEVICE
    echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" > $HID_DEVICE
}

# Wait for device to be ready
sleep 3

# Open terminal (GUI+T on Ubuntu)
echo -ne "\x08\x00\x17\x00\x00\x00\x00\x00" > $HID_DEVICE  # GUI+T
echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" > $HID_DEVICE

sleep 1

# Type "echo Hello World"
echo "Hello World" | while IFS= read -r -n1 char; do
    # Map character to HID code (simplified)
    send_key "\x04"  # Example key
    sleep 0.05
done

# Send Enter
send_key "\x28"
```

## Step 7: File Structure in Your Repo

Your zorangepipwn repo should now look like:

```
zorangepipwn/
├── README.md                        # Updated with dual-mode info
├── LICENSE
├── SPECIFICATIONS.md
├── INTEGRATION_PLAN.md              # NEW
├── setup.py                         # NEW combined setup
├── requirements.txt                 # USB gadget requirements
├── requirements-pwnagotchi.txt      # NEW Pwnagotchi requirements
├── Makefile                         # NEW
├── docs/
│   ├── os-install.md
│   ├── pwnagotchi-mode.md          # NEW
│   ├── usb-gadget-mode.md          # NEW
│   └── mode-switching.md           # NEW
├── platform/
│   └── requirements.md
├── scripts/
│   ├── orangepipwn-mode            # NEW mode switcher
│   ├── usb-gadget-setup.sh         # NEW USB gadget config
│   └── ... (your existing scripts)
├── config/
│   ├── default-config.toml         # NEW system config
│   └── ... (other configs)
├── orangepipwn/                     # NEW Python package
│   ├── __init__.py
│   ├── cli.py                      # NEW command-line interface
│   ├── pwnagotchi_core/            # NEW Pwnagotchi modules
│   │   ├── agent.py
│   │   ├── bettercap.py
│   │   ├── plugins/
│   │   ├── ui/
│   │   └── ...
│   └── usb/                        # Your USB gadget code
│       ├── __init__.py
│       ├── hid.py
│       └── ...
├── systemd/
│   ├── usb-gadget.service          # NEW
│   ├── pwnagotchi.service          # NEW
│   └── bettercap.service           # NEW
├── bin/
│   └── pwnagotchi                  # NEW Pwnagotchi launcher
└── payloads/
    ├── hid/
    │   └── examples/
    │       └── hello-world.sh      # NEW
    ├── mass_storage/
    └── network/
```

## Step 8: Testing

### Test Mode Switching

```bash
# Check initial status
sudo orangepipwn-mode status

# Switch to Pwnagotchi mode
sudo orangepipwn-mode set pwnagotchi
sudo reboot

# After reboot, verify
orangepipwn-mode status
systemctl status pwnagotchi

# Switch to USB gadget mode  
sudo orangepipwn-mode set usb-gadget
sudo reboot

# After reboot, verify
orangepipwn-mode status
systemctl status usb-gadget
```

### Test Pwnagotchi Mode

```bash
# Check if monitor mode is active
iw dev

# Check bettercap
sudo systemctl status bettercap

# View Pwnagotchi logs
sudo journalctl -u pwnagotchi -f

# Access web interface
# From another device: http://<orange-pi-ip>:8080
```

### Test USB Gadget Mode

```bash
# Check USB gadget status
sudo /usr/local/bin/usb-gadget-setup.sh status

# Check HID device
ls -l /dev/hidg0

# Check network device
ip addr show usb0

# Connect to host computer via USB-C
# The Orange Pi should appear as:
# - Network adapter (RNDIS)
# - HID keyboard
# - Mass storage (if enabled)
```

## Step 9: Commit to Your Repository

```bash
cd /path/to/zorangepipwn

# Add all new files
git add .

# Commit
git commit -m "Add Pwnagotchi integration and mode switching

- Integrated Pwnagotchi WiFi auditing platform
- Added mode switcher for dual-mode operation
- Created USB gadget service configuration
- Updated documentation and examples
- Added systemd service management"

# Push
git push origin main
```

## Step 10: Create GitHub Release

Create a release on GitHub with:
- Tag: `v1.0.0`
- Title: "OrangePiPwn v1.0 - Dual Mode Release"
- Description: Include the key features and installation instructions

## Troubleshooting

### Mode switch doesn't work
- Check logs: `sudo journalctl -u orangepipwn -f`
- Verify kernel modules: `lsmod | grep -E "dwc2|libcomposite"`
- Ensure you rebooted after switching

### Pwnagotchi mode issues
- Check WiFi supports monitor mode: `iw list`
- Verify bettercap is installed
- Check configuration: `/etc/pwnagotchi/config.toml`

### USB gadget issues
- Verify USB-C cable supports data
- Check UDC device: `ls /sys/class/udc/`
- Ensure modules are loaded: `lsmod | grep dwc2`

## Additional Resources

- [Pwnagotchi Documentation](https://pwnagotchi.ai)
- [Orange Pi Zero 2W Wiki](http://www.orangepi.org/orangepiwiki/)
- [Linux USB Gadget Framework](https://www.kernel.org/doc/html/latest/usb/gadget.html)

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

- Pwnagotchi components: GPL3
- USB Gadget components: MIT
- Combined work: GPL3 (due to GPL3 components)

---

**Ready to Deploy!** Follow these steps and your zorangepipwn repository will have full dual-mode capabilities.
