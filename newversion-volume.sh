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

# Function to get root disk name
get_root_disk() {
    lsblk -rno NAME,TYPE,MOUNTPOINT | awk '$3=="/" {print $1}' | sed 's/[0-9]*$//'
}

# Function to get unmounted volumes (excluding root disk and its variations)
get_unmounted_volumes() {
    root_disk=$(get_root_disk)
    lsblk -rno NAME,TYPE,MOUNTPOINT | awk -v root="$root_disk" '$2=="disk" && $3=="" && $1!=root {print $1}'
}

# Main loop
while true; do
    # Step 1: Show all block devices
    echo "Available volumes/disks:"
    echo "------------------------"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
    echo ""

    # Get unmounted volumes
    unmounted_volumes=($(get_unmounted_volumes))
    unmounted_count=${#unmounted_volumes[@]}
    
    echo "Number of unmounted volumes: $unmounted_count"
    
    if [ $unmounted_count -eq 0 ]; then
        echo "No unmounted volumes found. Exiting."
        exit 0
    fi
    
    echo ""
    echo "Unmounted volumes: ${unmounted_volumes[@]}"
    echo ""

    # Step 2: Ask for volume name
    read -p "Enter the volume name to format (e.g., ${unmounted_volumes[0]}): " volume_name

    # Validate volume exists
    if [ ! -b "/dev/$volume_name" ]; then
        echo "Error: /dev/$volume_name does not exist!"
        continue
    fi

    # Check if volume is already mounted
    if mount | grep -q "/dev/$volume_name"; then
        echo "Error: /dev/$volume_name is already mounted!"
        continue
    fi

    # Warning before formatting
    echo ""
    echo "WARNING: This will DELETE ALL DATA on /dev/$volume_name"
    read -p "Are you sure you want to continue? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        echo "Skipping this volume."
        echo ""
        read -p "Do you want to format another volume? (yes/no): " continue_format
        if [ "$continue_format" != "yes" ]; then
            echo "Exiting script."
            exit 0
        fi
        continue
    fi

    # Step 3: Format the volume with xfs
    echo ""
    echo "Formatting /dev/$volume_name with xfs filesystem..."
    mkfs.xfs -f /dev/$volume_name

    if [ $? -ne 0 ]; then
        echo "Error: Failed to format the volume!"
        continue
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
        continue
    fi

    echo "Volume mounted successfully!"
    echo ""

    # Step 6: Get UUID for permanent mounting
    uuid=$(blkid -s UUID -o value /dev/$volume_name)

    if [ -z "$uuid" ]; then
        echo "Error: Could not get UUID for the volume!"
        continue
    fi

    echo "Volume UUID: $uuid"
    echo ""

    # Step 7: Update /etc/fstab for permanent mounting
    echo "Adding entry to /etc/fstab for permanent mounting..."

    # Backup fstab (only first time)
    if [ ! -f /etc/fstab.backup.original ]; then
        cp /etc/fstab /etc/fstab.backup.original
        echo "Original fstab backup created at: /etc/fstab.backup.original"
    fi

    # Add comment and entry to fstab
    {
        echo ""
        echo "# Volume: $volume_name | Mount path: $mount_path"
        echo "UUID=$uuid $mount_path xfs defaults 0 2"
    } >> /etc/fstab

    echo "Entry added to /etc/fstab successfully!"
    echo ""

    # Step 8: Test fstab configuration
    echo "Testing /etc/fstab configuration with 'mount -a'..."
    mount -a

    if [ $? -eq 0 ]; then
        echo "mount -a successful! All entries in fstab are valid."
    else
        echo "Warning: mount -a returned an error. Please check /etc/fstab"
    fi
    echo ""

    # Verify fstab entry
    echo "Last added entry in /etc/fstab:"
    echo "-----------------------------------"
    tail -n 3 /etc/fstab
    echo "-----------------------------------"
    echo ""

    echo "================================"
    echo "Volume Setup Complete!"
    echo "================================"
    echo "Volume: /dev/$volume_name"
    echo "Mount Point: $mount_path"
    echo "UUID: $uuid"
    echo "Filesystem: xfs"
    echo ""

    # Show current mount
    df -h "$mount_path"
    echo ""

    # Ask if user wants to format another volume
    read -p "Do you want to format another volume? (yes/no): " continue_format
    
    if [ "$continue_format" != "yes" ]; then
        echo ""
        echo "All done! Exiting script."
        echo "The volumes will automatically mount on system reboot."
        exit 0
    fi
    
    echo ""
done
