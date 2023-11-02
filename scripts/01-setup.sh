#!/usr/bin/bash

############################################################################################################
#                                        SCRIPT                                                            #
############################################################################################################

source "$SCRIPT_DIR/functions.sh"


# Update database
sudo pacman -Sy

echo -ne "
-------------------------------------------------------------------------
Setting up mirrors for optimal download          
-------------------------------------------------------------------------
"
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo pacman-mirrors --geoip

nc=$(grep -c ^processor /proc/cpuinfo)
echo "-------------------------------------------------"
echo "You have $nc cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for $nc cores."
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g' /etc/makepkg.conf
echo "Changing the compression settings for $nc cores."
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g' /etc/makepkg.conf

#Add parallel downloading
echo -ne "
-------------------------------------------------------------------------
Add parallel downloading for pacman              
-------------------------------------------------------------------------
"

sudo sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable AUR in pamac
echo -ne "
-------------------------------------------------------------------------
Enable AUR                                       
-------------------------------------------------------------------------
"

sudo sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf
sudo sed -Ei '/CheckAURUpdates/s/^#//' /etc/pamac.conf

#Enable Flatpak in pamac
echo -ne "
-------------------------------------------------------------------------
Enable Flatpak                                   
-------------------------------------------------------------------------
"

flatpackcheck=$(grep -c "EnableFlatpak" /etc/pamac.conf)
if [ "$flatpackcheck" -gt 0 ]; then
sudo sed -Ei '/EnableFlatpak/s/^#//' /etc/pamac.conf
sudo sed -Ei '/CheckFlatpakUpdates/s/^#//' /etc/pamac.conf
elif [ "$flatpackcheck" -eq 0 ]; then
echo -ne 'EnableFlatpak\n\n' | sudo tee -a /etc/pamac.conf
echo -ne '#EnableSnap\n\n' | sudo tee -a /etc/pamac.conf
echo -ne 'CheckFlatpakUpdates\n' | sudo tee -a /etc/pamac.conf
fi


echo -ne "
-------------------------------------------------------------------------
Installing Base System PKGs                      
-------------------------------------------------------------------------
"

do_installpacmanpkgs pkgs-base.txt

echo -ne "
-------------------------------------------------------------------------
Installing User PKGs                             
-------------------------------------------------------------------------
"
do_installpacmanpkgs pkgs-user.txt

echo -ne "
-------------------------------------------------------------------------
Installing Game PKGs                             
-------------------------------------------------------------------------
"

do_installpacmanpkgs pkgs-game.txt

# Custom Kernel with linux-tkg
ask_customkernel
if [[ $CUSTOMKERNEL == true ]]; then
    echo -ne "
    -------------------------------------------------------------------------
    Installing Custom Kernel                         
    -------------------------------------------------------------------------
    "
    
    # Installing custom Kernel with linux-tkg
    cd "$HOME" || { echo "Failure"; exit 1; }
    git clone https://github.com/Frogging-Family/linux-tkg.git
    cp -f "$LINUXTKG_DIR/customization.cfg" "$HOME/linux-tkg/customization.cfg"
    cd "linux-tkg" || { echo "Failure"; exit 1; }
    makepkg -si
fi

# Detecting and Installing VGA drivers or custom nvidia-all
echo -ne "
-------------------------------------------------------------------------
Installing VGA Drivers                           
-------------------------------------------------------------------------
"
# Detect NVIDIA VGA
if lspci | grep -E "(VGA compatible controller:).*?NVIDIA"; then
    ask_customnvidiadriver
# Ask for cutom nvidia-all install
elif [[ $CUSTOMNVIDIADRIVER == true ]]; then
    echo -e "\nInstalling custom Nvidia-Drivers\n"
    do_nvidiahook
    cd "$HOME" || { echo "Failure"; exit 1; }
    if lspci | grep -E "(VGA compatible controller:).*?NVIDIA"; then 
        git clone https://github.com/Frogging-Family/nvidia-all.git
        cp -f "$NVIDIAALL_DIR/customization.cfg" "$HOME/nvidia-all/customization.cfg"
        cd "nvidia-all" || { echo "Failure"; exit 1; }
        makepkg -si
    fi
# Install standard Nvidia distro driver
elif [[ $CUSTOMNVIDIADRIVER == false ]]; then
    echo -e "\nInstalling Nvidia-Drivers\n"
    do_nvidiahook
    sudo mhwd -i pci video-nvidia
# Detect AMD VGA and install driver
elif lspci | grep -E "(VGA compatible controller:).*?AMD"; then
    echo -e "\nInstalling AMD-Drivers\n"
    sudo pacman -S xf86-video-amdgpu --noconfirm --needed
# Detect Intel VGA and install driver
elif lspci | grep -E "Integrated Graphics Controller"; then
    echo -e "\nInstalling Intel-Drivers\n"
    sudo pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -ne "
-------------------------------------------------------------------------
Installing AUR PKGs                              
-------------------------------------------------------------------------
"
do_installaurpkgs pkgs-aur.txt

echo -ne "
-------------------------------------------------------------------------
Installing FLATPAK PKGs                              
-------------------------------------------------------------------------
"
do_installflatpakpkgs pkgs-flatpak.txt
