#!/bin/sh

set -e
set -u

KNOWN_TARGETS="ubuntu"

_guess_target()
{
    if [ ! -e /etc/lsb-release ]; then
        echo "unknown"
        exit 1
    fi

    . /etc/lsb-release

    case ${DISTRIB_ID} in
    "Ubuntu"|"elementary OS")
        echo "ubuntu"
        exit
        ;;
    esac

    echo "unknown"
    exit 1
}

case $# in
0)
    if ! TARGET=`_guess_target`; then
        echo "Do not know the underlying OS to work with"
        echo "Can be specified as a command-line argument."
        exit 1
    fi
    ;;
*)
    while :; do
        for known_target in ${KNOWN_TARGETS}; do
            if [ "${known_target}" = "$1" ]; then
                TARGET=$1
                break 2
            fi
        done
        echo "Unknown target $1 not in known targets: ${KNOWN_TARGETS}"
        exit 1
    done
esac

COMMON_PACKAGES_ubuntu="git curl zsh"
PACKAGES_ubuntu="${COMMON_PACKAGES_ubuntu} vim-gtk"
PACKAGES_ubuntu_server="${COMMON_PACKAGES_ubuntu} vim"

_ubuntu_check_install_packages()
{
    install=0
    for package in ${PACKAGES_ubuntu}; do
        if ! dpkg -s ${package} > /dev/null 2> /dev/null; then
            printf "Could not find package: ${package}\n"
            install=1
        fi
    done

    case ${install} in
    1)
        printf "Installing missing packages...\n\n"
        sudo apt-get install ${PACKAGES_ubuntu}
        ;;
    esac
}

_ubuntu_check_install_packages

if [ ! -e ~/.oh-my-zsh ]; then
    printf "Installing oh-my-zsh...\n\n"
    git clone https://github.com/nxsy/oh-my-zsh.git ~/.oh-my-zsh
    if [ -e ~/.zshrc ]; then
        mv ~/.zshrc ~/.zshrc_backup_`date +%s`
    fi
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
fi

if [ ! -e ~/.spf13-vim-3 ]; then
    printf "Installing spf13-vim-3\n\n"
    git clone https://github.com/nxsy/spf13-vim.git ~/.spf13-vim-3
    ( cd ~/.spf13-vim-3 && env VUNDLE_URI=https://github.com/nxsy/Vundle.vim.git sh bootstrap.sh )
fi

printf "Apparent success!\n\nGOOD LUCK!\n\n"
