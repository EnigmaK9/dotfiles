#!/bin/bash

# VIM_LIKE_APP is the binary to be used.
# Default is "vim", but you can also use "nvim" or "nvim-qt"
VIM_LIKE_APP=vim

if [ $# -eq 1 ]; then
    if [ "$1" == "-n" ]; then
        VIM_LIKE_APP=nvim
    elif [ "$1" == "-w" ]; then
        VIM_LIKE_APP=nvim-qt
    fi
fi

# Function to ensure a directory exists
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

# Install vim-plug if it's not installed
if [ ! -f ~/.vim/autoload/plug.vim ]; then
    echo "Installing vim-plug..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Copy the vimrc (located in the current directory) to ~/.vimrc
cp vimrc ~/.vimrc

# Neovim specific: create a symlink for init.vim if using nvim
if [ "$VIM_LIKE_APP" == "nvim" ]; then
    ensure_dir ~/.config/nvim
    ln -n ~/.vimrc ~/.config/nvim/init.vim
fi

# Run Vim to install plugins via vim-plug
$VIM_LIKE_APP +PlugInstall +qall

# Copy additional configuration files to the respective plugin directories

# 1. Emmet snippet for emmet-vim
SOURCE_FILE="snips/emmet.vim"
TARGET_DIR="$HOME/.vim/plugged/emmet-vim/autoload"
ensure_dir "$TARGET_DIR"
if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$TARGET_DIR"
else
    echo "Warning: $SOURCE_FILE not found."
fi

# 2. Neosnippet snippets
SOURCE_PATTERN="snips/*.snip"
TARGET_DIR="$HOME/.vim/plugged/neosnippet-snippets/neosnippets"
ensure_dir "$TARGET_DIR"
if compgen -G "$SOURCE_PATTERN" > /dev/null; then
    cp $SOURCE_PATTERN "$TARGET_DIR"
else
    echo "Warning: No snippet files matching $SOURCE_PATTERN found."
fi

# 3. Tender colorscheme
SOURCE_FILE="colors/tender.vim"
TARGET_DIR="$HOME/.vim/plugged/awesome-vim-colorschemes/colors"
ensure_dir "$TARGET_DIR"
if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$TARGET_DIR"
else
    echo "Warning: $SOURCE_FILE not found."
fi

# 4. c-conceal configuration
SOURCE_FILE="other_scripts/c_conceal.vim"
TARGET_DIR="$HOME/.vim/plugged/c-conceal/after/syntax"
ensure_dir "$TARGET_DIR"
if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$TARGET_DIR/c.vim"
else
    echo "Warning: $SOURCE_FILE not found."
fi

# 5. Clang tidy script
SOURCE_FILE="other_scripts/clang_tidy_sangria_correcta.sh"
TARGET_DIR="$HOME/.vim"
if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$TARGET_DIR"
else
    echo "Warning: $SOURCE_FILE not found."
fi

# 6. Clang-format1: located in the parent directory
SOURCE_FILE="../clang-format1"
TARGET_FILE="$HOME/.clang-format"
if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$TARGET_FILE"
else
    echo "Warning: $SOURCE_FILE not found."
fi

# 7. Compile C programs for cutting and pasting spaces
SOURCE_FILE="other_scripts/quitar_espacios.c"
TARGET_FILE="$HOME/.vim/cortar"
if [ -f "$SOURCE_FILE" ]; then
    gcc "$SOURCE_FILE" -o "$TARGET_FILE"
else
    echo "Warning: $SOURCE_FILE not found."
fi

SOURCE_FILE="other_scripts/aniadir_espacios.c"
TARGET_FILE="$HOME/.vim/pegar"
if [ -f "$SOURCE_FILE" ]; then
    gcc "$SOURCE_FILE" -o "$TARGET_FILE"
else
    echo "Warning: $SOURCE_FILE not found."
fi

echo "Setup completed."

