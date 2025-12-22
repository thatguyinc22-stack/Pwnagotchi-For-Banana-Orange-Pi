# Pwnagotchi Mode Switcher - Usage Guide

## Quick Start

After installation, you can use the `pwn-switch` command (or `python3 pwnagotchi-switcher.py`) to manage your Pwnagotchi modes.

## Understanding Pwnagotchi Modes

### AUTO Mode
- **Purpose**: Automatic WiFi handshake collection
- **Triggered by**: Power-only USB connection or AUTO flag file
- **Best for**: Running autonomously while mobile
- **How to enable**: `sudo pwn-switch auto`

### AI Mode (Default)
- **Purpose**: AI-powered optimization with reinforcement learning
- **Triggered by**: When AUTO flag is not present and not in MANU mode
- **Best for**: Learning and adapting to WiFi environments
- **How to enable**: `sudo pwn-switch ai`

### MANU Mode
- **Purpose**: Management, maintenance, and data access
- **Triggered by**: USB data connection to a computer
- **Best for**: Configuring, updating, and reviewing captured handshakes
- **How to enable**: Connect via USB data port

## Common Use Cases

### Scenario 1: Taking your Pwnagotchi on the go
```bash
# Before leaving, set to AUTO mode
sudo pwn-switch auto
sudo pwn-switch restart

# Now your device will consistently run in AUTO mode
```

### Scenario 2: Switching back to AI learning mode
```bash
# After manual testing, return to AI mode
sudo pwn-switch ai
sudo pwn-switch restart
```

### Scenario 3: Checking current status
```bash
# No sudo needed for status
pwn-switch status
```

### Scenario 4: Quick restart after config changes
```bash
# Restart the pwnagotchi service
sudo pwn-switch restart
```

## Advanced Usage

### Creating a boot script
You can create a systemd service or init script to automatically set your preferred mode on boot:

```bash
# Create a boot script
sudo nano /usr/local/bin/pwnagotchi-boot-mode.sh
```

Add:
```bash
#!/bin/bash
# Set Pwnagotchi to AUTO mode on boot
/usr/local/bin/pwn-switch auto
```

Make it executable:
```bash
sudo chmod +x /usr/local/bin/pwnagotchi-boot-mode.sh
```

### Checking service logs
```bash
# View Pwnagotchi service logs
sudo journalctl -u pwnagotchi -f

# Or use systemctl
sudo systemctl status pwnagotchi
```

### Verifying mode after switch
```bash
# Switch mode
sudo pwn-switch auto

# Check status
pwn-switch status

# Verify the AUTO flag exists
ls -la /root/.pwnagotchi-auto
```

## Troubleshooting

### Switcher says "service not found"
Your system might not have Pwnagotchi installed or the service is named differently. Check with:
```bash
systemctl list-units | grep pwn
```

### Mode doesn't change after switching
Some modes require a service restart or system reboot:
```bash
sudo pwn-switch restart
# or
sudo reboot
```

### Permission denied errors
The switcher needs root access for most operations:
```bash
sudo pwn-switch auto
```

### MANU mode not activating
MANU mode is hardware-triggered. Ensure:
1. You're connecting via the USB **data** port (not power-only)
2. Your computer recognizes the device as a USB network interface
3. Check with `lsusb` to see if the device is detected

## Integration with Other Tools

### Using with cron for scheduled mode changes
```bash
# Edit crontab
sudo crontab -e

# Switch to AUTO mode at 8 AM daily
0 8 * * * /usr/local/bin/pwn-switch auto

# Switch to AI mode at 6 PM daily
0 18 * * * /usr/local/bin/pwn-switch ai
```

### Using in custom scripts
```python
#!/usr/bin/env python3
import subprocess

# Switch to AUTO mode programmatically
result = subprocess.run(['pwn-switch', 'auto'], capture_output=True)
if result.returncode == 0:
    print("Successfully switched to AUTO mode")
```

## Tips and Best Practices

1. **Always check status first**: Run `pwn-switch status` to see current mode
2. **Restart after mode change**: Use `pwn-switch restart` for changes to take effect
3. **Keep backups**: Backup your `/etc/pwnagotchi/config.toml` before making changes
4. **Monitor logs**: Watch service logs when troubleshooting mode issues
5. **Document your setup**: Keep notes on which mode works best for your use case

## Getting Help

If you encounter issues:
1. Check the status with `pwn-switch status`
2. Review service logs: `sudo journalctl -u pwnagotchi -n 50`
3. Verify file permissions: `ls -la /root/.pwnagotchi-auto`
4. Open an issue on GitHub with details about your setup

## Related Resources

- [Pwnagotchi Official Documentation](https://pwnagotchi.ai/)
- [Pwnagotchi-For-Banana-Orange-Pi GitHub](https://github.com/Fikolmij/Pwnagotchi-For-Banana-Orange-Pi)
- [Pwnagotchi Discord Community](https://discord.gg/pwnagotchi)
