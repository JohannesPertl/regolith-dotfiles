#!/bin/bash
git_name="Johannes Pertl"
git_email=$1

if [ -z "$git_email" ]; then
  echo "Usage: $0 <git_email>"
  exit 1
fi

setup_git() {
  if ! command -v git; then
    sudo apt install git -y &
  fi
  git config --global core.editor "vim"
  git config --global user.name "${git_name}"
  git config --global user.email "${git_email}"
  git config --global credential.helper store
}

setup_fish() {
  if ! command -v fish; then
    sudo apt-add-repository ppa:fish-shell/release-3 -y
    sudo apt update
    sudo apt install fish -y
  fi
  sudo chsh -s "$(which fish)" "$USER"

  # TODO: Replace omf and bobthefish with tide and autoconfigure it
  if ! command -v omf; then
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install >install &&
      chmod +x install
    ./install --noninteractive
    rm install
  fi
  fish -c "omf install bobthefish"
  fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
  fish -c "fisher install jethrokuan/z"

  # Use TAB as auto suggestion shortcut
  #sudo apt install xclip -y
  #fish_config=~/.config/fish/config.fish
  #binding='bind \t accept-autosuggestion'
  #if ! grep -Fq "$binding" $fish_config
  #  then
  #    echo "$binding" >> $fish_config
  #fi
}

setup_nvm() {
  if ! command -v nvm; then
    fish -c "fisher install jorgebucaran/nvm.fish"
    fish -c "nvm install latest"
    fish -c "set --universal nvm_default_version latest"
  fi
}

setup_homebrew() {
  if ! command -v brew; then
    echo -ne '\n' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fish -c "fish_add_path /home/linuxbrew/.linuxbrew/bin"
  fi
}

setup_dependencies() {
  sudo apt update -y && sudo apt upgrade -y &&
    sudo apt install snapd curl -y &&
    setup_git
  sudo apt install -y python3-dev python3-pip python3-setuptools pipx
  setup_fish
  setup_nvm
  setup_homebrew
}

setup_chrome() {
  if ! command -v google-chrome; then
    sudo apt install fonts-liberation &&
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
      sudo apt install -y ./google-chrome-stable_current_amd64.deb &&
      rm ./google-chrome-stable_current_amd64.deb
  fi
}

setup_i3() {
  # Dotfiles
  # TODO: Move to end of script?
  cp -r .config ~
  # Home config
  cp -r .home/* ~
  # Autotiling
  sudo cp bin/autotiling.py /usr/bin/autotiling

  # Temp fix for jetbrains floating windows 
  ## https://youtrack.jetbrains.com/issue/JBR-4023
  set _JAVA_AWT_WM_STATIC_GRAVITY 1

  i3-msg reload
  i3-msg restart
}


fix_regolith_bugs() {
  # Fix chrome file upload not working https://github.com/orgs/regolith-linux/discussions/984
  sudo apt remove xdg-desktop-portal-regolith xdg-desktop-portal-gnome
}

setup_neovim() {
  # TODO: Install and setup nvchad instead, use and configure a different copilot plugin
  if ! command -v nvim; then
    sudo snap install nvim --classic
  fi
  ## Copilot
  git clone https://github.com/github/copilot.vim.git \
    ~/.config/nvim/pack/github/start/copilot.vim
}

setup_tools() {
  pipx install shell-gpt
  fish -c "npm install -g tldr"
  sudo snap install jq
  sudo snap install httpie
  wget -qO- https://raw.githubusercontent.com/rettier/c/master/install.sh | bash
  sudo apt install at
  # Bat
  sudo apt install -y bat
  sudo mv "$(which batcat)" /usr/bin/bat
  # The Fuck
  if ! command -v fuck; then
    sudo apt update
    pipx install thefuck --user
    sudo mv ~/.local/bin/thefuck /usr/bin/thefuck
    sudo mv ~/.local/bin/fuck /usr/bin/fuck
  fi
  # Clipboard manager
  sudo apt install diodon -y
  ## Add shortcut for diodon
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'diodon'"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Super><Ctrl>c'"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'/usr/bin/diodon'"
  # Rebind super
  gsettings set org.gnome.desktop.input-sources xkb-options "['caps:super', 'altwin:swap_lalt_lwin']"
  # Adjust mouse scroll speed
  sudo apt install imwheel
  sudo cp bin/mousewheel.sh /usr/bin/scroll
  # Custom script for ultrawide monitors
  sudo cp bin/center /usr/bin/center
  # bun
  curl -fsSL https://bun.sh/install | bash
}

setup_docker() {
  # TODO: Fix script exiting if user already in group
  sudo snap install docker
  sudo addgroup --system docker
  sudo adduser "$USER" docker
  newgrp docker
  sudo snap disable docker
  sudo snap enable docker
}

setup_dev_stuff() {
  sudo snap install code --classic
  #sudo snap install intellij-idea-ultimate --classic
  #sudo snap install pycharm-professional --classic
  #sudo snap install webstorm --classic
  sudo snap install postman
 # sudo snap install flutter --classic
  # Android Studio with VM acceleration
 # sudo snap install android-studio --classic &&
#	  sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
  sudo apt install adb -y
  # Firebase
  sudo curl -sL https://firebase.tools | bash &&
	  dart pub global activate flutterfire_cli &&
	  fish -c "fish_add_path $HOME/.pub-cache/bin"

}

setup_grub_customizer() {
  if ! command -v grub-customizer; then
    sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
    sudo apt-get update
    sudo apt-get install grub-customizer -y
  fi
}


setup_xpointerbarrier() {
  # Traps the mouse to one screen on multi-monitor setups
  cd /tmp &&
    git clone https://github.com/JohannesPertl/xpointerbarrier-ubuntu &&
    cd xpointerbarrier-ubuntu &&
    make && sudo make install
}

setup_user_apps() {
  sudo snap install discord
  sudo snap install vlc
  # Signal
  wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee -a /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null &&
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee -a /etc/apt/sources.list.d/signal-xenial.list &&
  sudo apt update && sudo apt install signal-desktop &&
  rm signal-desktop-keyring.gpg
}

setup_laptop() {
  # Ignore lid close when laptop is docked
  sudo sed -i -e 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/g' /etc/systemd/logind.conf	
}

setup_space2meta() {
  # Use holding space as meta key
  # TODO: Configure udevmon and space2meta autostart
  # sudo udevmon
  sudo cp etc/ / &&
  sudo cp bin/udevmon /usr/bin/udevmon &&
  sudo cp bin/space2meta /usr/bin/space2meta
}

setup_sdkman(){
  # Run sdk afterwards
  fish -c "fisher install reitzig/sdkman-for-fish@v2.1.0"
}

setup_dependencies
setup_chrome
setup_i3
setup_neovim
setup_tools
setup_dev_stuff
setup_grub_customizer
#setup_xpointerbarrier
setup_user_apps
setup_laptop
#setup_space2meta
setup_docker
setup_sdkman
fix_regolith_bugs
