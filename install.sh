#!/bin/sh
DOTFILES="$HOME/.dotfiles"
if [ -d $DOTFILES ]; then
    echo "Update my dotfiles ..."
    cd $DOTFILES && git pull origin master
else
    git clone 
    git clone https://github.com/Shougo/neobundle.vim.git $DOTFILES/.vim/bundle/neobundle.vim
fi
for i in `ls -A $DOTFILES | grep -v "^\.git$" | grep "^\."`; do
    rm -rf $HOME/$i && ln -s $DOTFILES/$i $HOME/$i && echo "Set $i";
done
