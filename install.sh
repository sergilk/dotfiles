#!/usr/bin/env bash

set -e
exec > >(tee "$HOME/install@$(date +%Y-%m-%d_%H:%M).log") 2>&1

arg="$1"
dotfiles_dir="$HOME/dotfiles"
core_packages=("libgnome-keyring" "gnome-keyring" "libsecret" "fuse2" "jq" "wget" "qt5ct" "python-pip" "mesa"
"lib32-mesa" "noto-fonts" "noto-fonts-emoji" "noto-fonts-extra" "noto-fonts-cjk" "ttf-jetbrains-mono-nerd"
"ttf-nerd-fonts-symbols-mono" "pipewire" "pipewire-pulse" "gstreamer" "gst-libav" "gst-plugins-good" "gst-plugins-bad"
"gst-plugins-ugly" "gst-plugins-base" "unrar" "unzip" "7zip" "zip" "bluez" "bluez-tools" "bluez-utils" "xdg-desktop-portal"
"xdg-desktop-portal-gtk" "xsettingsd" "adw-gtk-theme" "xclip")
x_system_packages=("xorg-server xorg-xev xorg-xprop xorg-xauth xorg-xrdb xorg-xinput xorg-xrandr i3-wm i3lock ly")
user_pacman=("feh" "dmenu" "mpv" "j4-dmenu-desktop" "discord" "polybar" "dunst" "xdotool" "libnotify" "copyq" "tmux"
"neovim" "alacritty" "wipe" "trash-cli" "yt-dlp" "playerctl" "pavucontrol" "picom" "thunar" "thunar-archive-plugin"
"thunar-media-tags-plugin" "thunar-volman" "tumbler" "ffmpegthumbnailer" "gvfs" "polkit-gnome" "webp-pixbuf-loader"
"gpick" "flameshot" "xarchiver" "nsxiv" "telegram-desktop" "btop" "zed")
user_aur=("brave-bin" "visual-studio-code-bin" "bluetuith" "localsend-bin" "python-pywal16" "spotify")
laptop_core=("cbatticon" "brightnessctl" "xf86-video-amdgpu" "vulkan-radeon" "lib32-vulkan-radeon" "alsa-utils")
desktop_core=("nvidia" "nvidia-utils" "nvidia-settings" "lib32-nvidia-utils")
laptop_user_aur=("powerstat")

log() {
    INFO='\e[34m'
    SUCCESS='\e[32m'
    WARN='\e[33m'
    ERROR='\e[31m'
    RESET='\e[0m'

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
trap 'log info "Script canceled"; exit 130' SIGINT

if [[ $EUID -eq 0 ]]; then
    log error "Do not run the sript as root!"
    exit 1
fi

if ! type git &>/dev/null; then
  log error "Install git first!"
  exit 1
fi

if [[ ! -d "$dotfiles_dir" ]]; then
  log error "Dotfiles folder not found!"
  exit 1
fi

exe() {
  local fn_name="$1"
    if $fn_name; then
      log success "$fn_name ok"
    else
      log error "$fn_name error"
      exit 1
    fi
}

setup_pacman() {
  log info "Configuring pacman.conf..."
  sudo sed -i "s|^#Color|Color|" /etc/pacman.conf
  sudo sed -i "s|^#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
  sudo sed -i "s|^#\[\(multilib\)\]$|[\1]|" /etc/pacman.conf
  sudo sed -i "/^\[multilib\]$/{n;s|^#Include = /etc/pacman.d/mirrorlist|Include = /etc/pacman.d/mirrorlist|;}" /etc/pacman.conf
}

update_system() {
    sudo pacman -Syy

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
        [[ -d /tmp/yay-bin ]] && sudo rm -rf /tmp/yay-bin
        cd /tmp
        git clone https://aur.archlinux.org/yay-bin.git || return 1
        cd yay-bin
        makepkg -si --noconfirm && log success "Yay installed!" || {
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
            inst_cmd=(sudo pacman -S --needed --noconfirm)
            check_cmd=(pacman -Qi)
            ;;
         aur)
            inst_cmd=(yay -S --needed --noconfirm --norebuild --noredownload)
            check_cmd=(yay -Qi)
            ;;
          *)
            log error "Invalid repo type"
            return 1
            ;;
    esac

    for pkg in "${pkg_list[@]}"; do
        if ! "${check_cmd[@]}" "$pkg" &>/dev/null; then
            log info "Installing [$pkg]..."
            if ! "${inst_cmd[@]}" "$pkg"; then
                log error "Installing [$pkg] canceled or failed"
                return 1
            fi
        else
            log info "[$pkg] already installed, skipping..."
        fi
    done
}

install_core_packages() {
     if [[ "${#core_packages[@]}" -gt 0 ]]; then
        log info "Installing core packages..."
        if ! installing_hook pacman "${core_packages[@]}"; then
            log error "Core packages installation failed or canceled, exiting..."
            return 1
        fi
    fi
}

