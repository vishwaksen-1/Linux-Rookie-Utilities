# Scripts in the `scripts` Directory

This directory contains utility scripts designed to simplify common tasks for Linux users, especially beginners. Below is a list of the scripts and their functionality:

---

## 1. `archClean.sh`
A script to help Arch Linux users clean and maintain their system. It includes:
- Cleaning the package cache.
- Removing unused (orphaned) packages.
- Cleaning the home cache directory.
- Finding and optionally removing duplicate files, empty files, and directories.
- Finding large files in the system.

This script is beginner-friendly and encourages learning by leaving room for customization.

---

## 2. `bluetooth.sh`
A simple utility to toggle Bluetooth on or off using `bluetoothctl`. 
- **Note**: This script might not work for all users. You may need to modify the condition `| grep -i "PowerState: off";` based on the output of `bluetoothctl show` when run alone.

---
## 3. `lester.sh`
A versatile script to recursively fetch and list subdirectories from a given URL using `wget`. It includes customizable options for advanced usage.

**Features**:
- Fetches and lists all subdirectories from a URL.
- Supports custom cookies, user agents, and HTTP headers.
- Allows setting timeouts, retries, and verbose output.
- Saves output to a specified file if needed.
- Asks whether to keep or delete the downloaded folder after execution.

This script is ideal for users who need to explore web directories efficiently while learning about `wget` and HTTP options.

---

Feel free to explore, modify, and extend these scripts to suit your needs. For more details on each script, check the individual documentation in the `docs/` directory (if available).