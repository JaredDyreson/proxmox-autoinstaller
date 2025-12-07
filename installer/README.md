# Ubuntu Server Autoinstaller

A tool to create a customized Ubuntu Server ISO with automated installation capabilities using cloud-init autoinstall.

## Overview

This project modifies an Ubuntu Server ISO to include automated installation configuration. The resulting ISO will automatically install Ubuntu Server with predefined settings including user accounts, network configuration, storage layout, and SSH access.

## Prerequisites

- `xorriso` - ISO image manipulation tool
- `yq` - YAML processor
- `openssl` - For password hashing
- Ubuntu Server ISO (downloaded from ubuntu.com)

### Install Dependencies

```bash
# Arch Linux
sudo pacman -S xorriso yq openssl

# Ubuntu/Debian
sudo apt install xorriso yq openssl

# Fedora
sudo dnf install xorriso yq openssl
```

## Quick Start

1. Download an Ubuntu Server ISO
2. Edit `user-data.yaml` to customize your installation settings
3. Run the build script:

```bash
./build-installer.sh /path/to/ubuntu-server.iso
```

4. The customized ISO will be created as `installer.iso`

## Configuration

### User Account

Edit the following variables in `build-installer.sh:17-18`:

```bash
SALTED_PASSWORD=$(openssl passwd -6 "xxx")  # Change "xxx" to your desired password
USERNAME="jared"                             # Change to your desired username
```

### Network Configuration

Edit `user-data.yaml:29-40` to configure network settings:

```yaml
network:
  ethernets:
    eth0:
      addresses:
      - 192.168.1.100/24  # Static IP address
      nameservers:
        addresses: [192.168.1.1, 8.8.8.8]
      routes:
      - to: default
        via: 192.168.1.1  # Gateway
```

### Storage Layout

The default configuration creates:
- 1MB BIOS boot partition
- 512MB EFI partition (FAT32)
- 1GB boot partition (ext4)
- 8GB swap partition
- Root partition (ext4, uses remaining space)

Modify `user-data.yaml:41-104` to customize the storage layout.

### Hostname

Change the hostname in `user-data.yaml:7`:

```yaml
identity:
  hostname: ubu-server  # Change to your desired hostname
```

## How It Works

1. **Extract**: The script extracts the contents of the original Ubuntu Server ISO using `xorriso`
2. **Configure**: Generates a `user-data` file with your customized autoinstall configuration
3. **Modify Boot**: Replaces `grub.cfg` to automatically boot into autoinstall mode
4. **Repackage**: Creates a new ISO with the modified files

## Features

- Fully automated Ubuntu Server installation
- Static IP configuration
- Custom user account creation
- SSH server enabled with password authentication
- Automatic security updates
- Driver and codec installation
- Custom storage partitioning (GPT/UEFI compatible)

## Usage

### Boot the ISO

1. Write the ISO to a USB drive or mount it in a VM
2. Boot from the ISO
3. Select "Autoinstall Ubuntu Server" from the GRUB menu (auto-selected after 30 seconds)
4. The installation will proceed automatically

### Post-Installation

After installation completes and the system reboots:

```bash
ssh jared@192.168.1.100  # Use your configured username and IP
```

## File Structure

```
.
├── build-installer.sh   # Main build script
├── user-data.yaml       # Cloud-init autoinstall configuration
├── grub.cfg            # GRUB boot menu configuration
└── README.md           # This file
```

## Customization

The `user-data.yaml` file follows the Ubuntu autoinstall format. You can customize:

- Keyboard layout
- Language/locale settings
- Additional packages to install
- Post-installation commands
- LVM/RAID configurations
- Multiple network interfaces

Refer to the [Ubuntu Autoinstall Documentation](https://ubuntu.com/server/docs/install/autoinstall) for advanced configuration options.

## Security Notes

- The default password hash in `user-data.yaml:8` should be changed before building
- The build script generates a new password hash, but ensure you use a strong password
- SSH password authentication is enabled by default - consider switching to key-based auth post-installation
- Review network configuration to ensure it matches your environment

## Troubleshooting

### ISO Build Fails

- Ensure `xorriso` is installed and accessible
- Verify the input ISO path is correct
- Check that you have write permissions in the current directory

### Installation Fails

- Verify network configuration matches your environment
- Check that the target machine meets Ubuntu Server requirements
- Review installation logs at `/var/log/installer/` after boot

### Boot Issues

- Ensure UEFI/Legacy boot mode matches your system
- Verify the ISO was written correctly to the boot media
- Try selecting "Try or Install Ubuntu Server" for manual installation
