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

# Установка основных пакетов
pacman -Syu --noconfirm --needed networkmanager neovim pulseaudio pulseaudio-alsa xorg xorg-xinit xorg-server nvidia grub efibootmgr base-devel git xfce4 xfce4-goodies i3 lightdm lightdm-gtk-greeter xclip

# Настройка NetworkManager
systemctl enable NetworkManager

# Настройка sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Настройка GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Автоматическая настройка i3 в XFCE
mkdir -p /home/$USERNAME/.config/autostart
cat <<EOT > /home/$USERNAME/.config/autostart/i3.desktop
[Desktop Entry]
Type=Application
Name=i3
Exec=i3
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOT

chown -R $USERNAME:users /home/$USERNAME/.config

# Установка yay (AUR helper)
# git clone https://aur.archlinux.org/yay.git /home/$USERNAME/yay
# chown -R $USERNAME:users /home/$USERNAME/yay
# chown -R $USERNAME:users /home/$USERNAME

# sudo -u $USERNAME sh -c 'cd /home/$USERNAME/yay && sudo -u $USERNAME makepkg -si --noconfirm'

# Очистка
# rm -rf /home/$USERNAME/yay
systemctl enable lightdm.service



# Отключение xfwm4 и xfdesktop, настройка i3 как оконного менеджера
xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -t string -sa "i3" -t string -sa "" --create
xfconf-query -c xfce4-session -p /sessions/Failsafe/Client1_Command -t string -sa "" --create

EOF

