#!/bin/bash
mkdir /etc/modprobe.d
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
# Запрос информации от пользователя
echo "Enter the computer name:"
read HOSTNAME
echo "Enter the computer name:Enter the user name:"
read USERNAME
echo "Enter the password for the user $USERNAME:"
read -s USER_PASSWORD
echo "Enter the password for root:"
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

# Настройка sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

pacman -Syu --noconfirm --needed nvidia grub efibootmgr

# Настройка GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
su $USERNAME
sh -c "$(curl -fsSL https://raw.githubusercontent.com/alexbelks/ArchSimpleDotfiles/master/setupDotfiles.sh)"
EOF
reboot
