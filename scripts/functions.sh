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
PKGS="($(cat "$CONFIGS_DIR/$1"))"

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done
}

# Installing aur pkgs from textfile input
do_installaurpkgs () {
PKGS="($(cat "$CONFIGS_DIR/$1"))"

for PKG in "${PKGS[@]}"; do
    checkaurpkgs=$(pamac list | grep "$PKG")
    if [[ ! $checkaurpkgs ]]; then
    pamac build --no-confirm "$PKG"
    fi
done
}

# Installing flatpak pkgs from textfile input
do_installflatpakpkgs () {
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

PKGS="($(cat "$CONFIGS_DIR/$1"))"

for PKG in "${PKGS[@]}"; do
flatpak install --noninteractive flathub --system "$PKG"
done
}