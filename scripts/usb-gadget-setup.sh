#!/bin/bash
#
# USB Gadget Configuration Script for Orange Pi Zero 2W
# Configures composite USB gadget with HID, Mass Storage, and Network functions
#

set -e

GADGET_NAME="orangepipwn"
GADGET_DIR="/sys/kernel/config/usb_gadget/$GADGET_NAME"
UDC_DEVICE=""

# USB IDs
VENDOR_ID="0x1d6b"    # Linux Foundation
PRODUCT_ID="0x0104"   # Multifunction Composite Gadget
DEVICE_BCD="0x0100"   # Device release number
USB_BCD="0x0200"      # USB 2.0

# Strings
MANUFACTURER="Orange Pi"
PRODUCT="OrangePiPwn MultiGadget"
SERIAL="fedcba9876543210"

# Network configuration
HOST_MAC="48:6f:73:74:50:43"  # HostPC
DEV_MAC="42:61:64:55:53:42"   # BadUSB

# HID Report Descriptor (keyboard)
HID_REPORT_DESC="05010906a1018501050719e029e71500250175019508810295017508810195057501050819012905910295017503910195067508150025650507190029658100c0"

# Mass storage image
STORAGE_IMAGE="/opt/orangepipwn/storage.img"
STORAGE_SIZE_MB=64

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Find UDC device
find_udc() {
    for udc in /sys/class/udc/*; do
        if [ -e "$udc" ]; then
            UDC_DEVICE=$(basename "$udc")
            log "Found UDC device: $UDC_DEVICE"
            return 0
        fi
    done
    log "ERROR: No UDC device found"
    return 1
}

# Create mass storage image if it doesn't exist
create_storage_image() {
    if [ ! -f "$STORAGE_IMAGE" ]; then
        log "Creating mass storage image ($STORAGE_SIZE_MB MB)..."
        dd if=/dev/zero of="$STORAGE_IMAGE" bs=1M count=$STORAGE_SIZE_MB
        mkdosfs "$STORAGE_IMAGE"
        log "Mass storage image created"
    else
        log "Mass storage image already exists"
    fi
}

# Setup USB gadget
setup_gadget() {
    log "Setting up USB gadget..."
    
    # Load required modules
    modprobe libcomposite
    modprobe dwc2
    
    # Find UDC device
    find_udc || exit 1
    
    # Create gadget directory
    if [ -d "$GADGET_DIR" ]; then
        log "Gadget already exists, removing..."
        remove_gadget
    fi
    
    mkdir -p "$GADGET_DIR"
    cd "$GADGET_DIR"
    
    # Set USB IDs
    echo "$VENDOR_ID" > idVendor
    echo "$PRODUCT_ID" > idProduct
    echo "$DEVICE_BCD" > bcdDevice
    echo "$USB_BCD" > bcdUSB
    
    # Device class (use composite)
    echo "0xEF" > bDeviceClass
    echo "0x02" > bDeviceSubClass
    echo "0x01" > bDeviceProtocol
    
    # Create strings directory
    mkdir -p strings/0x409
    echo "$MANUFACTURER" > strings/0x409/manufacturer
    echo "$PRODUCT" > strings/0x409/product
    echo "$SERIAL" > strings/0x409/serialnumber
    
    # Create configuration
    mkdir -p configs/c.1
    echo "250" > configs/c.1/MaxPower
    echo "0x80" > configs/c.1/bmAttributes  # Bus powered
    
    mkdir -p configs/c.1/strings/0x409
    echo "Config 1: RNDIS + HID + Mass Storage" > configs/c.1/strings/0x409/configuration
    
    # Function 1: RNDIS (Network)
    log "Configuring RNDIS network function..."
    mkdir -p functions/rndis.usb0
    echo "$HOST_MAC" > functions/rndis.usb0/host_addr
    echo "$DEV_MAC" > functions/rndis.usb0/dev_addr
    ln -s functions/rndis.usb0 configs/c.1/
    
    # Function 2: HID (Keyboard)
    log "Configuring HID keyboard function..."
    mkdir -p functions/hid.usb0
    echo 1 > functions/hid.usb0/protocol       # Keyboard
    echo 1 > functions/hid.usb0/subclass       # Boot interface
    echo 8 > functions/hid.usb0/report_length  # 8 bytes
    echo -ne "\x$HID_REPORT_DESC" | xxd -r -p > functions/hid.usb0/report_desc
    ln -s functions/hid.usb0 configs/c.1/
    
    # Function 3: Mass Storage (optional, if image exists)
    if [ -f "$STORAGE_IMAGE" ]; then
        log "Configuring mass storage function..."
        mkdir -p functions/mass_storage.usb0
        echo 1 > functions/mass_storage.usb0/stall
        echo 0 > functions/mass_storage.usb0/lun.0/cdrom
        echo 0 > functions/mass_storage.usb0/lun.0/ro
        echo 0 > functions/mass_storage.usb0/lun.0/nofua
        echo "$STORAGE_IMAGE" > functions/mass_storage.usb0/lun.0/file
        ln -s functions/mass_storage.usb0 configs/c.1/
    else
        log "Skipping mass storage (image not found)"
    fi
    
    # Enable gadget
    log "Enabling USB gadget on $UDC_DEVICE..."
    echo "$UDC_DEVICE" > UDC
    
    log "USB gadget configured successfully"
    
    # Wait for network interface
    sleep 2
    
    # Configure network interface
    if ip link show usb0 &>/dev/null; then
        log "Configuring usb0 network interface..."
        ip addr add 10.0.0.1/24 dev usb0
        ip link set usb0 up
        
        # Enable IP forwarding
        echo 1 > /proc/sys/net/ipv4/ip_forward
        
        # Setup NAT (if wlan0 is available)
        if ip link show wlan0 &>/dev/null; then
            iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
            iptables -A FORWARD -i usb0 -o wlan0 -j ACCEPT
            iptables -A FORWARD -i wlan0 -o usb0 -m state --state RELATED,ESTABLISHED -j ACCEPT
            log "NAT configured for internet sharing"
        fi
        
        # Start DHCP server for USB network
        if command -v dnsmasq &>/dev/null; then
            dnsmasq --interface=usb0 --dhcp-range=10.0.0.2,10.0.0.254,12h \
                    --dhcp-option=3,10.0.0.1 --dhcp-option=6,8.8.8.8 \
                    --no-daemon &
            log "DHCP server started on usb0"
        fi
    fi
}

# Remove USB gadget
remove_gadget() {
    log "Removing USB gadget..."
    
    if [ -d "$GADGET_DIR" ]; then
        cd "$GADGET_DIR"
        
        # Disable gadget
        if [ -f "UDC" ]; then
            echo "" > UDC 2>/dev/null || true
        fi
        
        # Remove configuration links
        rm -f configs/c.1/rndis.usb0 2>/dev/null || true
        rm -f configs/c.1/hid.usb0 2>/dev/null || true
        rm -f configs/c.1/mass_storage.usb0 2>/dev/null || true
        
        # Remove functions
        rmdir functions/rndis.usb0 2>/dev/null || true
        rmdir functions/hid.usb0 2>/dev/null || true
        rmdir functions/mass_storage.usb0 2>/dev/null || true
        
        # Remove configuration
        rmdir configs/c.1/strings/0x409 2>/dev/null || true
        rmdir configs/c.1 2>/dev/null || true
        
        # Remove strings
        rmdir strings/0x409 2>/dev/null || true
        
        # Remove gadget
        cd /
        rmdir "$GADGET_DIR" 2>/dev/null || true
        
        log "USB gadget removed"
    else
        log "No gadget to remove"
    fi
    
    # Kill dnsmasq
    pkill -f "dnsmasq.*usb0" 2>/dev/null || true
}

# Show status
show_status() {
    echo "USB Gadget Status:"
    echo "=================="
    
    if [ -d "$GADGET_DIR" ]; then
        echo "Gadget: Configured"
        echo "Name: $GADGET_NAME"
        
        if [ -f "$GADGET_DIR/UDC" ]; then
            local udc=$(cat "$GADGET_DIR/UDC")
            if [ -n "$udc" ]; then
                echo "UDC: $udc (enabled)"
            else
                echo "UDC: Not bound"
            fi
        fi
        
        echo ""
        echo "Functions:"
        [ -d "$GADGET_DIR/functions/rndis.usb0" ] && echo "  - RNDIS Network"
        [ -d "$GADGET_DIR/functions/hid.usb0" ] && echo "  - HID Keyboard"
        [ -d "$GADGET_DIR/functions/mass_storage.usb0" ] && echo "  - Mass Storage"
        
        echo ""
        echo "Network Interface:"
        if ip link show usb0 &>/dev/null; then
            ip addr show usb0
        else
            echo "  usb0: not present"
        fi
    else
        echo "Gadget: Not configured"
    fi
}

# Main
case "${1:-start}" in
    start)
        create_storage_image
        setup_gadget
        ;;
    stop)
        remove_gadget
        ;;
    restart)
        remove_gadget
        sleep 1
        create_storage_image
        setup_gadget
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
