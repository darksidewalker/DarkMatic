#!/usr/bin/bash

echo -ne "
-------------------------------------------------------------------------
Increasing file watcher count                    
-------------------------------------------------------------------------
"

# This prevents a "too many files" error in Visual Studio Code
echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system

echo -ne "
-------------------------------------------------------------------------
Increasing max map count                         
-------------------------------------------------------------------------
"

# This is for games with many open files
echo vm.max_map_count=1048576 | sudo tee /usr/lib/sysctl.d/99-vm-max_map_count.conf && sudo sysctl --system

echo -ne "
-------------------------------------------------------------------------
Winetricks update                                
-------------------------------------------------------------------------
"

# Update winetricks to latest
cd "$HOME" || { echo "Failure"; exit 1; }
sudo winetricks --self-update

echo -ne "
-------------------------------------------------------------------------
Checking Keyring                                       
-------------------------------------------------------------------------
"

if [ "$(grep -q -E "(error: some-package: signature from).*(is unknown trust)" $SCRIPT_DIR/01-setup.log)" ]; then
    echo -ne "'\033[0;31m''\033[40m'Keyring is outdated or missing signatures ..."
    echo -ne "Keyring Updating keyring - this may take a while ..."
    sudo pacman-key --refresh-keys
    
    echo -ne "
    -------------------------------------------------------------------------
    Installing AUR PKGs again ...                             
    -------------------------------------------------------------------------
    "
    
   
    PKGS="($(cat "$CONFIGS_DIR"/pkgs-aur.txt))"
    for PKG in "${PKGS[@]}"; do
    PKGCHECK=pamac list | grep -q "$PKG"
    if ! PKGCHECK; then
    pamac build --no-confirm "$PKG"
    fi
    done
fi

echo -ne "
-------------------------------------------------------------------------
CleanUp                                          
-------------------------------------------------------------------------
"

rm -rf "$HOME/nvidia-all"
rm -rf "$HOME/linux-tkg"
flatpak uninstall --unused -y
