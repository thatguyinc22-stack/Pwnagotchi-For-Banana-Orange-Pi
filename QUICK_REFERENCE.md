# OrangePiPwn Dual-Mode Quick Reference

## Mode Switching Commands

```bash
# Initialize system (first time only)
sudo orangepipwn-mode init

# Switch to Pwnagotchi (WiFi Auditing) Mode
sudo orangepipwn-mode set pwnagotchi
sudo reboot

# Switch to USB Gadget (Attack) Mode
sudo orangepipwn-mode set usb-gadget
sudo reboot

# Check current status
orangepipwn-mode status

# View configuration
orangepipwn-mode config
```

## Pwnagotchi Mode

### What It Does
- WiFi monitoring and handshake capture
- AI-powered learning
- Mesh networking with other Pwnagotchi units
- Web interface for management

### After Switching to Pwnagotchi Mode

```bash
# Check if services are running
systemctl status pwnagotchi
systemctl status bettercap

# View logs
journalctl -u pwnagotchi -f

# Check WiFi is in monitor mode
iw dev

# Access web interface from another device
http://<orange-pi-ip>:8080

# View captured handshakes
ls /root/handshakes/
```

### Configuration
Edit `/etc/pwnagotchi/config.toml`:
- Set your device name
- Configure display (if using one)
- Enable/disable plugins
- Set whitelist networks

### Key Locations
- **Config**: `/etc/pwnagotchi/config.toml`
- **Handshakes**: `/root/handshakes/`
- **Logs**: `/var/log/pwnagotchi.log`
- **Web UI**: Port 8080

## USB Gadget Mode

### What It Does
- HID keyboard/mouse attacks
- Mass storage emulation
- USB network sharing
- P4wnP1-style payload execution

### After Switching to USB Gadget Mode

```bash
# Check if USB gadget is configured
usb-gadget-setup.sh status

# View USB gadget configuration
ls /sys/kernel/config/usb_gadget/orangepipwn/

# Check network interface
ip addr show usb0

# List HID device
ls -l /dev/hidg0

# Check mass storage
ls -l /opt/orangepipwn/storage.img
```

### Running HID Payloads

```bash
# Basic payload execution
sudo /opt/orangepipwn/payloads/hid/your-payload.sh

# Send keys directly to HID device
echo -ne "\x00\x00\x04\x00\x00\x00\x00\x00" > /dev/hidg0  # Press 'a'
echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" > /dev/hidg0  # Release
```

### Configuration
Edit `/etc/orangepipwn/config.toml`:
- USB vendor/product IDs
- Mass storage settings
- Network configuration
- Payload settings

### Key Locations
- **Config**: `/etc/orangepipwn/config.toml`
- **Payloads**: `/opt/orangepipwn/payloads/`
- **Storage Image**: `/opt/orangepipwn/storage.img`
- **Logs**: `/var/log/orangepipwn/`
- **HID Device**: `/dev/hidg0`

## Service Management

### Pwnagotchi Mode Services
```bash
# Start/stop/restart Pwnagotchi
sudo systemctl start pwnagotchi
sudo systemctl stop pwnagotchi
sudo systemctl restart pwnagotchi

# Enable/disable autostart
sudo systemctl enable pwnagotchi
sudo systemctl disable pwnagotchi

# View logs
sudo journalctl -u pwnagotchi -f
```

### USB Gadget Mode Services
```bash
# Start/stop USB gadget
sudo systemctl start usb-gadget
sudo systemctl stop usb-gadget

# Manual control
sudo usb-gadget-setup.sh start
sudo usb-gadget-setup.sh stop
sudo usb-gadget-setup.sh restart
sudo usb-gadget-setup.sh status
```

## Common Tasks

### Connect to Orange Pi

**In Pwnagotchi Mode:**
- WiFi: Connect to its AP (if configured)
- Web: http://<ip>:8080
- SSH: ssh root@<ip>

**In USB Gadget Mode:**
- USB Network: Automatic DHCP (10.0.0.1)
- SSH via USB: ssh root@10.0.0.1

### View Captured Handshakes (Pwnagotchi)
```bash
# List handshakes
ls -lh /root/handshakes/

# View specific handshake info
aircrack-ng /root/handshakes/captured.pcap

# Copy handshakes for cracking elsewhere
scp root@<ip>:/root/handshakes/*.pcap .
```

