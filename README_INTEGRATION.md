# Integration Files for ZorangePiPwn

## Overview

This directory contains all the files you need to integrate the Pwnagotchi WiFi auditing platform into your **zorangepipwn** repository, creating a powerful dual-mode penetration testing platform for the Orange Pi Zero 2W.

## What You Have

### 📄 Documentation (4 files)

1. **INTEGRATION_PLAN.md** - Complete architecture and planning document
2. **INTEGRATION_GUIDE.md** - Step-by-step integration instructions
3. **QUICK_REFERENCE.md** - Command reference and quick tips
4. **FILES_CREATED.md** - Summary of all files and what they do

### 🔧 Scripts (2 files)

5. **scripts/orangepipwn-mode** - Mode switcher (Bash script)
6. **scripts/usb-gadget-setup.sh** - USB gadget configuration (Bash script)

### ⚙️ Configuration (1 file)

7. **config/default-config.toml** - Default system configuration

### 🚀 Systemd Service (1 file)

8. **systemd/usb-gadget.service** - USB gadget mode service

### 🛠️ Build Tool (1 file)

9. **Makefile.orangepipwn** - Installation and management helper

## Quick Start

### Step 1: Read the Documentation

Start here in this order:

1. **FILES_CREATED.md** ← Start here for overview
2. **INTEGRATION_PLAN.md** ← Understand the architecture
3. **INTEGRATION_GUIDE.md** ← Follow step-by-step
4. **QUICK_REFERENCE.md** ← Keep for daily use

### Step 2: Copy Files to Your Repo

```bash
# Navigate to your zorangepipwn repository
cd /path/to/your/zorangepipwn

# Copy integration files
cp /path/to/Pwnagotchi-For-Banana-Orange-Pi/INTEGRATION_PLAN.md .
cp /path/to/Pwnagotchi-For-Banana-Orange-Pi/INTEGRATION_GUIDE.md .
cp /path/to/Pwnagotchi-For-Banana-Orange-Pi/QUICK_REFERENCE.md .
cp /path/to/Pwnagotchi-For-Banana-Orange-Pi/scripts/orangepipwn-mode scripts/
cp /path/to/Pwnagotchi-For-Banana-Orange-Pi/scripts/usb-gadget-setup.sh scripts/
cp /path/to/Pwnagotchi-For-Banana-Orange-Pi/config/default-config.toml config/
cp /path/to/Pwnagotchi-For-Banana-Orange-Pi/systemd/usb-gadget.service systemd/
cp /path/to/Pwnagotchi-For-Banana-Orange-Pi/Makefile.orangepipwn Makefile
```

### Step 3: Copy Pwnagotchi Core

```bash
# Create directory structure
mkdir -p orangepipwn/pwnagotchi_core

# Copy Pwnagotchi Python modules
cp -r /path/to/Pwnagotchi-For-Banana-Orange-Pi/pwnagotchi/* orangepipwn/pwnagotchi_core/

# Copy supporting files
cp -r /path/to/Pwnagotchi-For-Banana-Orange-Pi/builder ./
cp -r /path/to/Pwnagotchi-For-Banana-Orange-Pi/bin ./
cp /path/to/Pwnagotchi-For-Banana-Orange-Pi/requirements.txt requirements-pwnagotchi.txt
```

### Step 4: Follow the Integration Guide

Open **INTEGRATION_GUIDE.md** and follow all 10 steps to complete the integration.

## What This Does

### Two Modes in One Device

**Mode 1: Pwnagotchi** (WiFi Auditing)
- Captures WiFi handshakes automatically
- AI learns from environment
- Web interface for management
- Supports various displays
- Mesh networking with other units

**Mode 2: USB Gadget** (Attack Platform)
- HID keyboard attacks
- Mass storage emulation
- USB network sharing
- Your existing P4wnP1-style payloads

### Easy Mode Switching

```bash
# Switch between modes
sudo orangepipwn-mode set pwnagotchi
sudo orangepipwn-mode set usb-gadget

# Check status
orangepipwn-mode status
```

## Architecture Overview

```
┌─────────────────────────────────────────┐
│        Orange Pi Zero 2W                │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐  ┌─────────────────┐ │
│  │ Pwnagotchi   │  │  USB Gadget     │ │
│  │ Mode         │  │  Mode           │ │
│  │              │  │                 │ │
│  │ - WiFi Hunt  │  │ - HID Attacks   │ │
│  │ - AI Learn   │  │ - Mass Storage  │ │
│  │ - Web UI     │  │ - Network Share │ │
│  └──────────────┘  └─────────────────┘ │
│         ▲                  ▲            │
│         └──────────────────┘            │
│                │                        │
│      ┌─────────┴─────────┐             │
│      │  Mode Switcher    │             │
│      │  orangepipwn-mode │             │
│      └───────────────────┘             │
└─────────────────────────────────────────┘
```

## File Descriptions

### Documentation Files

#### INTEGRATION_PLAN.md
- **Purpose**: High-level architecture and planning
- **Contains**: Directory structure, component descriptions, roadmap
- **Read when**: Planning the integration

#### INTEGRATION_GUIDE.md
- **Purpose**: Step-by-step integration instructions
- **Contains**: All steps to integrate into your repo
- **Read when**: Actually doing the integration

#### QUICK_REFERENCE.md
- **Purpose**: Daily usage reference
- **Contains**: Commands, locations, troubleshooting
- **Read when**: Using the system day-to-day

#### FILES_CREATED.md
- **Purpose**: Summary of all created files
- **Contains**: What each file does and why
- **Read when**: Getting oriented

### Script Files

