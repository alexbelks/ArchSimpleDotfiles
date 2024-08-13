#!/bin/bash

sudo sh << EAF

cat << EOF /etc/apparmor.d/usr.bin.pulseaudio
#include <tunables/global>

/usr/bin/pulseaudio {
  # Права доступа к основным системным файлам и директориям
  /bin/* ixr,
  /usr/bin/* ixr,
  /lib/* ixr,
  /usr/lib/* ixr,
  /lib64/* ixr,
  /usr/lib64/* ixr,
  
  # Ограничение доступа к конфигурационным файлам PulseAudio
  /etc/pulse/** r,
  /var/lib/pulse/** rwk,
  /var/run/pulse/** rwk,

  # Доступ к аудиоустройствам
  /dev/snd/ r,
  /dev/snd/* rw,

  # Доступ к необходимым IPC и сетевым ресурсам
  /dev/shm/pulse-shm-* rw,
  /run/user/*/pulse/ rw,

  # Сетевая активность PulseAudio
  network inet stream,
  network inet dgram,

  # Запрещение всего остального
  deny / rw,
  deny /home/** rw,

  # Разрешение записи логов
  capability sys_ptrace,
  capability sys_admin,

  # Запрет на прямой доступ к железу
  deny /dev/mem rw,
  deny /dev/kmem rw,
}
EOF

cat << EOF > /etc/apparmor.d/usr.bin.Xorg
#include <tunables/global>

/usr/bin/Xorg {
  # Права доступа к системным библиотекам и исполняемым файлам
  /bin/* ixr,
  /usr/bin/* ixr,
  /lib/* ixr,
  /usr/lib/* ixr,
  /lib64/* ixr,
  /usr/lib64/* ixr,

  # Доступ к конфигурационным файлам Xorg
  /etc/X11/** r,
  /usr/share/X11/** r,

  # Доступ к видеоустройствам
  /dev/dri/* rw,
  /dev/input/* rw,

  # Доступ к временным файлам
  /tmp/** rw,
  /var/tmp/** rw,

  # Доступ к необходимым IPC и сетевым ресурсам
  /dev/shm/** rw,

  # Сетевая активность Xorg
  network inet stream,
  network inet dgram,

  # Запрещение всего остального
  deny / rw,
  deny /home/** rw,

  # Разрешение записи логов
  capability sys_ptrace,
  capability sys_admin,

  # Запрет на прямой доступ к железу
  deny /dev/mem rw,
  deny /dev/kmem rw,
}


EOF

pacman -Syu --noconfirm --needed git
repo_dir="$HOME/.cfg"
work_tree="$HOME"
# Проверка на существование репозитория и клонирование, если не существует
if [ ! -d $repo_dir ]; then
    git clone --bare https://github.com/alexbelks/ArchSimpleDotfiles.git "$repo_dir"
else
    echo "Репозиторий ~/.cfg уже существует. Обновление..."
    git --git-dir="$repo_dir" --work-tree="$work_tree" fetch --all
    git --git-dir="$repo_dir" --work-tree="$work_tree" reset --hard origin/master
fi

# Указываем директорию для резервных копий
backup_dir="$HOME/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"


# Получаем список файлов, которые будут изменены или удалены командой checkout
changed_files=$(git --git-dir="$repo_dir" --work-tree="$work_tree" status --porcelain | grep -E '^(M| D)' | cut -c4-)

# Перебираем измененные файлы и создаем резервные копии
echo "$changed_files" | while IFS= read -r file; do
    if [ -f "$work_tree/$file" ]; then
        # Создаем директории в backup_dir, если необходимо
        mkdir -p "$backup_dir/$(dirname "$file")"
        # Копируем файл в директорию резервных копий
        cp "$work_tree/$file" "$backup_dir/$file"
        echo "Резервная копия создана для: $file"
    fi
done
echo good
# Теперь можно безопасно выполнить checkout
git --git-dir="$repo_dir" --work-tree="$work_tree" checkout -f

# Установка основных пакетов
pacman -Syu --noconfirm --needed networkmanager neovim pulseaudio pulseaudio-alsa xorg xorg-xinit xorg-server base-devel xfce4 xfce4-goodies i3 xclip zsh feh fzf python-pip kitty python-pipx; 


TOUCHPAD_CONFIG="/etc/X11/xorg.conf.d/40-libinput.conf"

# Проверяем, существует ли файл конфигурации
if [ ! -f "$TOUCHPAD_CONFIG" ]; then
    echo "Файл конфигурации тачпада не найден. Создаем новый."
    # Создание директории, если она еще не существует
    mkdir -p /etc/X11/xorg.conf.d/;  touch "$TOUCHPAD_CONFIG"
    # Создание нового файла конфигурации
fi

# Добавление настроек в файл конфигурации
echo 'Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
        Option "TappingButtonMap" "lrm" # Left, Right, Middle click for 1, 2, and 3 finger tap respectively
EndSection' | tee "$TOUCHPAD_CONFIG"


EAF

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

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Проверка и клонирование zsh плагинов
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

source ~/.zshrc

