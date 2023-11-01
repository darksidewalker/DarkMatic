#!/usr/bin/env bash
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_DIR/configs/colors.cfg

echo -ne "$Green$On_Black
-------------------------------------------------------------------------
Increasing file watcher count                    
-------------------------------------------------------------------------
$Color_Off"

# This prevents a "too many files" error in Visual Studio Code
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system

echo -ne "$Green$On_Black
-------------------------------------------------------------------------
Increasing max map count                         
-------------------------------------------------------------------------
$Color_Off"

# This is for games with many open files
echo vm.max_map_count=1048576 | sudo tee /usr/lib/sysctl.d/99-vm-max_map_count.conf && sudo sysctl --system

echo -ne "$Green$On_Black
-------------------------------------------------------------------------
Winetricks update                                
-------------------------------------------------------------------------
$Color_Off"

# Update winetricks to latest
cd "$HOME" || { echo "Failure"; exit 1; }
sudo winetricks --self-update

echo -ne "$Green$On_Black
-------------------------------------------------------------------------
Checking Keyring                                       
-------------------------------------------------------------------------
$Color_Off"

if [ $(grep -q -E "(error: some-package: signature from).*(is unknown trust)" $SCRIPT_DIR/01-setup.log) ]; then
    echo "$Red$On_BlackKeyring is outdated or missing signatures ...$Color_Off"
    echo "$Green$On_BlackKeyring Updating keyring - this may take a while ...$Color_Off"
    sudo pacman-key --refresh-keys
    
    echo -ne "$Green$On_Black
    -------------------------------------------------------------------------
    Installing AUR PKGs again ...                             
    -------------------------------------------------------------------------
    $Color_Off"
    
   
    PKGS="($(cat "$CONFIGS_DIR"/pkgs-aur.txt))"
    for PKG in "${PKGS[@]}"; do
    PKGCHECK=pamac list | grep -q "$PKG"
    if ! PKGCHECK; then
    pamac build --no-confirm "$PKG"
    fi
    done
fi

echo -ne "$Green$On_Black
-------------------------------------------------------------------------
CleanUp                                          
-------------------------------------------------------------------------
$Color_Off"

rm -rf $HOME/nvidia-all
rm -rf $HOME/linux-tkg
flatpak uninstall --unused -y
