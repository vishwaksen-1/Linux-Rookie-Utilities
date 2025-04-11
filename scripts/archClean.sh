#!/bin/bash

# Function to clean package cache
clean_pkg_cache() {
    echo "Do you want to list the package cache before cleaning? (y/N)"
    read -r list_choice
    if [[ $list_choice == "y" || $list_choice == "Y" ]]; then
        echo "Listing package cache..."
        ls /var/cache/pacman/pkg/ | less
    fi

    echo "Cleaning package cache..."
    sudo pacman -Sc
    echo "Do you want to remove all cached files? (y/N)"
    read -r choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        sudo pacman -Scc
    fi
    echo "Package cache cleaned."
}

# Function to remove unused packages
remove_unused_packages() {
    echo "Removing unused packages..."
    unused=$(sudo pacman -Qtdq)
    if [[ -z $unused ]]; then
        echo "No unused packages found."
    else
        sudo pacman -Rns $unused
        echo "Unused packages removed."
    fi
}

# Function to manage paccache.timer
manage_paccache_timer() {
    echo "🎉 Congratulations! You've found the secret option! 🎉"
    echo "This utility allows you to automate cleaning the package cache using a systemd timer."
    echo "Would you like to enable or disable the paccache.timer? (enable/disable)"
    read -r action

    if [[ $action == "enable" ]]; then
        echo "Enabling paccache.timer..."
        sudo systemctl enable --now paccache.timer
        echo "paccache.timer has been enabled and is now active."
        echo "By default, it will run every three days and keep the last three versions of packages."
    elif [[ $action == "disable" ]]; then
        echo "Disabling paccache.timer..."
        sudo systemctl disable --now paccache.timer
        echo "paccache.timer has been disabled."
    else
        echo "Invalid option. Please enter 'enable' or 'disable'."
    fi
}

# Function to clean home cache
clean_home_cache() {
    echo "Calculating current cache size..."
    before_size=$(du -sh ~/.cache 2>/dev/null | awk '{print $1}')
    echo "Current cache size: ${before_size:-0}"

    echo "Cleaning home cache..."
    rm -rf ~/.cache/*
    
    echo "Recalculating cache size..."
    after_size=$(du -sh ~/.cache 2>/dev/null | awk '{print $1}')
    echo "Cache size after cleanup: ${after_size:-0}"

    if [[ $before_size != $after_size ]]; then
        echo "Space saved: $before_size -> $after_size"
    else
        echo "No space was saved (cache was already empty)."
    fi
}

# Function to find and remove duplicates, empty files, and directories
find_and_remove() {
    echo "Finding and removing duplicates, empty files, and directories..."

    # Check if rmlint is installed
    if ! command -v rmlint &> /dev/null; then
        echo "Error: 'rmlint' is not installed on your system."
        echo "You can install it using one of the following commands:"
        echo "  sudo pacman -S rmlint       # For Arch-based systems with pacman"
        echo "  yay -S rmlint              # If you use yay as an AUR helper"
        echo "  pamac install rmlint       # If you use pamac"
        echo "Please install 'rmlint' and re-run the script."

        exit 1
    fi

    # Run rmlint to find duplicates, empty files, and directories
    rmlint --types=duplicates,emptydirs,emptyfiles --progress
    echo "Do you want to remove the found items? (y/n)"
    read -r choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        rmlint --types=duplicates,emptydirs,emptyfiles --remove
        echo "Items removed."
    else
        echo "Items not removed."
    fi

}

# Function to find large files
find_large_files() {
    echo "Finding large files can take some time."
    echo "Are you sure you want to proceed? (y/N)"
    read -r first_choice
    if [[ $first_choice != "y" && $first_choice != "Y" ]]; then
        echo "Smart choice. Exiting this option."
        return
    fi

    echo "Alright, you seem determined. Let me ask again: Are you *really* sure? (y/N)"
    read -r second_choice
    if [[ $second_choice != "y" && $second_choice != "Y" ]]; then
        echo "Good call. Better safe than sorry. Exiting this option."
        return
    fi

    echo "Okay, don't say I didn't warn you. Neither I (the dev) nor God is responsible for what happens next. Proceeding..."
    find ~ -type f -exec du -h {} + | sort -rh | head -n 20
}

# Main menu
while true; do
    echo "System Cleanup Script"
    echo "1. Clean package cache"
    echo "2. Remove unused packages"
    echo "3. Clean home cache"
    echo "4. Find and remove duplicates, empty files, and directories"
    echo -e "\e[31m5. Find Large Files *\e[0m"  # Display in red with a star
    echo "6. Exit"
    echo "Enter your choice: "
    read -r choice
    case $choice in
        1) clean_pkg_cache ;;
        2) remove_unused_packages ;;
        3) clean_home_cache ;;
        4) find_and_remove ;;
        5) 
            echo -e "\e[33mNote: Finding large files can take some time.\e[0m"
            echo -e "\e[33mDeleting certain large files might put your system at risk.\e[0m"
            echo -e "\e[33mProceed cautiously!\e[0m"
            find_large_files ;;
        6) echo "Exiting..."; break ;;
        42) manage_paccache_timer ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
    echo -e "\n----------------------------------------\n"
done