#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "================================"
echo "Volume Management Script"
echo "================================"
echo ""

# Step 1: Show all block devices
echo "Available volumes/disks:"
echo "------------------------"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
echo ""

# Count unmounted volumes
unmounted_count=$(lsblk -rno NAME,TYPE,MOUNTPOINT | grep "disk" | grep -v "/" | wc -l)
echo "Number of unmounted volumes: $unmounted_count"
echo ""

# Step 2: Ask for volume name
read -p "Enter the volume name to format (e.g., sdb, nvme1n1): " volume_name

# Validate volume exists
if [ ! -b "/dev/$volume_name" ]; then
    echo "Error: /dev/$volume_name does not exist!"
    exit 1
fi

# Warning before formatting
echo ""
echo "WARNING: This will DELETE ALL DATA on /dev/$volume_name"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Step 3: Format the volume with xfs
echo ""
echo "Formatting /dev/$volume_name with xfs filesystem..."
mkfs.xfs -f /dev/$volume_name

if [ $? -ne 0 ]; then
    echo "Error: Failed to format the volume!"
    exit 1
fi

echo "Volume formatted successfully!"
echo ""

# Step 4: Ask for mount path
read -p "Enter the mount path (e.g., /mnt/data): " mount_path

# Create mount directory if it doesn't exist
if [ ! -d "$mount_path" ]; then
    echo "Creating directory $mount_path..."
    mkdir -p "$mount_path"
fi

# Step 5: Mount the volume
echo "Mounting /dev/$volume_name to $mount_path..."
mount /dev/$volume_name "$mount_path"

if [ $? -ne 0 ]; then
    echo "Error: Failed to mount the volume!"
    exit 1
fi

echo "Volume mounted successfully!"
echo ""

# Step 6: Get UUID for permanent mounting
uuid=$(blkid -s UUID -o value /dev/$volume_name)

if [ -z "$uuid" ]; then
    echo "Error: Could not get UUID for the volume!"
    exit 1
fi

echo "Volume UUID: $uuid"
echo ""

# Step 7: Update /etc/fstab for permanent mounting
echo "Adding entry to /etc/fstab for permanent mounting..."

# Backup fstab
backup_file="/etc/fstab.backup.$(date +%Y%m%d_%H%M%S)"
cp /etc/fstab "$backup_file"
echo "Backup of fstab created at: $backup_file"

# Add comment and entry to fstab
{
    echo ""
    echo "# Mount path: $mount_path"
    echo "UUID=$uuid $mount_path xfs defaults 0 2"
} >> /etc/fstab

echo "Entry added to /etc/fstab successfully!"
echo ""

# Verify fstab entry
echo "Verifying /etc/fstab entry..."
tail -n 3 /etc/fstab
echo ""

echo "================================"
echo "Setup Complete!"
echo "================================"
echo "Volume: /dev/$volume_name"
echo "Mount Point: $mount_path"
echo "UUID: $uuid"
echo "Filesystem: xfs"
echo ""
echo "The volume will automatically mount on system reboot."
echo ""

# Show current mount
df -h "$mount_path"

exit 0