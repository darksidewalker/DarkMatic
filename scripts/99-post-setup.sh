#!/usr/bin/bash

############################################################################################################
#                                        SCRIPT                                                            #
############################################################################################################

source "$SCRIPT_DIR/functions.sh"

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

checksignatureerrors=$(grep -q -E "(error: some-package: signature from).*(is unknown trust)" "$BASE_DIR/01-setup.log")
if [[ $checksignatureerrors ]]; then
    echo -ne "Keyring is outdated or missing signatures ..."
    echo -ne "Keyring Updating keyring - this may take a while ..."
    sudo pacman-key --refresh-keys
    
    echo -ne "
    -------------------------------------------------------------------------
    Installing AUR PKGs again ...                             
    -------------------------------------------------------------------------
    "

   do_installaurpkgs pkgs-aur.txt
fi

echo -ne "
-------------------------------------------------------------------------
CleanUp                                          
-------------------------------------------------------------------------
"

rm -rf "$HOME/nvidia-all"
rm -rf "$HOME/linux-tkg"
flatpak uninstall --unused -y
