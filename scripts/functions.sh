#!/usr/bin/bash
############################################################################################################
#                                        VARIABLE INIT                                                     #
############################################################################################################
# Set variables - Do not alter
CUSTOMKERNEL=false
CUSTOMNVIDIADRIVER=false
############################################################################################################
#                                        FUNCTIONS                                                         #
############################################################################################################
# Find the name of the folder the scripts are in

set -a
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIGS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/configs
set +a

# Aks the user if the TKG Kernel script from linux-tkg will be used to install a costum kernel
ask_customkernel() {
    echo -ne "'\033[0;32m''\033[40m'
    -------------------------------------------------------------------------
        Do you want to install a custom Kernel (tkg)?
    -------------------------------------------------------------------------
    '\033[0m'"
    read -r -p "Install CUSTOM TKG Kernel? [y/N] " response
    response=${response,,}    # tolower
    if [[ "$response" =~ ^(yes|y|Y|Yes)$ ]]; then
        CUSTOMKERNEL=true
    elif [[ "$response" =~ ^(no|n|N|No)$ ]]; then
        CUSTOMKERNEL=false
    else
        CUSTOMKERNEL=false
    fi
}

# Aks the user if the nvidia-all script will be used to install a costum nvidia driver
ask_customnvidiadriver() {
    echo -ne "'\033[0;32m''\033[40m'
    -------------------------------------------------------------------------
        Do you want to install a custom NVIDIA driver?
    -------------------------------------------------------------------------
    '\033[0m'"
    read -r -p "Install CUSTOM Nvidia Driver? [y/N] " response
    response=${response,,}    # tolower
    if [[ "$response" =~ ^(yes|y|Y|Yes)$ ]]; then
        Export CUSTOMNVIDIADRIVER=true
    elif [[ "$response" =~ ^(no|n|N|No)$ ]]; then
        Export CUSTOMNVIDIADRIVER=false
    else
        Export CUSTOMNVIDIADRIVER=false
    fi
}

ask_startup () { whiptail --title "Automated Manjaro Linux Installer" --yesno --defaultno "$(date)

The scripts are in directory named ManjaroMatic.

This script will install PGKs for:
- building
- basic daily use software
- gaming
- inkluding some optimizations

Press <OK> to start."
}

do_nvidiahook () {
    sudo cp "$CONFIGS_DIR/nvidia.hook" "/etc/pacman.d/hooks/nvidia.hook"
}
