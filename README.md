# Quick Start

```Bash
# Installation on Ubuntu 16.04
$ mkdir ~/.vim/bundle
$ git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
$ cp vimrc ~/.vimrc
$ vim
:BundleInstall

# Step 1: Prepare plugins "YouCompleteMe"
# NOTE: You may need to install some necessary packages
$ python3 ~/.vim/bundle/YouCompleteMe/install.py

# Step 2: Prepare plugins "devicons"
# 1. Install the patched font: https:/github.com/ryanoasis/nerd-fonts/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20for%20Powerline%20Nerd%20Font%20Complete.otf
# 2. Choose the patched font on your terminal like "terminator"

# Step 3: Prettify the prompt of bash (PS1)
$ vim
:PromptlineSnapshot ~/.shell_prompt.sh airline

$ vim ~/.shell_prompt.sh
- PS1=”$(__promptline_ps1)”
+ PS1=”\n$(__promptline_ps1)\n\[\033[1;32m\]$ \[\033[1;00m\]”]]

$ vim ~/.bashrc
+ . ~/.shell_prompt.sh
```
