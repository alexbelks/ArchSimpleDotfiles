#!/bin/bash

# Остановка при ошибке
set -e

# Ввод имени пользователя
echo "Введите имя нового пользователя:"
read new_user

# Ввод пароля пользователя
echo "Введите пароль для нового пользователя:"
read -s user_pass
echo

# Ввод пароля root
echo "Введите пароль для пользователя root:"
read -s root_pass
echo

# Обновление системного часа
timedatectl set-ntp true

# Установка основной системы
pacstrap /mnt base linux linux-firmware nano intel-ucode amd-ucode networkmanager

# Настройка fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Вход в chroot и настройка системы
arch-chroot /mnt /bin/bash <<EOF

# Настройка часового пояса
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

# Локализация
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=ru" > /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf

# Настройка сети
echo "myarch" > /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 myarch.localdomain myarch" >> /etc/hosts

# Создание инициализации initramfs
mkinitcpio -P

# Установка загрузчика
pacman -S grub efibootmgr --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Установка пароля root
echo "root:$root_pass" | chpasswd

# Установка KDE Plasma и системных инструментов
pacman -S xorg plasma plasma-wayland-session sddm konsole dolphin kate plasma-nm plasma-pa ark gwenview spectacle sudo --noconfirm
systemctl enable sddm
systemctl enable NetworkManager

# Установка драйверов NVIDIA
pacman -S nvidia nvidia-utils nvidia-settings --noconfirm

# Установка Pipewire и настройка звука
pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack pavucontrol --noconfirm
systemctl enable pipewire pipewire-pulse

# Создание нового пользователя
useradd -m -G wheel,audio,video,network,storage -s /bin/bash $new_user
echo "$new_user:$user_pass" | chpasswd

# Настройка sudo для группы wheel
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Настройка переключения раскладок
localectl set-x11-keymap ru,us pc104 , grp:ctrl_shift_toggle

EOF

# Сообщение о завершении установки и перезагрузка
echo "Установка завершена. Система будет автоматически перезагружена через 5 секунд..."
sleep 5
reboot
