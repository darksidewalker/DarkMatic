#!/usr/bin/bash
############################################################################################################
#                                        FUNCTIONS                                                         #
############################################################################################################

# Aks the user if the TKG Kernel script from linux-tkg will be used to install a costum kernel
ask_customkernel() {
    echo -ne "
-------------------------------------------------------------------------
    Do you want to install a custom Kernel (tkg)?
-------------------------------------------------------------------------
"
    read -r -p "Install CUSTOM TKG Kernel? [y/N] " response
    response=${response,,}    # tolower
    if [[ "$response" =~ ^(yes|y)$ ]]; then
        CUSTOMKERNEL=true
    elif [[ "$response" =~ ^(no|n)$ ]]; then
        CUSTOMKERNEL=false
    else
        CUSTOMKERNEL=false
    fi
}

# Aks the user if the nvidia-all script will be used to install a costum nvidia driver
ask_customnvidiadriver() {
    echo -ne "
    -------------------------------------------------------------------------
        Do you want to install a custom NVIDIA driver?
    -------------------------------------------------------------------------
    "
    read -r -p "Install CUSTOM Nvidia Driver? [y/N] " response
    response=${response,,}    # tolower
    if [[ "$response" =~ ^(yes|y)$ ]]; then
        CUSTOMNVIDIADRIVER=true
    elif [[ "$response" =~ ^(no|n)$ ]]; then
        CUSTOMNVIDIADRIVER=false
    else
        CUSTOMNVIDIADRIVER=false
    fi
}

ask_startup () { 
echo -ne "
    -------------------------------------------------------------------------
        Automated Manjaro Linux Installer
    -------------------------------------------------------------------------
    The scripts are in directory named DarkMatic.

    This script will install PGKs for:
    - building
    - basic daily use software
    - gaming
    - inkluding some optimizations
    
    "
    read -r -p "Start the script? [y/N] " response
    response=${response,,}    # tolower
    if [[ "$response" =~ ^(yes|y)$ ]]; then
        STARTSCRIPT=true
    elif [[ "$response" =~ ^(no|n)$ ]]; then
        STARTSCRIPT=false
    else
        STARTSCRIPT=false
    fi
}

do_nvidiahook () {
    sudo cp "$CONFIGS_DIR/nvidia.hook" "/etc/pacman.d/hooks/nvidia.hook"
}

#Enable multilib
do_enablemultilib () {

echo -ne "
-------------------------------------------------------------------------
Enable multilib                                  
-------------------------------------------------------------------------
"

sudo sed -Ei '/[multilib]/s/^#//' /etc/pacman.conf
sudo sed -Ei '/SigLevel\ \=\ PackageRequired/s/^#//' /etc/pacman.conf
sudo sed -Ei '/Include\ \=\ \/etc\/pacman\.d\/mirrorlist/s/^#//' /etc/pacman.conf
}

# Installing pacman pkgs from textfile input
do_installpacmanpkgs () {

while IFS="" read -r PKG || [ -n "$PKG" ]
    do
    sudo pacman -S "$PKG" --noconfirm --needed
done < "$CONFIGS_DIR/$1"
}

# Installing aur pkgs from textfile input
do_installaurpkgs () {

while IFS="" read -r PKG || [ -n "$PKG" ]
    do
    checkaurpkgs=$(pamac list | grep -c "$PKG")
    if [ "$checkaurpkgs" -gt 0 ]; then
    echo "$PKG"
    elif [ "$checkaurpkgs" -eq 0 ]; then
    sudo pamac build --no-confirm "$PKG"
    fi
done < "$CONFIGS_DIR/$1"
}

# Installing flatpak pkgs from textfile input
do_installflatpakpkgs () {
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

while IFS="" read -r PKG || [ -n "$PKG" ]
do
  flatpak install --noninteractive flathub --system "$PKG"
done < "$CONFIGS_DIR/$1"
}