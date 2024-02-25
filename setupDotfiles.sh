#!/bin/bash
pacman -Syu --noconfirm --needed git

git clone --bare https://github.com/alexbelks/ArchSimpleDotfiles.git ~/.cfg
git --git-dir=~/.cfg/ --work-tree=~/ checkout

# Установка основных пакетов
sudo pacman -Syu --noconfirm --needed networkmanager neovim pulseaudio pulseaudio-alsa xorg xorg-xinit xorg-server base-devel xfce4 xfce4-goodies i3 lightdm lightdm-gtk-greeter xclipzsh feh

# Настройка NetworkManager
systemctl enable NetworkManager

# Установка yay (AUR helper)
 git clone https://aur.archlinux.org/yay.git ~/yay

cd yay &&  makepkg -si --noconfirm
cd
# Очистка
 rm -rf yay
systemctl enable lightdm.service


TOUCHPAD_CONFIG="/etc/X11/xorg.conf.d/40-libinput.conf"

# Проверяем, существует ли файл конфигурации
if [ ! -f "$TOUCHPAD_CONFIG" ]; then
    echo "Файл конфигурации тачпада не найден. Создаем новый."
    # Создание директории, если она еще не существует
    mkdir -p /etc/X11/xorg.conf.d/
    # Создание нового файла конфигурации
    touch "$TOUCHPAD_CONFIG"
fi

# Добавление настроек в файл конфигурации
echo 'Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
        Option "TappingButtonMap" "lrm" # Left, Right, Middle click for 1, 2, and 3 finger tap respectively
EndSection' | sudo tee "$TOUCHPAD_CONFIG"

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sudo pacman -S --noconfirm --needed fzf python-pip
pip install thefuck

source /home/$USERNAME/.zshrc
