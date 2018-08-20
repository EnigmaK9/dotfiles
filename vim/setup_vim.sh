cp ./vimrc ~/.vimrc

if [ ! -d ~/.config/nvim ]; then
    mkdir -p ~/.config/nvim
fi
ln -n ~/.vimrc ~/.config/nvim/init.vim

nvim +qall # Just run config to install plugins and exit

cp ./vim/snips/emmet.vim ~/.vim/plugged/emmet-vim/autoload
cp ./vim/snips/*.snip ~/.vim/plugged/neosnippet-snippets/neosnippets
cp ./vim/colors/tender.vim ~/.vim/plugged/awesome-vim-colorschemes/colors
cp ./vim/other_scripts/c_conceal.vim ~/.vim/plugged/c-conceal/after/syntax/c.vim
cp ./vim/other_scripts/clang_tidy_sangria_correcta.sh ~/.vim
cp ./clang-format1 ~/.clang-format
gcc ./vim/other_scripts/quitar_espacios.c -o ~/.vim/cortar
gcc ./vim/other_scripts/aniadir_espacios.c -o ~/.vim/pegar
