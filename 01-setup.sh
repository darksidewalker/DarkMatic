#!/usr/bin/env bash
############################################################################################################
#                                        FUNCTIONS                                                         #
############################################################################################################
# Find the name of the folder the scripts are in
find_scriptdirs() {
set -a
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIGS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/configs
LINUXTKG_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/linux-tkg
NVIDIAALL_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/nvidia-all
set +a
}

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
    CUSTOMNVIDIADRIVER=true
elif [[ "$response" =~ ^(no|n|N|No)$ ]]; then
    CUSTOMNVIDIADRIVER=false
else
    CUSTOMNVIDIADRIVER=false
fi
}

do_nvidiahook () {
sudo \cp $CONFIGS_DIR/nvidia.hook /etc/pacman.d/hooks/nvidia.hook
}

############################################################################################################
#                                        SCRIPT                                                            #
############################################################################################################

# Set config file
find_scriptdirs
source $CONFIGS_DIR/colors.cfg

# Set variables - Do not alter
CUSTOMKERNEL=false
CUSTOMNVIDIADRIVER=false

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Setting up mirrors for optimal download          
-------------------------------------------------------------------------
'\033[0m'"
# Update database
sudo pacman -Sy
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo pacman-mirrors --geoip

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j$nc"/g' /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g' /etc/makepkg.conf

#Add parallel downloading
echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Add parallel downloading for pacman              
-------------------------------------------------------------------------
'\033[0m'"

sudo sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable multilib
#echo -ne "'\033[0;32m''\033[40m'
#-------------------------------------------------------------------------
#Enable multilib                                  
#-------------------------------------------------------------------------
#'\033[0m'"
#
#sudo sed -Ei '/[multilib]/s/^#//' /etc/pacman.conf
#sudo sed -Ei '/SigLevel\ \=\ PackageRequired/s/^#//' /etc/pacman.conf
#sudo sed -Ei '/Include\ \=\ \/etc\/pacman\.d\/mirrorlist/s/^#//' /etc/pacman.conf

#Enable AUR in pamac
echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Enable AUR                                       
-------------------------------------------------------------------------
'\033[0m'"

sudo sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf
sudo sed -Ei '/CheckAURUpdates/s/^#//' /etc/pamac.conf

#Enable Flatpak in pamac
echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Enable Flatpak                                   
-------------------------------------------------------------------------
'\033[0m'"

if [ $(grep -q "EnableFlatpak" /etc/pamac.conf) ]; then
sudo sed -Ei '/EnableFlatpak/s/^#//' /etc/pamac.conf
sudo sed -Ei '/CheckFlatpakUpdates/s/^#//' /etc/pamac.conf
else
echo -ne 'EnableFlatpak\n\n' /dev/null | sudo tee -a /etc/pamac.conf
echo -ne '#EnableSnap\n\n' /dev/null | sudo tee -a /etc/pamac.conf
echo -ne 'CheckFlatpakUpdates\n' /dev/null | sudo tee -a /etc/pamac.conf
fi


echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Installing Base System PKGs                      
-------------------------------------------------------------------------
'\033[0m'"

PKGS=($(cat $CONFIGS_DIR/pkgs-base.txt))

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Installing User PKGs                             
-------------------------------------------------------------------------
'\033[0m'"

PKGS=($(cat $CONFIGS_DIR/pkgs-user.txt))

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Installing Game PKGs                             
-------------------------------------------------------------------------
'\033[0m'"

PKGS=($(cat $CONFIGS_DIR/pkgs-game.txt))

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

ask_customkernel
if [[ $CUSTOMKERNEL = true ]]; then
    echo -ne "'\033[0;32m''\033[40m'
    -------------------------------------------------------------------------
    Installing Custom Kernel                         
    -------------------------------------------------------------------------
    '\033[0m'"
    
    # Installing custom Kernel with linux-tkg
    cd $HOME
    git clone https://github.com/Frogging-Family/linux-tkg.git
    \cp $LINUXTKG_DIR/customization.cfg $HOME/linux-tkg/customization.cfg
    cd linux-tkg
    makepkg -si
fi

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Installing VGA Drivers                           
-------------------------------------------------------------------------
'\033[0m'"

if lspci | grep -E "(VGA compatible controller:).*?NVIDIA"; then
    ask_customnvidiadriver

elif [[ $CUSTOMNVIDIADRIVER = true ]]; then
    echo -e "\nInstalling custom Nvidia-Drivers\n"
    do_nvidiahook
    cd $HOME
    git clo    if lspci | grep -E "(VGA compatible controller:).*?NVIDIA"; thenne https://github.com/Frogging-Family/nvidia-all.git
    \cp $NVIDIAALL_DIR/customization.cfg $HOME/nvidia-all/customization.cfg
    cd nvidia-all
    makepkg -si

elif [[ $CUSTOMNVIDIADRIVER = false ]]; then
    echo -e "\nInstalling Nvidia-Drivers\n"
    do_nvidiahook
    sudo mhwd -i pci video-nvidia

elif lspci | grep -E "(VGA compatible controller:).*?AMD"; then
    echo -e "\nInstalling AMD-Drivers\n"
    sudo pacman -S xf86-video-amdgpu --noconfirm --needed

elif lspci | grep -E "Integrated Graphics Controller"; then
    echo -e "\nInstalling Intel-Drivers\n"
    sudo pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Installing AUR PKGs                              
-------------------------------------------------------------------------
'\033[0m'"

PKGS=($(cat $CONFIGS_DIR/pkgs-aur.txt))

for PKG in "${PKGS[@]}"; do
    if [[ ! $(pamac list | grep $PKG) ]]; then
    pamac build --no-confirm $PKG 
    fi
done

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Installing FLATPAK PKGs                              
-------------------------------------------------------------------------
'\033[0m'"

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

PKGS=($(cat $CONFIGS_DIR/pkgs-flatpak.txt))

for PKGFLAT in "${PKGSFLAT[@]}"; do
flatpak install --noninteractive flathub --system $PKGFLAT
done
