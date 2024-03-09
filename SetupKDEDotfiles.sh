
# Установка KDE Plasma и системных инструментов
sudo pacman -Syu --noconfirm --needed git xorg xorg-xinit xorg-server base-devel plasma  sddm konsole dolphin kate plasma-nm plasma-pa ark gwenview spectacle neovim nano --noconfirm
sudo systemctl enable sddm

# Установка Pipewire и настройка звука
sudo pacman -Syu --noconfirm --needed pipewire pipewire-alsa pipewire-pulse pipewire-jack pavucontrol 
sudo systemctl enable pipewire pipewire-pulse

sudo usermod -aG wheel,audio,video $USER

if ! command -v yay &> /dev/null
then
    echo "yay не найден, начинаем установку..."
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay && makepkg -si --noconfirm --needed
    cd ~
    rm -rf ~/yay
else
    echo "yay уже установлен."
fi

# Сообщение о завершении установки и перезагрузка
echo "Установка завершена. Система будет автоматически перезагружена через 5 секунд..."
sleep 5
reboot
