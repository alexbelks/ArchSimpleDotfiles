# dotfiles
### Minimalistic and simple dotfiles for my i3wm + xfce4 setup.
#### **Arch installation with Russian layout**
```bash
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/alexbelks/ArchSimpleDotfiles/b196ac58a37a0bcb90c22d8e31b66d6228800b71/setupArch.sh)"
```
 
 
 #### **or to the installed system**

  To clone the dotfiles repository to another machine:

  ```bash
  git clone --bare https://github.com/alexbelks/ArchSimpleDotfiles.git $HOME/.cfg
  alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
  config checkout
  ```

  If errors occur during `checkout` due to existing files, back them up and try again.

![image](https://github.com/alexbelks/ArchSimpleDotfiles/assets/93944858/9710efd6-fef3-4a15-873f-7b017d269032)

![image](https://github.com/alexbelks/ArchSimpleDotfiles/assets/93944858/7ebb48c9-3899-49b5-ab55-45298dae7618)

#### **Configuraiton**
- i3
- xfce
- kitty
- zsh
- nvim