### Create HID Payload (USB Gadget)
```bash
# Create payload file
nano /opt/orangepipwn/payloads/hid/mypayload.sh

# Make executable
chmod +x /opt/orangepipwn/payloads/hid/mypayload.sh

# Test payload
sudo /opt/orangepipwn/payloads/hid/mypayload.sh
```

### Mount Mass Storage from Host
```bash
# On host computer (after connecting USB)
# Linux
sudo mount /dev/sdX1 /mnt/orangepipwn

# Windows
# Should auto-mount as new drive

# macOS
# Should appear in Finder
```

## Troubleshooting

### Mode Switch Issues
```bash
# Check logs
sudo journalctl -u orangepipwn -f

# Verify current mode
orangepipwn-mode status

# Force mode reset
sudo orangepipwn-mode set pwnagotchi
sudo reboot
```

### Pwnagotchi Not Starting
```bash
# Check bettercap
sudo systemctl status bettercap

# Test WiFi monitor mode
sudo iw dev wlan0 set type monitor
sudo ip link set wlan0 up

# View detailed errors
sudo journalctl -u pwnagotchi -n 50
```

### USB Gadget Not Recognized
```bash
# Check USB cable (must support data)
# Check modules
lsmod | grep dwc2

# Reload modules
sudo modprobe -r dwc2
sudo modprobe dwc2

# Restart gadget
sudo usb-gadget-setup.sh restart
```

### Network Issues in USB Gadget Mode
```bash
# Check usb0 interface
ip addr show usb0

# Restart network
sudo ip link set usb0 down
sudo ip link set usb0 up

# Check DHCP server
ps aux | grep dnsmasq
```

## Hardware Checks

### WiFi Capabilities
```bash
# Check WiFi card
lsusb | grep -i wireless
ip link show wlan0

# Check monitor mode support
iw list | grep -A 10 "Supported interface modes"

# Test monitor mode
sudo iw dev wlan0 set type monitor
```

### USB Controller
```bash
# Check USB controller
lsusb -t

# Check UDC device
ls /sys/class/udc/

# Check dwc2 module
lsmod | grep dwc2
```

### Display (Pwnagotchi Mode)
```bash
# Check I2C (for OLED)
i2cdetect -y 1

# Check SPI (for e-ink)
ls -l /dev/spidev*

# Test display
sudo pwnagotchi --debug
```

## File Locations Quick Reference

| Item | Location |
|------|----------|
| OrangePiPwn Config | `/etc/orangepipwn/config.toml` |
| Pwnagotchi Config | `/etc/pwnagotchi/config.toml` |
| Mode State | `/var/lib/orangepipwn/current_mode` |
| Handshakes | `/root/handshakes/` |
| HID Payloads | `/opt/orangepipwn/payloads/hid/` |
| Storage Image | `/opt/orangepipwn/storage.img` |
| Logs | `/var/log/orangepipwn/` |
| HID Device | `/dev/hidg0` |
| Mode Switcher | `/usr/local/bin/orangepipwn-mode` |
| USB Setup Script | `/usr/local/bin/usb-gadget-setup.sh` |

## Key Keyboard Shortcuts (HID Payloads)

HID Scancodes (2nd byte in HID report):
- `0x04` = A
- `0x28` = Enter
- `0x2C` = Space
- `0x17` = T
- Modifier: `0x08` = GUI/Windows key (1st byte)

Example: GUI+R (Run dialog)
```bash
echo -ne "\x08\x00\x15\x00\x00\x00\x00\x00" > /dev/hidg0
echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" > /dev/hidg0
```

## Update Commands

```bash
# Update system
sudo apt update && sudo apt upgrade

# Update OrangePiPwn
cd /path/to/zorangepipwn
git pull
sudo python3 setup.py install

# Reload services
sudo systemctl daemon-reload
```

## Emergency Recovery

If system won't boot or mode switch fails:

1. **Boot from SD card on another device**
2. **Mount the Orange Pi's SD card**
3. **Edit config files or reset mode:**
   ```bash
   echo "pwnagotchi" > /mnt/var/lib/orangepipwn/current_mode
   ```
4. **Disable problematic services:**
   ```bash
   rm /mnt/etc/systemd/system/multi-user.target.wants/usb-gadget.service
   ```
5. **Remount and boot**

## Resources

- Full Documentation: See `INTEGRATION_GUIDE.md`
- Integration Plan: See `INTEGRATION_PLAN.md`
- Pwnagotchi Docs: https://pwnagotchi.ai
- Orange Pi Wiki: http://www.orangepi.org/orangepiwiki/

---

**Save this file for quick reference while using OrangePiPwn!**
