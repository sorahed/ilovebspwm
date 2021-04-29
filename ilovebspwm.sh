#!/usr/bin/env bash

[[ $(echo $LANG | cut -c 1-2) == "pt" ]] && _MSG="Não use 'sudo' e nem 'root'" || _MSG="Do not use 'sudo' or 'root'"
[[ $(id -u) -eq 0 ]] && echo ${_MSG} && exit 1

CURRENT_DIR=$(pwd)

shopt -s extglob

usage() {
    cat << EOF
usage: ${0##*/} [flags]
    Options:
    --install,      -i Install ilovebspwm
    --uninstall,    -u Uninstall ilovebspwm
    --help,         -h Show this is message
    --update,       -U Update your system(Recommended, before installation;)
* Sora - The God's       <https://twitter.com/ant1c0n> 
EOF
}

if [[ -z $1 || $1 = @(-h|--help) ]]; then
    usage 
    exit $(( $# ? 0 : 1 ))
fi

version="${0##*/} version 1.0"

_updates(){
    sudo apt update
    sudo apt full-upgrade -y
    sudo apt clean
    sudo apt autoremove -y
    sudo apt autoclean
    exit 0
}

_dependencies(){
    sudo apt install -y build-essential \
      cmake cmake-data pkg-config libcairo2-dev \
      libxcb1-dev libxcb-util0-dev libxcb-randr0-dev \
      libxcb-composite0-dev python3-xcbgen xcb-proto \
      libxcb-image0-dev libxcb-ewmh-dev \
      libxcb-icccm4-dev \
      libcurl4-openssl-dev libjsoncpp-dev libpulse-dev libmpdclient-dev libasound2-dev libxcb-cursor-dev libxcb-xrm-dev libxcb-xkb-dev libnl-genl-3-dev
}

_apt_packages(){
    sudo apt install -y bspwm sxhkd subversion rofi feh numlockx compton dunst neofetch imagemagick webp unifont gnome-terminal git
}

_build_polybar(){
    cd /tmp
    git clone --recursive https://github.com/polybar/polybar
    cd polybar
    sed -i 's/read /#read /g' build.sh
    sudo ./build.sh
}

_git_packs(){
  [[ ! -d "${HOME}/.local/share/fonts" ]] && mkdir -p "${HOME}/.local/share/fonts"
  svn export https://github.com/terroo/fonts/trunk/fonts
  mv fonts ${HOME}/.local/share/fonts/
  fc-cache -fv
}

_cfg_all(){
  cd $CURRENT_DIR
  mv bspwm/ ${HOME}/.config/ 
  mv sxhkd/ ${HOME}/.config/ 
  mv dunst/ ${HOME}/.config/ 
  mv polybar/ ${HOME}/.config/ 
  mv rofi/ ${HOME}/.config/
  mv wallpaper.jpg ${HOME}/.wallpaper.jpg
  feh --bg-scale ${HOME}/.wallpaper.jpg
}
                                                                                    

_finish(){
    clear
    echo "Installation completed."
    _start
}

_install(){
  _apt_packs
  _deps_build
  [[ ! $(which cmake 2>/dev/null) ]] && _deps_build
  _git_svn_packs
  [[ $(grep -i 'debian' /etc/issue) ]] && sudo apt -y install polybar || _build_polybar
  _cfg_all
  _ok
  exit 0
}

_uninstall(){
  sudo apt remove -y bspwm rofi
  sudo rm $(which polybar)
  rm -rf ${HOME}/.fehbg ${HOME}/.wallpaper.jpg
  rm -rf ${HOME}/.local/share/fonts/fonts
  rm -rf ${HOME}/.config/{bspwm,sxhkd,polybar,rofi,dunst}
  exit 0
}

while [[ "$1" ]]; do
  case "$1" in
    "--install"|"-i") _install ;;
    "--uninstall"|"-u") _uninstall ;;
    "--help"|"-h") usage ;;
    "--update"|"-U") _updates && exit 0 ;;
    *) echo 'Invalid option.' && usage && exit 1 ;;
  esac
  shift
done
