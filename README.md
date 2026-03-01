# Winimage CLI 

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![macOS](https://img.shields.io/badge/macOS-10.15%2B-lightgrey.svg)
![Bash](https://img.shields.io/badge/Language-Bash-green.svg)

> A fast, interactive, and reliable terminal utility to clone and restore Boot Camp (Windows) partitions on macOS.

---

## 🌟 Why Winimage CLI?

While there are GUI apps like Winclone, sometimes you just need a straightforward, raw block-level cloning tool that doesn't rely on bloated frameworks. **Winimage CLI** is a single bash script that leverages Apple's native `diskutil` and the powerful `dd` command to create 1:1 byte-for-byte clones of your Windows partitions.

### Features
* **Interactive Menus:** No need to memorize complex `diskutil` or `dd` commands.
* **100% Native:** Zero dependencies to install. Uses built-in macOS tools.
* **Progress Tracking:** Shows real-time MB/s speeds and copied data during long operations.
* **Safety First:** Prompts for administrator privileges and explicitly warns before erasing any target drives.

## 🚀 Installation

Since it's a simple bash script, installation is instantaneous.

```bash
# 1. Download the script
curl -O https://raw.githubusercontent.com/YourUsername/winimage-cli/main/winimage.sh

# 2. Make it executable
chmod +x winimage.sh
```

## 📖 Usage

Run the script with administrator (`sudo`) privileges. It needs root access to read and write directly to the raw disk blocks (`/dev/rdisk`).

```bash
sudo ./winimage.sh
```

### 1. Backup Mode
1. The script will list all your connected drives.
2. Enter the identifier of your Boot Camp partition (e.g., `disk0s3`).
3. Enter the destination path for your backup (e.g., `/Volumes/ExternalDrive/WindowsBackup.img`).
4. Grab a coffee! The progress will be printed to your terminal.

### 2. Restore Mode
1. The script will ask for the exact path to your previously created `.img` or `.dmg` file.
2. Select your destination drive (e.g., `disk1s2`). 
   > **⚠️ DANGER:** All existing data on the destination drive will be permanently erased.
3. The script will format the target as ExFAT and inject the blocks from your backup image.
4. Finally, it attempts to apply a basic `bless --legacy` command to make the drive bootable.

## 🤝 Contributing
Contributions, issues, and feature requests are welcome!
Feel free to check [issues page](https://github.com/YourUsername/winimage-cli/issues).

## 📝 License
This project is [MIT](https://opensource.org/licenses/MIT) licensed.
