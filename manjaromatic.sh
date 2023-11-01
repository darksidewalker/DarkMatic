#!/bin/bash

# Find the name of the folder the scripts are in
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_DIR/configs/colors.cfg

ask_startup () {whiptail --title "Automated Manjaro Linux Installer" --yesno --defaultno "$(date)

The scripts are in directory named ManjaroMatic.

This script will install PGKs for:
- building
- basic daily use software
- gaming
- inkluding some optimizations

Press <OK> to start.
}

ask_startup

if [[ ! ask_startup == 0 ]]; then
    echo -e "$BYellow$On_Black Aborting - Nothing changed. $Green$On_Black"
    exit 1
fi

echo -ne "$Green$On_Black
~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~
Automated Manjaro Linux Installer
-------------------------------------------------------------------------
$Color_Off"

    ( bash $SCRIPT_DIR/01-setup.sh )|& tee 01-setup.log
    ( bash $SCRIPT_DIR/99-post-setup.sh )|& tee 99-post-setup.log
    
echo -ne "$Green$On_Black
-------------------------------------------------------------------------
Automated Manjaro Linux Installer
$BYellow$On_Black Done - Please Reboot $Green$On_Black
~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~
$Color_Off"
