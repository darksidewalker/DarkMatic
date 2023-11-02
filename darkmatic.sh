#!/bin/bash

# Find the name of the workfolders
set -a
BASE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/scripts
CONFIGS_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/configs
LINUXTKG_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/linux-tkg
NVIDIAALL_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/nvidia-all
set +a

ask_startup

if [[ ! $ask_startup ]]; then
    echo -e "'\033[1;33m''\033[40m' Aborting - Nothing changed. "
    exit 1
fi

echo -ne "
~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~
Automated Manjaro Linux Installer
-------------------------------------------------------------------------
"

    ( bash "$SCRIPT_DIR/01-setup.sh" )|& tee 01-setup.log
    ( bash "$SCRIPT_DIR/99-post-setup.sh" )|& tee 99-post-setup.log
    
echo -ne "
-------------------------------------------------------------------------
Automated Manjaro Linux Installer
'\033[1;33m''\033[40m' Done - Please Reboot 
~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~+~
"