install_user_packages() {
    if [[ "${#user_pacman[@]}" -gt 0 ]]; then
        log info "Installing user packages via pacman..."
        if installing_hook pacman "${user_pacman[@]}"; then
            log success "Pacman packages installed!"
        else
            log error "Pacman packages installation failed or canceled, exiting..."
            return 1
        fi
    fi

    if type yay &>/dev/null; then
        if [[ "${#user_aur[@]}" -gt 0 ]]; then
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

install_x_system() {
    if [[ -n $x_system_packages ]]; then
        log info "Installing X system..."
        if ! sudo pacman -S --needed $x_system_packages --noconfirm; then
            log error "System installation failed or canceled, exiting..."
            return 1
        else
            log success "System packages installed!"
        fi
        log info "Configuring system..."
        sleep 0.1

        log info "Creating user folders..."
        [[ ! -d "$HOME/Pictures" ]] && mkdir -v "$HOME/Pictures"
        [[ ! -d "$HOME/Videos" ]] && mkdir -v "$HOME/Videos"

        log info "Enabling system services..."
        sudo systemctl enable ly@tty2.service
        sudo systemctl disable getty@tty2.service
        systemctl --user enable pipewire pipewire-pulse
        systemctl --user start pipewire pipewire-pulse
        sudo systemctl enable bluetooth.service
        sudo systemctl start bluetooth.service

        log info "Configruing peripherals..."
        sudo tee /etc/X11/xorg.conf.d/40-libinput.conf > /dev/null <<EOF
        Section "InputClass"
        Identifier "libinput pointer catchall"
        MatchIsPointer "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        Option "AccelProfile" "flat"
        EndSection
EOF
        sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf > /dev/null << EOF
        Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "us,ua"
        Option "XkbOptions" "grp:alt_shift_toggle"
        EndSection
EOF
        if [[ "$platform" == "laptop" ]]; then
        sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf > /dev/null <<EOF
        Section "InputClass"
        Identifier "touchpad"
        Driver "libinput"
        MatchIsTouchpad "on"
        Option "Tapping" "on"
        Option "TappingButtonMap" "lmr"
        EndSection
EOF
        fi
    fi
}

create_symlinks() {
  local ignore_list=(".git" ".gitignore" "install.sh" "wallpaper.png" "misc")
  local target_dir="$HOME"

  find "$dotfiles_dir" -type f | while IFS= read -r item; do
    for ignore in "${ignore_list[@]}"; do
      [[ "$item" == *"/$ignore"*  || "$item" == "$dotfiles_dir/$ignore" ]] && continue 2
    done
    [[ "$platform" == "desktop" && "$item" == *"_laptop"* ]] && continue
    [[ "$platform" == "laptop" && "$item" == *"_desktop"* ]] && continue

    dir="$(dirname "$item")"
    relative_dir="${dir#"$dotfiles_dir"}"
    item_name="$(basename "$item")"
    clean_name="${item_name/_${platform}/}"

    if [[ -f "$item" && "$item" == *"_${platform}"* ]]; then
      mkdir -p "$target_dir/$relative_dir"
      ln -svf "$(realpath "$item")" "$target_dir/$relative_dir/$clean_name"
      head -n1 "$item" | grep -q '^#!' && chmod +x "$target_dir/$relative_dir/$clean_name"
    else
      mkdir -p "$target_dir/$relative_dir"
      ln -svf "$(realpath "$item")" "$target_dir/$relative_dir/$item_name"
    fi
  done
}

post_install() {
  log info "Perform post installation steps..."

  # install nvim plugin manager
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  nvim -c PlugInstall

  # install nvm
  ! command -v nvm >/dev/null && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  sed -i '/export NVM_DIR/,/bash_completion/d' "$HOME/.bashrc"
  [[ -f "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  nvm install --lts

  # adjust nvim.desktop to open text files from gui via alacritty+neovim
  sudo sed -i "s|^Exec=nvim %F|Exec=alacritty -e nvim %F|" /usr/share/applications/nvim.desktop
  sudo sed -i "s|^Terminal=true|Terminal=false|" /usr/share/applications/nvim.desktop
}

main() {
  exe setup_pacman
  exe update_system
  exe install_core_packages
  exe install_pkg_helpers
  exe install_user_packages
  exe install_x_system
  exe create_symlinks

  read -r -p "reboot? (y/n) " input
  [[ $input = "y" ]] && reboot || echo ":("
}

case "$arg" in
  laptop|desktop)
    platform="$arg"
    [[ "$platform" == "laptop" ]] && core_packages+=("${laptop_core[@]}") && user_aur+=("${laptop_user_aur[@]}")
    [[ "$platform" == "desktop" ]] && core_packages+=("${desktop_core[@]}")
    ;;
  update_system|create_symlinks|post_install)
    exe "$arg"
    exit 0
    ;;
  *)
    log error "Missed argument!
    1) For normal installation, pass the correct device platform!
      # Usage: $0 (desktop|laptop)
    2) To execute a specific function, pass as argument next entry:
      - update_system
      - create_symlinks
      - post_install
      # Usage: $0 entry above"
    exit 1
    ;;
esac

# entrypoint
main
