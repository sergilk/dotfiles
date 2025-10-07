#!/bin/bash

exec > >(tee "$HOME/inst_log.txt") 2>&1
set -e

dotfiles_dir="$HOME/dotfiles"
core_packages=("base-devel" "mesa" "libgnome-keyring" "gnome-keyring" "linux-headers"
"libsecret" "fuse2" "python-pyfuse3" "python-docutils" "jq" "wget" "qt5ct" "python-pip"
"python-dbus" "polkit" "dbus" "xdg-utils" "noto-fonts" "noto-fonts-emoji" "noto-fonts-extra"
"noto-fonts-cjk" "ttf-jetbrains-mono" "ttf-jetbrains-mono-nerd" "ttf-nerd-fonts-symbols"
"ttf-nerd-fonts-symbols-mono" "pipewire" "pipewire-alsa" "pipewire-pulse" "pipewire-jack")
i3_packages=("xorg i3-wm i3lock ly")
user_pacman=("feh" "dmenu" "chromium" "mpv" "j4-dmenu-desktop" "discord"
"polybar" "dunst" "xdotool" "libnotify" "copyq" "tmux" "neovim" "alacritty"
"wipe" "trash-cli" "yt-dlp" "playerctl" "ffmpeg" "pavucontrol" "picom" "thunar"
"thunar-archive-plugin" "file-roller" "thunar-media-tags-plugin" "thunar-volman"
"tumbler" "ffmpegthumbnailer" "xfce4-panel" "gvfs" "udisks2" "polkit-gnome" "glib2"
"desktop-file-utils" "webp-pixbuf-loader" "libwebp" "gdk-pixbuf2")
user_aur=("zen-browser-bin" "visual-studio-code-bin" "flameshot-git" "snapd")

# logger colors
INFO='\e[34m'
SUCCESS='\e[32m'
WARN='\e[33m'
ERROR='\e[31m'
RESET='\e[0m'

log() {
    local type="$1"
    local msg="$2"

    case $type in
        info)    echo -e "${INFO}[INFO]${RESET} $msg" ;;
        success) echo -e "${SUCCESS}[SUCCESS]${RESET} $msg" ;;
        warn)    echo -e "${WARN}[WARNING]${RESET} $msg" ;;
        error)   echo -e "${ERROR}[ERROR]${RESET} $msg" ;;
        *)       echo -e "[LOG] $msg" ;;
    esac
}

# catch an error when exiting the script (e.g by clicking ctrl+c)
trap 'log error "Script canceled"; exit 130' SIGINT

# configuring pacman.conf
sudo sed -i "s|^#Color|Color|" /etc/pacman.conf
sudo sed -i "s|^#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
sudo sed -i "s|^#\[\(multilib\)\]$|[\1]|" /etc/pacman.conf
sudo sed -i "/^\[multilib\]$/{n;s|^#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|;}" /etc/pacman.conf

update_system() {
    sudo pacman -Sy

    if ! pacman -Qi pacman-contrib &>/dev/null; then
        log info "Checkupdates utility not found, installing..."
        if ! sudo pacman -S pacman-contrib --noconfirm; then
            log error "Failed to install checkupdates utility, exiting..."
            return 1
        fi
    fi

    local upd_count=$(checkupdates | wc -l)

    if [[ $upd_count -gt 0 ]]; then
        log info "Found $upd_count new updates for the next packages:"
        checkupdates
        if ! sudo pacman -Syu; then
            log error "System update canceled or failed, exiting..."
            return 1
        fi
        log success "System has been updated"
    else
        log info "System is up to date, skipping..."
    fi
}

 install_pkg_helpers() {
    if ! type yay &>/dev/null; then
        log info "Installing yay..."
        cd /tmp &&
        (
        git clone https://aur.archlinux.org/yay-bin.git ||
        git clone --branch yay-bin --single-branch https://github.com/archlinux/aur.git yay-bin
        ) &&
        cd yay-bin &&
        makepkg -si --noconfirm &&
        log success "Yay installed!" || {
            log error "Failed to install yay, exiting..."
            return 1
        }
   else
        log info "Yay already installed, skipping..."
   fi
 }

