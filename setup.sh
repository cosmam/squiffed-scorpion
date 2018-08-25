#!/bin/bash

EMAIL="CHANGEME@EMAIL.COM"

INSTALLED_CHROMIUM=false

APT_INSTALLS=(gnome-tweaks gparted git chromium-browser geany meld xclip)

function is_installed {
    if command -v $1 >/dev/null 2>&1; then
        return 0;
    else
        return 1;
    fi
}

function if_install {
    if is_installed $1 = true; then
        echo "$1 is already installed";
    else
        sudo apt-get -y install $1
        if $1 = chromium-browser; then
            INSTALLED_CHROMIUM=true
        fi
    fi
}

function do_apt_installs {
    for i in ${APT_INSTALLS[@]}; do
        if_install ${i}
    done
}

function open_link {
    chromium-browser $1 >/dev/null 2>&1 &
}

function install_chrome {
    if ! is_installed google-chrome; then
        open_link https://www.google.com/intl/en-US/chrome/browser/
        echo "Press any key once downloaded..."
        read -n1 -r -p "Press any key to continue..." key
        yes | sudo dpkg -i ~/Downloads/google-chrome*.deb
        sudo apt-get install -f
    else
        echo "google-chrome is already installed"
    fi
}

function install_discord {
    if ! is_installed discord; then
        open_link https://discordapp.com/download
        echo "Press any key once downloaded..."
        read -n1 -r -p "Press any key to continue..." key
        yes | sudo dpkg -i ~/Downloads/discord*.deb
        sudo apt-get install -f
    else
        echo "discord is already installed"
    fi
}

function adjust_bashrc {
    if grep '##BEGIN ADDED SECTION' ~/.bashrc >/dev/null 2>&1; then
        echo "bashrc up to date"
    else
        cat bashrc.txt >> ~/.bashrc
        source ~/.bashrc
    fi
}

function generate_ssh_key {
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo | ssh-keygen -P ''
        ssh-add ~/.ssh/id_rsa
        cat ~/.ssh/id_rsa.pub | xclip -sel clip
        open_link https://bitbucket.org/account/user/cosmam/ssh-keys/ 
        echo "Public key copied to clipboard"
        read -n1 -r -p "Press any key to continue..." key
    else
        echo "Ssh key already created"
    fi
}

function setup_git {
    if git config --list | grep user >/dev/null 2>&1; then
        echo "Git credentials already set"
    else
        git config --global user.email "$EMAIL"
        git config --global user.name "cosmam"
    fi
}

do_apt_installs
install_chrome
install_discord
adjust_bashrc
generate_ssh_key
setup_git

if $INSTALLED_CHROMIUM; then
    chromium-browser &
fi
