#!/bin/bash

# ==============================================================================
# Winimage CLI - A macOS utility to clone and restore Boot Camp/NTFS partitions
# ==============================================================================
# AUTHOR: Soner Atalay (Generated)
# VERSION: 1.0.0
# LICENSE: MIT
# ==============================================================================

# Text formatting
bold=$(tput bold)
green=$(tput setaf 2)
red=$(tput setaf 1)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

echo "${blue}${bold}=====================================${reset}"
echo "${blue}${bold}            WINIMAGE CLI             ${reset}"
echo "${blue}${bold}=====================================${reset}"
echo "A simple, robust block-level clone tool for macOS."
echo ""

# Privilege check
if [ "$EUID" -ne 0 ]; then
    echo "${red}Error: Winimage CLI needs administrator privileges.${reset}"
    echo "Please run this script with sudo: ${bold}sudo $0${reset}"
    exit 1
fi

# Function to list drives
list_drives() {
    echo "${yellow}Scanning connected drives & partitions...${reset}"
    echo "------------------------------------------------------------"
    diskutil list | grep -E "GUID_partition_scheme|Apple_APFS_Container|Microsoft|Windows|NTFS|ExFAT|DOS_FAT_32|disk[0-9]+s[0-9]+"
    echo "------------------------------------------------------------"
}

# Function: Backup
backup_flow() {
    echo "${bold}--- BACKUP MODE ---${reset}"
    list_drives
    
    echo ""
    read -p "Enter the ${bold}SOURCE${reset} partition identifier (e.g., disk0s3, disk1s2): " source_drive
    
    if ! diskutil info "$source_drive" >/dev/null 2>&1; then
        echo "${red}Invalid drive identifier! Exiting.${reset}"
        exit 1
    fi
    
    read -p "Enter the ${bold}DESTINATION${reset} path and filename (e.g., /Volumes/External/WindowsBackup.img): " dest_file
    
    echo "${yellow}Preparing to clone /dev/${source_drive} to ${dest_file}...${reset}"
    read -p "Are you sure you want to proceed? (y/n): " confirm
    if [[ $confirm != [yY]* ]]; then
        echo "Backup canceled."
        exit 0
    fi
    
    echo "Unmounting /dev/${source_drive} for safe reading..."
    diskutil unmount "/dev/${source_drive}"
    
    # Use rdisk for faster speed
    rdisk_source=$(echo "$source_drive" | sed 's/disk/rdisk/')
    
    echo "${green}Starting backup (this will take a while). Press Ctrl+T during the process to see progress...${reset}"
    
    # Run dd command
    # bs=1m is often optimal for macOS
    dd if="/dev/${rdisk_source}" of="${dest_file}" bs=1m status=progress
    
    if [ $? -eq 0 ]; then
        echo "${green}${bold}Backup completed successfully!${reset}"
    else
        echo "${red}An error occurred during backup.${reset}"
    fi
}

# Function: Restore
restore_flow() {
    echo "${red}${bold}--- RESTORE MODE (DANGER) ---${reset}"
    echo "This mode will OVERWRITE all data on the target partition."
    
    read -p "Enter the ${bold}SOURCE${reset} image file path (e.g., /Volumes/External/WindowsBackup.img): " source_img
    
    if [ ! -f "$source_img" ]; then
        echo "${red}Image file not found at $source_img! Exiting.${reset}"
        exit 1
    fi
    
    echo ""
    list_drives
    echo ""
    
    read -p "Enter the ${bold}DESTINATION${reset} partition identifier to overwrite (e.g., disk0s3, disk1s2): " target_drive
    
    if ! diskutil info "$target_drive" >/dev/null 2>&1; then
        echo "${red}Invalid drive identifier! Exiting.${reset}"
        exit 1
    fi
    
    echo "${red}${bold}WARNING: YOU ARE ABOUT TO COMPLETELY ERASE /dev/${target_drive}${reset}"
    read -p "Are you ABSOLUTELY sure? Type 'YES' to confirm: " confirm
    
    if [ "$confirm" != "YES" ]; then
        echo "Restore canceled."
        exit 0
    fi
    
    echo "Formatting target partition as ExFAT to prepare..."
    diskutil eraseVolume ExFAT "WINIMAGE_RESTORE" "/dev/${target_drive}"
    
    if [ $? -ne 0 ]; then
        echo "${red}Formatting failed. Exiting.${reset}"
        exit 1
    fi
    
    echo "Unmounting target for raw writing..."
    diskutil unmount "/dev/${target_drive}"
    
    rdisk_target=$(echo "$target_drive" | sed 's/disk/rdisk/')
    
    echo "${green}Starting restore from ${source_img} to /dev/${rdisk_target}.${reset}"
    echo "Press Ctrl+T during the process to see progress..."
    
    dd if="${source_img}" of="/dev/${rdisk_target}" bs=1m status=progress
    
    if [ $? -eq 0 ]; then
        echo "${green}${bold}Image restored successfully!${reset}"
        
        echo "${yellow}Attempting to apply basic boot fixes (bless)...${reset}"
        bless --device "/dev/${target_drive}" --setBoot --legacy
        
        echo "${green}Restore process finished. You can restart your Mac and hold Option to check if Windows boots.${reset}"
    else
        echo "${red}An error occurred during restore.${reset}"
    fi
}

# Main menu
echo "Please select an operation:"
echo "  1) Backup (Clone a partition to an image file)"
echo "  2) Restore (Clone an image file to a partition)"
echo "  3) Exit"
echo ""
read -p "Choice (1/2/3): " choice

case $choice in
    1) backup_flow ;;
    2) restore_flow ;;
    3) exit 0 ;;
    *) echo "${red}Invalid choice.${reset}" ; exit 1 ;;
esac
