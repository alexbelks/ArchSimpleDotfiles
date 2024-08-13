#!/bin/bash

# Запрос информации от пользователя
echo "Enter the computer name:"
read HOSTNAME
echo "Enter the user name:"
read USERNAME
echo "Enter the password for the user $USERNAME:"
read -s USER_PASSWORD
echo "Enter the password for root:"
read -s ROOT_PASSWORD



#монтирование разделов
mount -L LINUX /mnt
mount --mkdir -L HOME /mnt/home
mount --mkdir -L EFI /mnt/boot/efi

lsblk

# Установка основных пакетов системы
pacstrap /mnt base linux linux-firmware --needed


# Генерация fstab
genfstab -U /mnt >> /mnt/etc/fstab

cat << EOF > /mnt/etc/fstab
LABEL=D  /mnt/D ntfs-3g defaults 0 0
LABEL=C /mnt/C ntfs-3g defaults 0 0
LABEL=E  /mnt/E ntfs-3g defaults 0 0
LABEL=R  /mnt/R ntfs-3g defaults 0 0
LABEL=DATA /mnt/DATA ext4 defaults 0 2
EOF

# Вход в chroot
arch-chroot /mnt /bin/bash <<EOF

systemctl stop ModemManager
systemctl disable ModemManager
systemctl stop cups
systemctl disable cups
systemctl stop avahi-daemon
systemctl disable avahi-daemon
systemctl stop sshd
systemctl disable sshd



mkdir /etc/modprobe.d
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

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

pacman -Syu --noconfirm --needed grub efibootmgr networkmanager sudo neovim ufw apparmor ntfs-3g





# wНастройка GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Включение AppArmor в GRUB
echo "Включаю AppArmor в конфигурации GRUB..."
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& apparmor=1 security=apparmor/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Включение и запуск AppArmor сервиса
echo "Включаю и запускаю сервис AppArmor..."
systemctl enable apparmor


# Настройка профиля AppArmor для NetworkManager
echo "Настраиваю профиль AppArmor для NetworkManager..."
cat > /etc/apparmor.d/usr.sbin.NetworkManager <<EAF
/usr/sbin/NetworkManager {
    /etc/** r,
    /usr/sbin/NetworkManager mr,
    /var/lib/NetworkManager/** rw,
    /run/NetworkManager/** rw,
    network inet dgram,
    network inet stream,
}
EAF

# Имя и путь создаваемого скрипта
SCRIPT_NAME="auto_script.sh"
SCRIPT_PATH="/tmp/$SCRIPT_NAME"
# Имя и путь для systemd сервиса
SERVICE_NAME="auto_script.service"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"

cat << EAF > $SCRIPT_PATH
#!/bin/bash

echo "Скрипт начал работу..."
systemctl stop ModemManager
systemctl disable ModemManager
systemctl stop cups
systemctl disable cups
systemctl stop avahi-daemon
systemctl disable avahi-daemon
systemctl stop sshd
systemctl disable sshd

# фаервол
ufw enable
ufw default deny incoming
ufw default allow outgoing

# Применение профиля AppArmor
echo "Применяю профиль AppArmor для NetworkManager..."
apparmor_parser -r /etc/apparmor.d/usr.sbin.NetworkManager
aa-enforce /etc/apparmor.d/usr.sbin.NetworkManager

echo "Установка и настройка AppArmor завершены."


# Делаем что-то полезное
sleep 5  # Симуляция работы

echo "Скрипт завершен."

# Отключение сервиса из автозапуска
systemctl disable auto_script.service

# Удаление самого скрипта
rm -- "$0"

# Удаление systemd unit файла
rm /etc/systemd/system/auto_script.service

# Перезагрузка systemd для применения изменений
systemctl daemon-reload
EAF

# Делаем созданный скрипт исполняемым
chmod +x $SCRIPT_PATH

# Создание unit-файла для systemd
cat << EAF > $SERVICE_PATH
[Unit]
Description=Auto-generated Script
After=network.target

[Service]
Type=simple
ExecStart=$SCRIPT_PATH
Restart=no

[Install]
WantedBy=multi-user.target
EAF

# Перезагрузка systemd для учета нового сервиса
systemctl daemon-reload

# Включение сервиса в автозапуск
systemctl enable $SERVICE_NAME




systemctl enable NetworkManager

# Настройка sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers


curl -fsSL https://raw.githubusercontent.com/alexbelks/ArchSimpleDotfiles/master/setupDotfiles.sh > /home/$USERNAME/SetupDotfiles.sh
chmod +x /home/$USERNAME/SetupDotfiles.sh
curl -fsSL https://raw.githubusercontent.com/alexbelks/ArchSimpleDotfiles/master/SetupKDEDotfiles.sh > /home/$USERNAME/SetupKDEDotfiles.sh
chmod +x /home/$USERNAME/SetupKDEDotfiles.sh

EOF
umount  /mnt/home
umount  /mnt/boot/efi
umount  /mnt


