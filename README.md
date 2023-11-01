This is currently a work in progress.

# Installer Script

This README contains the steps I do to install and configure my Manjaro Arch Linux installation to turn it in a Gaming-Linux and added Docker capabilities.

---
## Create Manjaro ISO or Use Image

Download ManjaroISO from [Manjaro](https://manjaro.org/download/) and put on a USB drive with [Etcher](https://www.balena.io/etcher/), [Ventoy](https://www.ventoy.net/en/index.html), or [Rufus](https://rufus.ie/en/)

## Install Manjaro

## Boot Manjaro

From initial Prompt type the following commands:

```
sudo pacman -Sy --needed git
git clone https://github.com/darksidewalker/ManjaroMatic
cd ManjaroMatic
./manjaromatic.sh
```

### System Description
This is completely automated arch install. It includes prompts to select your desired desktop environment, window manager, AUR helper, and whether to do a full or minimal install. The KDE desktop environment on arch includes all the packages I use on a daily basis, as well as some customizations.
The original project was customozed to work with Manjaro and german locales.


## Troubleshooting

__[Arch Linux RickEllis Installation Guide](https://github.com/rickellis/Arch-Linux-Install-Guide)__

__[Arch Linux Wiki Installation Guide](https://wiki.archlinux.org/title/Installation_guide)__

The main script will generate .log files for every script that is run as part of the installation process. These log files contain the terminal output so you can review any warnings or errors that occurred during installation and aid in troubleshooting. 
### No Wifi

You can check if the WiFi is blocked by running `rfkill list`.
If it says **Soft blocked: yes**, then run `rfkill unblock wifi`

After unblocking the WiFi, you can connect to it. Go through these 5 steps:

#1: Run `iwctl`

#2: Run `device list`, and find your device name.

#3: Run `station [device name] scan`

#4: Run `station [device name] get-networks`

#5: Find your network, and run `station [device name] connect [network name]`, enter your password and run `exit`. You can test if you have internet connection by running `ping google.com`, and then Press Ctrl and C to stop the ping test.

## Reporting Issues

An issue is easier to resolve if it contains a few important pieces of information.
1. Chosen configuration from /configs/setup.conf (DONT INCLUDE PASSWORDS)
1. Errors seen in .log files
1. What commit/branch you used
1. Where you were installing (VMWare, Virtualbox, Virt-Manager, Baremetal, etc)
    1. If a VM, what was the configuration used.
## Credits

- Original packages script was a post install cleanup script called ArchMatic located here: https://github.com/rickellis/ArchMatic
- Original project from https://github.com/ChrisTitusTech/ArchTitus
- Custom Kernel setup https://github.com/Frogging-Family/linux-tkg
- Custom NVIDIA-Driver setup https://github.com/Frogging-Family/nvidia-all
