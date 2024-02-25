#### **Полная установка Arch**
```bash
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/alexbelks/ArchSimpleDotfiles/b196ac58a37a0bcb90c22d8e31b66d6228800b71/setupArch.sh)"
```
 
 
 #### **Клонирование на другой машине**

  Чтобы клонировать репозиторий dotfiles на другую машину:

  ```bash
  git clone --bare https://github.com/alexbelks/ArchSimpleDotfiles.git $HOME/.cfg
  alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
  config checkout
  ```

  Если при выполнении `checkout` возникают ошибки из-за существующих файлов, резервируйте их и повторите попытку.


