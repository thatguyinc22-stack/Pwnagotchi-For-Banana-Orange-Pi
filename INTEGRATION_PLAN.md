# ZorangePiPwn + Pwnagotchi Integration Plan

## Overview
This document outlines the integration of Pwnagotchi WiFi auditing capabilities into the ZorangePiPwn platform, creating a dual-mode system that can switch between:
1. **Pwnagotchi Mode** - WiFi auditing/AI learning/handshake capture
2. **USB Gadget Mode** - HID/mass storage/network USB attack payloads

## Architecture

### Mode Switcher System
The system uses a configuration-based approach with systemd service management:

```
/usr/local/bin/orangepipwn-mode       # Main mode switcher script
/etc/orangepipwn/config.toml          # System configuration
/etc/systemd/system/orangepipwn.service  # Orchestrator service
```

### Directory Structure
```
zorangepipwn/
├── README.md
├── LICENSE
├── SPECIFICATIONS.md
├── setup.py                          # NEW: Python package installer
├── requirements.txt                  # NEW: Python dependencies
├── Makefile                          # NEW: Build automation
├── docs/
│   ├── os-install.md
│   ├── pwnagotchi-mode.md           # NEW
│   ├── usb-gadget-mode.md           # NEW
│   └── mode-switching.md            # NEW
├── platform/
│   └── requirements.md
├── scripts/
│   ├── setup-pwnagotchi.sh          # NEW
│   ├── setup-usb-gadget.sh
│   └── mode-switcher.sh             # NEW
├── config/
│   ├── default-config.toml          # NEW: Default system config
│   ├── pwnagotchi-defaults.toml     # NEW: Pwnagotchi config
│   └── usb-gadget-profiles/         # NEW: USB gadget configs
├── orangepipwn/                      # NEW: Main Python package
│   ├── __init__.py
│   ├── agent.py                     # Pwnagotchi agent
│   ├── bettercap.py                 # Bettercap interface
│   ├── grid.py                      # Grid integration
│   ├── utils.py
│   ├── log.py
│   ├── voice.py
│   ├── usb/                         # USB gadget mode
│   │   ├── __init__.py
│   │   ├── hid.py
│   │   ├── mass_storage.py
│   │   └── network.py
│   ├── ai/                          # AI learning components
│   │   ├── __init__.py
│   │   ├── gym.py
│   │   └── train.py
│   ├── plugins/                     # Plugin system
│   │   ├── __init__.py
│   │   └── default/
│   └── ui/                          # Display/web interface
│       ├── __init__.py
│       ├── display.py
│       ├── hw/                      # Hardware display drivers
│       └── web/                     # Web UI
├── systemd/                          # NEW
│   ├── orangepipwn.service
│   ├── pwnagotchi.service
│   └── usb-gadget.service
└── payloads/                         # USB attack payloads
    ├── hid/
    ├── mass_storage/
    └── network/
```

## Key Components to Add

### 1. Mode Switcher (`/usr/local/bin/orangepipwn-mode`)
- Switch between Pwnagotchi and USB Gadget modes
- Manage systemd services
- Configure network interfaces
- Handle USB gadget setup/teardown

### 2. Configuration System
- TOML-based configuration files
- Mode-specific settings
- Plugin configuration
- Network settings

### 3. Pwnagotchi Components
From this repo, we need:
- Core Python package (`pwnagotchi/` → `orangepipwn/pwnagotchi_core/`)
- Plugin system
- Display drivers (modified for Orange Pi)
- AI/learning components
- Web interface
- Bettercap integration

### 4. USB Gadget System
- HID keyboard/mouse emulation
- Mass storage emulation
- RNDIS/ECM networking
- Payload management

### 5. Systemd Services
- `orangepipwn.service` - Main orchestrator
- `pwnagotchi-mode.service` - Pwnagotchi mode
- `usb-gadget-mode.service` - USB gadget mode

## Installation Process

### Prerequisites
```bash
# Orange Pi Zero 2W running Ubuntu 22.04 or Orange Pi OS
sudo apt update
sudo apt install -y python3 python3-pip git build-essential \
    libnetfilter-queue-dev libffi-dev libssl-dev \
    python3-dev python3-pil python3-numpy
```

### Installation Steps
1. Clone repository
2. Run setup script: `sudo python3 setup.py install`
3. Configure system: Edit `/etc/orangepipwn/config.toml`
4. Enable services: `sudo systemctl enable orangepipwn`
5. Select mode: `sudo orangepipwn-mode set pwnagotchi` or `usb-gadget`
6. Reboot

## Mode Switching

### Switch to Pwnagotchi Mode
```bash
sudo orangepipwn-mode set pwnagotchi
sudo reboot
```

