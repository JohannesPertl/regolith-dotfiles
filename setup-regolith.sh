#!/bin/bash
git_name="Johannes Pertl"
git_email=$1

if [ -z "$git_email" ]; then
    echo "Usage: $0 <git_email>"
    exit 1
fi

setup_git(){
if ! command -v git;then
  sudo apt install git -y &
fi
  git config --global core.editor "vim"
  git config --global user.name ${git_name}
  git config --global user.email ${git_email}
  git config --global credential.helper store
}

setup_fish(){
sudo apt-add-repository ppa:fish-shell/release-3 -y
sudo apt update
sudo apt install fish -y
sudo chsh -s $(which fish)
curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install > install &&
chmod +x install
./install --noninteractive
rm install
fish -c "omf install bobthefish"
fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
fish -c "fisher install jethrokuan/z"
}

setup_nvm(){
if ! command -v nvm;then
fish -c "fisher install jorgebucaran/nvm.fish"
nvm install 17.1.0
fish -c "set --universal nvm_default_version v17.1.0"
fi
}


setup_dependencies(){
sudo apt update -y  && sudo apt upgrade -y &&
sudo apt install snapd curl -y && 
setup_git
setup_fish
setup_nvm
# Install Homebrew
echo -ne '\n' | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

setup_chrome(){
if ! command -v google-chrome;then
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
  sudo apt install -y ./google-chrome-stable_current_amd64.deb &&
  rm ./google-chrome-stable_current_amd64.deb
fi
}

setup_i3(){
## Dotfiles
cp -r .config/regolith/* ~/.config/regolith/ &&
## Autotiling
sudo cp bin/autotiling.py /usr/bin/autotiling

i3-msg reload
i3-msg restart
}

setup_neovim(){
sudo snap install nvim --classic &&
## Copilot
git clone https://github.com/github/copilot.vim.git \
  ~/.config/nvim/pack/github/start/copilot.vim
}


setup_tools(){
sudo npm install -g tldr
sudo snap install jq
sudo snap install http
sudo snap install vlc
wget -qO- https://raw.githubusercontent.com/rettier/c/master/install.sh | bash
# Bat
sudo apt install -y bat
sudo mv $(which batcat) /usr/bin/bat
# The Fuck
sudo apt update
sudo apt install -y python3-dev python3-pip python3-setuptools
pip3 install thefuck --user
sudo mv ~/.local/bin/thefuck /usr/bin/thefuck
sudo mv ~/.local/bin/fuck /usr/bin/fuck
# Clipboard manager
sudo apt install diodon -y
## Add shortcut for diodon
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'diodon'"	
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Super><Ctrl>h'"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'/usr/bin/diodon'"
# Adjust mouse scroll speed
sudo cp bin/mousewheel.sh /usr/bin/scroll
}

setup_docker(){
sudo snap install docker

sudo addgroup --system docker
sudo adduser $USER docker
newgrp docker
sudo snap disable docker
sudo snap enable docker
}

setup_ides(){
sudo snap install code --classic
sudo snap install intellij-idea-ultimate --classic
sudo snap install pycharm-professional --classic
sudo snap install webstorm --classic
sudo snap install android-studio --classic
# Install KVM for accelerating emulator
sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils -y
}

setup_grub_customizer(){
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo apt-get update
sudo apt-get install grub-customizer -y
}

setup_abbreviations(){
fish -c "abbr -a vim nvim"
fish -c "abbr -a apt sudo apt"
fish -c "abbr -a install sudo apt install -y"
fish -c "abbr -a remove sudo apt remove"
fish -c "abbr -a gst git status"
fish -c "abbr -a ga git add"
fish -c "abbr -a gaa git add --all"
fish -c "abbr -a gc git commit -m"
}

setup_xpointerbarrier(){
# Install xpointerbarrier, which is used to trap the mouse to one screen on multi-monitor setups
cd /tmp &&
git clone https://github.com/JohannesPertl/xpointerbarrier-ubuntu &&
cd xpointerbarrier-ubuntu &&
make && sudo make install
}


setup_dependencies
setup_chrome
setup_i3
setup_neovim
setup_tools
setup_docker
setup_ides
setup_grub_customizer
setup_abbreviations
setup_xpointerbarrier
