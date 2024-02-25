#### **Полная установка Arch**
```bash
  git clone https://github.com/alexbelks/ArchSimpleDotfiles.git
  cd ArchSimpleDotfiles
  chmod +x setupArch.sh
  ./setupArch.sh
  rm ../ArchSimpleDotfiles -rf
  reboot
```
 
 
 #### **Клонирование на другой машине**

  Чтобы клонировать репозиторий dotfiles на другую машину:

  ```bash
  git clone --bare https://github.com/alexbelks/ArchSimpleDotfiles.git
  alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
  config checkout
  ```

  Если при выполнении `checkout` возникают ошибки из-за существующих файлов, резервируйте их и повторите попытку.


