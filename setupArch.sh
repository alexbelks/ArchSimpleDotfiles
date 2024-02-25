#!/bin/bash
echo "blacklist pcspkr" > /etc/modprode.d/nobeep.conf
# Запрос информации от пользователя
echo "Введите название компьютера:"
read HOSTNAME
echo "Введите имя пользователя:"
read USERNAME
echo "Введите пароль для пользователя $USERNAME:"
read -s USER_PASSWORD
echo "Введите пароль для root:"
read -s ROOT_PASSWORD

# Установка основных пакетов системы
pacstrap /mnt base linux linux-firmware --needed

# Генерация fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Вход в chroot
arch-chroot /mnt /bin/bash <<EOF

# Настройка временной зоны
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

# Локализация
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Настройка консоли
echo "KEYMAP=ru" > /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf

# Создание пользователя
useradd -m -g users -G wheel -s /bin/bash $USERNAME

# Установка паролей
echo "$USERNAME:$USER_PASSWORD" | chpasswd
echo "root:$ROOT_PASSWORD" | chpasswd

# Имя хоста
echo "$HOSTNAME" > /etc/hostname

pacman -Syu --noconfirm --needed git

git clone --bare https://github.com/alexbelks/ArchSimpleDotfiles.git /home/$USERNAME/.cfg
git --git-dir=/home/$USERNAME/.cfg/ --work-tree=/home/$USERNAME' checkout

# Установка основных пакетов
pacman -Syu --noconfirm --needed networkmanager neovim pulseaudio pulseaudio-alsa xorg xorg-xinit xorg-server nvidia grub efibootmgr base-devel xfce4 xfce4-goodies i3 lightdm lightdm-gtk-greeter xclipzsh feh

# Настройка NetworkManager
systemctl enable NetworkManager

# Настройка sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Настройка GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg


# Установка yay (AUR helper)
# git clone https://aur.archlinux.org/yay.git /home/$USERNAME/yay
# chown -R $USERNAME:users /home/$USERNAME/yay
# chown -R $USERNAME:users /home/$USERNAME

# sudo -u $USERNAME sh -c 'cd /home/$USERNAME/yay && sudo -u $USERNAME makepkg -si --noconfirm'

# Очистка
# rm -rf /home/$USERNAME/yay
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
source /home/$USERNAME/.zshrc
EOF
reboot