Features active:
- WiFi monitor mode
- Bettercap for packet capture
- AI learning
- Handshake collection
- Web interface on port 8080
- Optional display support

### Switch to USB Gadget Mode
```bash
sudo orangepipwn-mode set usb-gadget
sudo reboot
```

Features active:
- USB gadget configuration
- HID attack payloads
- Mass storage emulation
- Network sharing via USB
- Payload execution

### Query Current Mode
```bash
orangepipwn-mode status
```

## Configuration Files

### `/etc/orangepipwn/config.toml`
```toml
[system]
mode = "pwnagotchi"  # or "usb-gadget"
hostname = "orangepipwn"
auto_mode_switch = false

[pwnagotchi]
name = "orangepipwn"
enabled = true
config_file = "/etc/pwnagotchi/config.toml"
display = "none"  # or "waveshare_v2", "oled", etc.

[usb_gadget]
enabled = false
vendor_id = "0x1d6b"
product_id = "0x0104"
manufacturer = "Orange Pi"
product = "Multifunction USB Device"
serial = "fedcba9876543210"

[usb_gadget.hid]
enabled = true
payloads_dir = "/opt/orangepipwn/payloads/hid"

[usb_gadget.mass_storage]
enabled = false
image_file = "/opt/orangepipwn/storage.img"
```

## Hardware Compatibility

### Tested Displays for Pwnagotchi Mode
- Waveshare 2.13" e-Paper (SPI)
- SSD1306 OLED 128x64 (I2C)
- ST7789 TFT displays

### USB Gadget Hardware
- Orange Pi Zero 2W USB-C port (dwc2 controller)
- Supports composite USB gadget

## Features Comparison

| Feature | Pwnagotchi Mode | USB Gadget Mode |
|---------|----------------|-----------------|
| WiFi Scanning | ✅ | ❌ |
| Handshake Capture | ✅ | ❌ |
| AI Learning | ✅ | ❌ |
| Display UI | ✅ | ⚠️ (limited) |
| Web Interface | ✅ | ⚠️ (payload mgmt) |
| HID Attacks | ❌ | ✅ |
| Mass Storage | ❌ | ✅ |
| USB Networking | ❌ | ✅ |
| Mesh/Grid | ✅ | ❌ |
| Bluetooth | ⚠️ (tether) | ⚠️ (future) |

## Development Roadmap

### Phase 1: Core Integration ✅
- [x] Mode switcher script
- [x] Configuration system
- [x] Directory structure
- [x] Documentation

### Phase 2: Pwnagotchi Integration
- [ ] Port core Pwnagotchi code
- [ ] Adapt for Orange Pi Zero 2W
- [ ] Remove Raspberry Pi specific code
- [ ] Configure display drivers
- [ ] Test WiFi monitor mode

### Phase 3: USB Gadget Enhancement
- [ ] Refactor existing USB gadget code
- [ ] Create payload management system
- [ ] Web-based payload selector
- [ ] Automated payload execution

### Phase 4: Unified Interface
- [ ] Unified web interface for both modes
- [ ] Status dashboard
- [ ] Easy mode switching via web
- [ ] Log viewer

### Phase 5: Advanced Features
- [ ] Hybrid mode (limited WiFi + USB)
- [ ] Scheduled mode switching
- [ ] Remote management
- [ ] Cloud sync for handshakes/logs

## Security Considerations

1. **Permissions**: Mode switching requires root access
2. **USB Gadget**: Only use on devices you own
3. **WiFi Auditing**: Legal compliance required
4. **Default Passwords**: Change all default credentials
5. **Web Interface**: Enable authentication in production

## Troubleshooting

### Mode Switch Fails
1. Check logs: `journalctl -u orangepipwn -f`
2. Verify USB gadget support: `lsmod | grep dwc2`
3. Check WiFi monitor support: `iw list | grep monitor`

### Pwnagotchi Mode Issues
1. Bettercap not starting: Check service logs
2. No handshakes: Verify monitor mode active
3. Display not working: Check SPI/I2C enabled

### USB Gadget Mode Issues
1. Not recognized by host: Check USB cables/ports
2. HID not working: Verify gadget modules loaded
3. Network not working: Check RNDIS/ECM configuration

## Contributing

Contributions welcome! Please see CONTRIBUTING.md

## License

Combined under GPL3 (Pwnagotchi) and MIT (ZorangePiPwn components)

## Credits

- **Pwnagotchi**: Original project by @evilsocket
- **P4wnP1 A.L.O.A.**: USB attack inspiration
- **Orange Pi Community**: Hardware support
- **ZorangePiPwn**: Integration and adaptation

---

**Last Updated**: December 18, 2025
