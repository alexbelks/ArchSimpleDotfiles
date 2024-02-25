 #### **Клонирование на другой машине**

  Чтобы клонировать ваш репозиторий dotfiles на другую машину:

  ```bash
  git clone --bare git@github.com:user/repo.git $HOME/.cfg
  alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
  config checkout
  ```

  Если при выполнении `checkout` возникают ошибки из-за существующих файлов, резервируйте их и повторите попытку.

#### **Установка**
```bash
  chmod +x setupArch.sh
  ./setupArch.sh
  ```