#### scripts/orangepipwn-mode
- **Language**: Bash
- **Purpose**: Main mode switcher
- **Commands**: set, status, config, init, help
- **Installs to**: `/usr/local/bin/orangepipwn-mode`
- **Permissions**: 755 (executable)

#### scripts/usb-gadget-setup.sh
- **Language**: Bash
- **Purpose**: Configure USB gadget hardware
- **Commands**: start, stop, restart, status
- **Installs to**: `/usr/local/bin/usb-gadget-setup.sh`
- **Permissions**: 755 (executable)

### Configuration File

#### config/default-config.toml
- **Format**: TOML
- **Purpose**: System-wide configuration
- **Installs to**: `/etc/orangepipwn/config.toml`
- **Permissions**: 644 (read-write for root)
- **Contents**: Settings for both modes

### Systemd Service

#### systemd/usb-gadget.service
- **Type**: oneshot service
- **Purpose**: Manages USB gadget mode
- **Installs to**: `/etc/systemd/system/usb-gadget.service`
- **Permissions**: 644

### Build Tool

#### Makefile.orangepipwn
- **Purpose**: Simplify installation and management
- **Targets**: install, uninstall, status, switch-*, clean
- **Usage**: `sudo make -f Makefile.orangepipwn install`

## Installation Workflow

```
1. Copy files to your zorangepipwn repo
   ↓
2. Copy Pwnagotchi core modules
   ↓
3. Create combined setup.py
   ↓
4. Update README.md
   ↓
5. Test locally on Orange Pi
   ↓
6. Commit and push to GitHub
   ↓
7. Users can now install your enhanced repo
```

## User Installation (After You Integrate)

Once you've integrated these files, users will install like this:

```bash
# Clone your repo
git clone https://github.com/thatguyinc22-stack/zorangepipwn.git
cd zorangepipwn

# Install
sudo python3 setup.py install
# OR
sudo make install

# Initialize
sudo orangepipwn-mode init

# Choose mode
sudo orangepipwn-mode set pwnagotchi

# Reboot
sudo reboot
```

## Testing Checklist

After integration, test:

- ✅ Mode switching works
- ✅ Pwnagotchi mode starts correctly
- ✅ USB gadget mode configures properly
- ✅ Web interface accessible
- ✅ HID device functional
- ✅ Network interface works
- ✅ Services start/stop correctly
- ✅ Configuration persists across reboots

## Troubleshooting Integration

### If files don't work:
1. Check file permissions: `ls -la scripts/`
2. Verify paths in scripts match your structure
3. Check syntax: `bash -n scripts/orangepipwn-mode`

### If integration seems complex:
1. Start with just the mode switcher
2. Add USB gadget support
3. Add Pwnagotchi components last
4. Test after each major addition

### If you need help:
1. Review the INTEGRATION_GUIDE.md step-by-step
2. Check error messages in logs
3. Compare against this repo's structure
4. Open an issue on GitHub

## Next Steps

1. ✅ **Read FILES_CREATED.md** (this file)
2. ⬜ **Read INTEGRATION_PLAN.md**
3. ⬜ **Read INTEGRATION_GUIDE.md**
4. ⬜ **Copy files to your repo**
5. ⬜ **Copy Pwnagotchi core**
6. ⬜ **Follow integration guide steps**
7. ⬜ **Test on Orange Pi**
8. ⬜ **Update your README**
9. ⬜ **Commit and push**
10. ⬜ **Create release**

## Support

### During Integration
- Follow INTEGRATION_GUIDE.md exactly
- Test each component before moving on
- Keep backups of your original files

### After Integration
- Provide QUICK_REFERENCE.md to users
- Point users to troubleshooting sections
- Maintain both modes separately

## License Reminder

- **Pwnagotchi**: GPL3 (must be preserved)
- **Your USB work**: MIT (your choice)
- **Combined**: GPL3 (required by GPL3 components)

Update your LICENSE file accordingly.

## Credits

When you integrate this, remember to credit:
- **Pwnagotchi** by @evilsocket
- **This integration work**
- **Your original USB gadget work**
- **Orange Pi community**

## Questions?

If something is unclear:

1. Check the INTEGRATION_GUIDE.md
2. Review the QUICK_REFERENCE.md
3. Look at this repo's structure for examples
4. Open an issue on GitHub

## Repository Structure After Integration

```
zorangepipwn/
├── README.md ← Update with dual-mode info
├── LICENSE ← Update to GPL3
├── INTEGRATION_PLAN.md ← NEW
├── INTEGRATION_GUIDE.md ← NEW
├── QUICK_REFERENCE.md ← NEW
├── setup.py ← NEW combined installer
├── Makefile ← NEW from Makefile.orangepipwn
├── requirements.txt ← Your existing
├── requirements-pwnagotchi.txt ← NEW
├── scripts/
│   ├── orangepipwn-mode ← NEW
│   ├── usb-gadget-setup.sh ← NEW
│   └── ... (your existing scripts)
├── config/
│   ├── default-config.toml ← NEW
│   └── ... (your existing configs)
├── systemd/
│   ├── usb-gadget.service ← NEW
│   ├── pwnagotchi.service ← NEW
│   └── bettercap.service ← NEW
├── orangepipwn/ ← NEW Python package
│   ├── __init__.py
│   ├── pwnagotchi_core/ ← NEW Pwnagotchi modules
│   └── usb/ ← Your existing USB code
└── ... (rest of your files)
```

---

## Ready to Start?

Open **INTEGRATION_GUIDE.md** and begin! Good luck! 🚀

---

**Created**: December 18, 2025  
**Purpose**: Integration materials for ZorangePiPwn project  
**Status**: Ready to use  
**Repo**: Currently in Pwnagotchi-For-Banana-Orange-Pi, ready to copy to zorangepipwn