installing_hook() {
    local repo_type=$1 # pacman|aur
    local pkg_list=("${@:2}")

    local inst_cmd check_cmd
    case $repo_type in
      pacman)
            inst_cmd="sudo pacman -S"
            check_cmd="pacman -Qi"
            ;;
         aur)
            inst_cmd="yay -S"
            check_cmd="yay -Qi"
            ;;
          *)
            log error "Invalid repo type"
            return 1
            ;;
    esac

    for pkg in "${pkg_list[@]}"; do
        if ! $check_cmd $pkg &>/dev/null; then
            log info "Installing [$pkg]..."
            if ! $inst_cmd $pkg --noconfirm; then
                log error "Installing [$pkg] canceled or failed"
                return 1
            fi
        else
            log info "[$pkg] already installed, skipping..."
        fi
    done
}

install_core_packages() {
     if [[ -n $core_packages ]]; then
        log info "Installing core packages..."
        if ! installing_hook pacman "${core_packages[@]}"; then
            log error "Core packages installation failed or canceled, exiting..."
            return 1
        fi
    fi
}

install_user_packages() {
    if [[ -n $user_pacman ]]; then
        log info "Installing user packages via pacman..."
        if installing_hook pacman "${user_pacman[@]}"; then
            log success "Pacman packages installed!"
        else
            log error "Pacman packages installation failed or canceled, exiting..."
            return 1
        fi
    fi

    if type yay &>/dev/null; then
        if [[ -n $user_aur ]]; then
            log info "Installing user packages via yay..."
            if installing_hook aur "${user_aur[@]}"; then
                log success "Aur packages installed!"
            else
                log error "Aur packages installation failed or canceled, exiting..."
                return 1
            fi
        fi
    fi
}

install_system() {
    if [[ -n $i3_packages ]]; then
        log info "Installing i3..."
        if ! sudo pacman -S --needed $i3_packages --noconfirm; then
            log error "i3 installation failed or canceled, exiting..."
            return 1
        else
            log success "i3 packages installed!"
        fi
        log info "Configuring system..."
        sleep 0.1

        log info "Creating user folders..."
        [[ ! -d "$HOME/Pictures" ]] && mkdir -v "$HOME/Pictures"
        [[ ! -d "$HOME/Videos" ]] && mkdir -v "$HOME/Videos"

        log info "Enabling system services..."
        systemctl enable ly.service
        systemctl disable getty@tty2.service
        systemctl --user enable pipewire pipewire-pulse
        systemctl --user start pipewire pipewire-pulse
        sudo systemctl enable --now snapd.socket
        sudo systemctl enable --now snapd.apparmor.service
    fi
}

create_symlinks() {
    if [[ ! -d $dotfiles_dir ]]; then
        log info "dotfiles folder not found, exiting..."
        return 1
    fi

    if [[ ! -d "$HOME"/.config ]]; then
        log info ".config folder not found, creating..."
        mkdir "$HOME"/.config
    fi

    for item in "$dotfiles_dir"/.config/*; do
        echo -e "$(ln -s -v $item "$HOME/.config")"
    done

    if [[ -d $dotfiles_dir ]]; then
        ln -s -v "$dotfiles_dir/scripts" $HOME
        ln -s -v "$dotfiles_dir/wallpapers" $HOME
        ln -s -v "$dotfiles_dir/.Xresources" $HOME
        ln -s -v "$dotfiles_dir/.xprofile" $HOME
        ln -sf -v "$dotfiles_dir/.bashrc" $HOME
    fi
}

exe() {
    local fn_name="$1"

    if $fn_name; then
        log success "$fn_name ok"
    else
        log error "$fn_name error"
        exit 1
    fi
}
exe update_system
exe install_core_packages
exe install_pkg_helpers
exe install_user_packages
exe install_system
exe create_symlinks

read -p "reboot? (y/n) " input
[[ $input = "y" ]] && reboot || echo ":("
