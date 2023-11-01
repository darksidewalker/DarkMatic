#!/usr/bin/env bash
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_DIR/configs/colors.cfg

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Increasing file watcher count                    
-------------------------------------------------------------------------
'\033[0m'"

# This prevents a "too many files" error in Visual Studio Code
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Increasing max map count                         
-------------------------------------------------------------------------
'\033[0m'"

# This is for games with many open files
echo vm.max_map_count=1048576 | sudo tee /usr/lib/sysctl.d/99-vm-max_map_count.conf && sudo sysctl --system

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Winetricks update                                
-------------------------------------------------------------------------
'\033[0m'"

# Update winetricks to latest
cd "$HOME" || { echo "Failure"; exit 1; }
sudo winetricks --self-update

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
Checking Keyring                                       
-------------------------------------------------------------------------
'\033[0m'"

if [ "$(grep -q -E "(error: some-package: signature from).*(is unknown trust)" $SCRIPT_DIR/01-setup.log)" ]; then
    echo -ne "'\033[0;31m''\033[40m'Keyring is outdated or missing signatures ...'\033[0m'"
    echo -ne "'\033[0;32m''\033[40m'Keyring Updating keyring - this may take a while ...'\033[0m'"
    sudo pacman-key --refresh-keys
    
    echo -ne "'\033[0;32m''\033[40m'
    -------------------------------------------------------------------------
    Installing AUR PKGs again ...                             
    -------------------------------------------------------------------------
    '\033[0m'"
    
   
    PKGS="($(cat "$CONFIGS_DIR"/pkgs-aur.txt))"
    for PKG in "${PKGS[@]}"; do
    PKGCHECK=pamac list | grep -q "$PKG"
    if ! PKGCHECK; then
    pamac build --no-confirm "$PKG"
    fi
    done
fi

echo -ne "'\033[0;32m''\033[40m'
-------------------------------------------------------------------------
CleanUp                                          
-------------------------------------------------------------------------
'\033[0m'"

rm -rf $HOME/nvidia-all
rm -rf $HOME/linux-tkg
flatpak uninstall --unused -y
