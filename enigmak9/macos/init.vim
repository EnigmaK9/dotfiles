" =============================================================================
"                            My Vim/Neovim Configuration
" =============================================================================

" === Configuration Variables ======
" Define which plugins to use:
"   0 = None
"   1 = Plugins without dependencies
"   2 = All plugins
" ==================================
let s:use_plugins = 2

" Determine if long lines should wrap or extend off-screen
let s:wrap_long_lines = 1

" Determine whether copy/paste/delete operations interact with the system clipboard or only with Vim registers
let s:use_system_clipboard = 1

" Define whether Vim keeps local backup and swap files
let s:use_local_backup = 1

" Enable or disable spell checking / use English or Spanish
" Spanish mode:
let s:enable_spell_check = 1
let s:spell_check_in_spanish = 0
" ### End Configuration Variables

" ##### General Settings ##### {{{
" Set file encoding for files
set encoding=utf-8     " Use UTF-8 for files
scriptencoding utf-8   " Use UTF-8 for scripts (allows commands with ñ, etc.)
set mouse=a            " Enable mouse support for navigation and selection
set exrc               " Allow local .vimrc and .exrc files
set secure             " Disable insecure commands from local .exrc files

" Matching pairs (parentheses, brackets, etc.)
set showmatch         " Highlight matching brackets/parentheses
set matchpairs+=<:>   " Also jump between matching angle brackets
" Use % to jump between matching pairs

let g:mapleader = ','  " Set leader key to ',' (since '\' is less accessible)

" Automatically download the plugin manager if plugins are enabled
if s:use_plugins
    let s:plugin_manager_path = expand('~/.vim/autoload/plug.vim')

    if !filereadable(s:plugin_manager_path)
        echomsg 'Installing Vim-Plug plugin manager...'
        echomsg 'Creating directory for the plugin'
        call mkdir(expand('~/.vim/autoload/'), 'p')
        if !executable('curl')
            echoerr 'Curl is required or install vim-plug manually'
            quit!
        endif

        echomsg 'Downloading the plugin'
        !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

        if v:shell_error
            echomsg 'Could not install the plugin manager'
            let s:use_plugins = 0
        endif

        let s:plugin_manager_recently_installed = 1
    endif
    execute 'source ' . fnameescape(s:plugin_manager_path)
endif

" Enable file type detection, plugins and indenting
filetype plugin indent on

" Vim versions earlier than 7.4.0 may have issues with the "fish" shell
if &shell =~# 'fish$' && (v:version < 704 || (v:version == 704 && !has('patch276')))
    set shell=/bin/bash
endif
" ### End General Settings }}}

" ##### Plugins and Their Configurations (if enabled) ##### {{{
if s:use_plugins
    " All plugins must be declared between plug#begin() and plug#end()
    call plug#begin('~/.vim/plugged')
endif

" +++ Version Control and Change Tracking +++ {{{
if s:use_plugins >= 1
    " Git integration is provided by vim-fugitive.
    Plug 'tpope/vim-fugitive', { 'on': ['Git', 'Gstatus'] }     " Git integration inside Vim
    " File differences are shown by vim-gitgutter.
    Plug 'airblade/vim-gitgutter', { 'on': 'GitGutterToggle' }    " Show file differences while editing
    " A graphical undo tree is provided by undotree.
    Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }            " Graphical undo tree
    " Directory differences are provided by DirDiff.vim.
    Plug 'vim-scripts/DirDiff.vim'                                " Compare differences between entire directories
    let g:DirDiffExcludes = '*.git,node_modules,package.json'
    nnoremap <F7>         :UndotreeToggle<Return>
    nnoremap <Leader>tgut :UndotreeToggle<Return>
    " :GitGutterToggle - Enable/disable GitGutter
    let g:gitgutter_map_keys = 0
    nmap ]h <Plug>GitGutterNextHunk
    nmap [h <Plug>GitGutterPrevHunk

    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'tomtom/tlib_vim'
    Plug 'garbas/vim-snipmate'
    imap <C-e> <Plug>snipMateNextOrTrigger
    " Optional snippet collection is loaded.

    Plug 'honza/vim-snippets'
    let g:snipMate = { 'snippet_version' : 1 }
endif
" +++ End Version Control Section +++ }}}

" +++ Code Completion and Linting +++ {{{
if s:use_plugins >= 1
    Plug 'mattn/emmet-vim'
    Plug 'tkhren/vim-fake'          " Faketext: generate lorem ipsum etc.
    let g:fake_bootstrap = 1        " Load additional definitions for vim-fake
endif

if s:use_plugins >= 2
    if has('nvim') || (v:version >= 800 && has('python3'))
        if has('nvim')
            if !has('python3')
                echomsg 'Python 3 provider not found. Attempting to install...'
                !pip3 install --upgrade neovim
            endif

            " Code completion
            Plug 'neoclide/coc.nvim', {'branch': 'release'}
            Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
            Plug 'Shougo/deoplete.nvim', { 'do': 'UpdateRemotePlugins' }
            Plug 'carlitux/deoplete-ternjs', { 'do': 'sudo npm install -g tern' }
            let g:deoplete#sources#ternjs#docs = 1
            let g:deoplete#sources#ternjs#include_keywords = 1
        else
            Plug 'Shougo/deoplete.nvim'
            Plug 'roxma/nvim-yarp'
            Plug 'roxma/vim-hug-neovim-rpc'
        endif
        let g:deoplete#enable_at_startup = 1
        Plug 'w0rp/ale'                   " Linting via external tools
        " See ":help ale-support" for language support details
        nnoremap <leader>tsr :call ToggleStaticLinting()<return>
        let s:restricted_linters = {
                    \   'c': ['gcc'],
                    \   'cpp': ['clang'],
                    \}
        let g:ale_linters = s:restricted_linters
        function! ToggleStaticLinting()
            ALEDisable
            if empty(g:ale_linters)
                let g:ale_linters = s:restricted_linters
            else
                let g:ale_linters = {}
            endif
            ALEEnable
        endfunction
    else
        " For Vim without full Neovim support, neocomplete and syntastic are provided.
        if has('lua')                     " Lua is required for neocomplete
            Plug 'Shougo/neocomplete'     " Code completion
            let g:neocomplete#enable_at_startup = 1
        endif
        Plug 'vim-syntastic/Syntastic'    " Syntax checking
    endif

    " Neosnippet is provided for snippet management.
    Plug 'Shougo/neosnippet'              " Snippet manager
    Plug 'Shougo/neosnippet-snippets'     " Predefined snippets
    " Use Ctrl-e (for expand) to trigger snippet expansion
    imap <C-e> <Plug>(neosnippet_expand_or_jump)
    smap <C-e> <Plug>(neosnippet_expand_or_jump)
    xmap <C-e> <Plug>(neosnippet_expand_target)

    "Plug 'vim-scripts/SearchComplete'     " Search completion
    Plug 'Shougo/neoinclude.vim', { 'for': ['c', 'cpp', 'python'] }   " Auto-include headers
      " Use emmet_leader + , to expand emmet abbreviation
      " emmet_leader + n to jump to next emmet edit point
    Plug 'Shougo/neco-vim', { 'for': 'vim' }                          " VimL completion
    Plug 'artur-shaik/vim-javacomplete2', { 'for': 'java' }           " Java completion
    Plug 'saulaxel/jcommenter.vim', { 'for': 'java' }                 " Generate JavaDoc comments
    nnoremap <Leader>jd :call JCommentWriter()<Return>

    Plug 'Rip-Rip/clang_complete' , { 'for': ['c', 'cpp'] }           " C/C++ code completion
    let g:clang_make_default_keymappings = 0
    if !executable('clang')
        echomsg 'Clang must be installed for C/C++ completion'
    endif

    let g:clang_library_path = '/usr/lib/llvm-3.8/lib/libclang.so.1'

    Plug 'davidhalter/jedi-vim', { 'for': 'python' }                  " Python completion
    let g:jedi#completions_enabled    = 1
    let g:jedi#auto_vim_configuration = 0
    let g:jedi#smart_auto_mappings    = 0
    let g:jedi#force_py_version       = 3

    Plug 'tkhren/vim-fake'          " Faketext again for sample text generation
    let g:fake_bootstrap = 1        " Load additional definitions for vim-fake

    " Set up omni-completion for various filetypes
    augroup OmniCompletion
        autocmd!
        autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
        autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
        autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType java setlocal omnifunc=javacomplete#Complete
        autocmd FileType python setlocal omnifunc=jedi#completions
        autocmd FileType sql,html,css,javascript,php setlocal omnifunc=syntaxcomplete#Complete
        autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    augroup END
endif
" +++ End Code Completion Section +++ }}}

" +++ Navigation and Text Editing +++ {{{
if s:use_plugins >= 1
    Plug 'farmergreg/vim-lastplace'
    Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle'}             " Directory tree explorer
    nnoremap <Leader>tgnt :NERDTreeToggle<Return>
    nnoremap <F5>         :NERDTreeToggle<Return>

    Plug 'kshenoy/vim-signature'          " Visual markers for positions
    Plug 'tpope/vim-repeat'               " Enable repeating plugin commands with .
    Plug 'terryma/vim-multiple-cursors'   " Multiple cursors like in Sublime Text
    Plug 'godlygeek/Tabular', { 'on': 'Tabularize' }                  " Align text operations
    nnoremap <Leader>tb   :Tabularize /
    xnoremap <Leader>tb   :Tabularize /
    nnoremap <Leader>tbox :Tabularize /*<Return>vip<Esc>:substitute/ /=/g<Return>r A/<Esc>vipo<Esc>0r/:substitute/ /=/g<Return>:nohlsearch<Return>

    Plug 'jiangmiao/auto-pairs'           " Auto-close pairs of symbols
    let g:AutoPairs = {
                \ '(' : ')', '[' : ']', '{' : '}',
                \ '"' : '"', "'" : "'", '`' : '`',
                \ '¿' : '?', '¡' : '!'
                \}
    Plug 'tpope/vim-endwise'              " Auto-complete word pairs

    Plug 'KabbAmine/vCoolor.vim', { 'on': 'VCoolor' }                 " Insert RGB color values
    " Recommended: gpick - program for color picking
    nnoremap <Leader>vc :VCoolor<Return>
    Plug 'sedm0784/vim-you-autocorrect', { 'on': ['EnableAutoCorrect', 'DisableAutoCorrect']} " Spell check auto-correction
    " Use :EnableAutoCorrect to turn on auto-correction
    " Use :DisableAutoCorrect to turn it off
    Plug 'scrooloose/nerdcommenter'       " Tools to comment/uncomment code
    Plug 'iamcco/markdown-preview.vim'    " Markdown previewer
endif

if s:use_plugins >= 2
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " File finder
    Plug 'majutsushi/tagbar'              " Tag viewer (requires ctags)
    nnoremap <Leader>tgtb :TagbarToggle<Return>
    nnoremap <F6>         :TagbarToggle<Return>

    Plug 'xolox/vim-misc'                 " Dependency for the following
    Plug 'xolox/vim-easytags'             " Generate and manage tags
    let g:easytags_auto_update = 0
endif
" +++ End Navigation Section +++ }}}

" +++ Text Objects and Operators +++ {{{
if s:use_plugins >= 1
    Plug 't9md/vim-textmanip'
    xmap <Leader>tgtm <Plug>(textmanip-toggle-mode)
    nmap <Leader>tgtm <Plug>(textmanip-toggle-mode)
    " (Optional hooks for text manipulation can be defined here)

    Plug 'easymotion/vim-easymotion'       " Fast movement to characters
    map <Leader>em <Plug>(easymotion-prefix)
    Plug 'michaeljsmith/vim-indent-object' " Indented text object
    Plug 'PeterRincker/vim-argumentative'  " Argument text object
    Plug 'kana/vim-textobj-user'           " Requirement for the following text objects
    Plug 'kana/vim-textobj-function'       " Function text object
    Plug 'kana/vim-textobj-line'           " Line text object
    Plug 'kana/vim-textobj-entire'         " Entire buffer text object
    Plug 'glts/vim-textobj-comment'        " Comment text object
    Plug 'saulaxel/vim-next-object'        " Next element text object
    let g:next_object_prev_letter = 'v'
    let g:next_object_wrap_file = 1

    Plug 'tpope/vim-surround'              " Surround text objects with delimiters
    Plug 'tpope/vim-commentary'            " Comment/uncomment operator
    Plug 'vim-scripts/ReplaceWithRegister' " Operator to replace with register content

    " Visual style and syntax highlighting
    Plug 'rafi/awesome-vim-colorschemes'  " Collection of color schemes
    Plug 'vim-airline/vim-airline'        " Lightweight status line
    if s:use_plugins >= 2
        let g:airline_powerline_fonts = 1
    endif
    let g:airline#extensions#tabline#enabled = 1
    Plug 'vim-airline/vim-airline-themes'  " Themes for vim-airline

    Plug 'Yggdroot/indentLine'             " Visual indentation markers
    Plug 'gregsexton/MatchTag', {'for': ['html', 'xml']}              " Highlight matching HTML/XML tags
    Plug 'ap/vim-css-color', {'for': ['css', 'sass']}                 " Colorize CSS RGB values
    Plug 'sheerun/vim-polyglot'            " Language syntax package
    " Additional language syntaxes can be enabled/disabled here
endif

if s:use_plugins >= 2
    Plug 'ryanoasis/vim-devicons'          " File icons for various filetypes
    if has('mac') || has('win32')
        set guifont=DroidSansMono\ Nerd\ Font:11
    else
        set guifont=DroidSansMono\ Nerd\ Font\ 8
    endif
endif
" +++ End Text Objects Section +++ }}}

if s:use_plugins
    call plug#end()

    if exists('s:plugin_manager_recently_installed')
        PlugInstall
    endif
endif
" ### End Plugins Configuration }}}

" ##### Window Title and Miscellaneous Information ##### {{{
" Set terminal title and show current file, command, etc.
set title             " Use file name as the terminal title

set showcmd           " Show incomplete commands
set showmode          " Display current mode (INSERT, NORMAL, etc.)
set laststatus=2      " Always show the status line
" Status line when plugins are disabled:
set statusline=%f\                          " Filename
set statusline+=[%Y]\                       " File type
set statusline+=\ %{getcwd()}               " Current working directory
set statusline+=%=col:%2c\ line:%2l         " Column and line number

" Command-line completion menu settings
set wildmode=longest,full
set wildmenu          " Visual command-line completion
set wildignore=*.o,*.obj,*.bak,*.exe,*.py[co],*.swp,*~,*.pyc,.svn

" Show absolute line numbers and relative numbers for context
set number            " Global line numbers
set relativenumber    " Relative line numbering
" Toggle relative numbering
nnoremap <Leader>trn :setlocal relativenumber!<Return>
nnoremap <F3>        :setlocal relativenumber!<Return>
set numberwidth=3     " Width for the line number column
set ruler             " Display line and column in the status line

" Text formatting settings
set textwidth=80      " Maximum text width (for formatting, etc.)
set colorcolumn=+1    " Highlight column after textwidth
augroup SpecialFileLengths
    autocmd!
    " For git commit messages, limit text to 72 characters
    autocmd FileType gitcommit setlocal spell textwidth=72
augroup END
" ### End Window Title and Misc Settings }}}

" ##### Syntax, Indentation and Hidden Characters ##### {{{
" +++ General Syntax and Color Settings +++ {{{
syntax on         " Enable syntax highlighting
set synmaxcol=200 " Only highlight first 200 columns

" Enable 256 colors if possible
if (&term =~? 'mlterm\|xterm\|xterm-256\|screen-256') || has('nvim')
    set t_Co=256
endif
let g:current_theme = 'tender'
if s:use_plugins
    if has('vim_starting')
        colorscheme tender
    endif
    let s:color_list = [ '256_noir', 'PaperColor',
        \ 'abstract', 'alduin', 'angr', 'apprentice', 'challenger_deep',
        \ 'deus', 'gruvbox', 'gotham256', 'hybrid', 'hybrid_material',
        \ 'jellybeans', 'lightning', 'lucid', 'lucius', 'materialbox',
        \ 'meta5', 'minimalist', 'molokai', 'molokayo', 'nord', 'one',
        \ 'onedark', 'paramount', 'rdark-terminal2', 'scheakur',
        \ 'seoul256-light', 'sierra', 'tender', 'two-firewatch' ]

    let s:current_position = index(s:color_list, g:current_theme)

    nnoremap <leader>cr :call RotateColorScheme()<Return>
    function! RotateColorScheme()
        let s:current_position = (s:current_position + 1) % len(s:color_list)
        let g:current_theme = s:color_list[s:current_position]
        execute 'colorscheme ' . g:current_theme

        for l:color in ['two-firewatch', 'lucid', 'paramount']
            if l:color ==# s:color_list[s:current_position]
                set background=dark
            endif
        endfor
        for l:color in ['256_noir']
            if l:color ==# s:color_list[s:current_position]
                set background=light
            endif
        endfor
        call ApplyCustomColors(g:current_theme)
    endfunction
else
    " Fallback background setting
    "set background=dark
    colorscheme desert
endif

" When changing the theme, some custom colors get reset.
" This function sets custom colors for the 'tender' theme.
function! ApplyCustomColors(theme)
    if a:theme ==# 'tender'
        highlight SpellBad guibg=NONE guifg=#f43753 ctermbg=NONE ctermfg=203
        highlight SpellCap guibg=NONE guifg=#9faa00 ctermbg=NONE ctermfg=142
        highlight SpellRare guibg=NONE guifg=#d3b987 ctermbg=NONE ctermfg=180
        highlight SpellLocal guibg=NONE guifg=#ffc24b ctermbg=NONE ctermfg=215
        highlight ColorColumn guifg=NONE ctermfg=NONE guibg=#000000 ctermbg=0 gui=NONE cterm=NONE
        highlight CursorColumn guifg=NONE ctermfg=NONE guibg=#000000 ctermbg=0 gui=NONE cterm=NONE
        highlight CursorLine guifg=NONE ctermfg=NONE guibg=#000000 ctermbg=0 gui=NONE cterm=NONE
        highlight LineNr guifg=#b3deef ctermfg=153 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
        highlight Comment guifg=#c9d05c ctermfg=185 guibg=NONE ctermbg=NONE gui=NONE cterm=NONE
        highlight FoldColumn guifg=#ffffff ctermfg=15 guibg=#202020 ctermbg=234 gui=NONE cterm=NONE
    endif
endfunction
call ApplyCustomColors(g:current_theme)

" Show invisible characters based on 'listchars' settings
set list " Enable display of invisible characters
if has('multi_byte') && &encoding ==# 'utf-8'
    set listchars=tab:»·,trail:·,extends:❯,precedes:❮
else
    set listchars=tab:>·,trail:·,extends:>,precedes:<
endif
if has('conceal')
    set conceallevel=2   " Conceal text that has conceal property
    set concealcursor=   " Always disable conceal for the current line
endif
"   +++ End General Syntax Section +++ }}}

" +++ Element Highlighting +++ {{{
" Highlight the current line and column
set cursorline
set cursorcolumn

" Create a highlight group for extra trailing spaces
highlight ExtraTrailingSpaces ctermbg=172 guifg=#D78700
" Match trailing whitespace with the highlight group
match ExtraTrailingSpaces /\s\+$/

" Highlight merge conflict markers (e.g., Git conflicts)
highlight Conflict ctermbg=1 guifg=#FF2233
2match Conflict /\v^(\<|\=|\>){7}([^=].+)?$/
"   +++ End Highlighting Section +++ }}}

" +++ Indentation and Tabs +++ {{{
function! ChangeIndentation(spaces, ...)
    " Change three options with one function call.
    " Example usage:
    "    :call ChangeIndentation(8)<Return>
    " To reindent the entire file, pass an extra argument:
    "    :call ChangeIndentation(8, 'reindent')<Return>
    let &tabstop     = a:spaces
    let &shiftwidth  = a:spaces
    let &softtabstop = a:spaces

    " Reindent the existing code if extra argument provided
    if len(a:000)
        execute "normal! gg=G\<C-o>\<C-o>"
    endif
endfunction
call ChangeIndentation(4)  " Set number of spaces per tab

" Other indentation settings:
set expandtab     " Use spaces instead of literal tab characters
set autoindent    " Copy indent from current line when starting a new line
set smartindent   " Intelligent auto-indentation
set shiftround    " Round indent to a multiple of 'shiftwidth'
set smarttab      " Use 'shiftwidth' for tab operations
if has('patch-8.1.1564') || has('nvim-0.4.0')
    set signcolumn=number
endif
"   +++ End Indentation Section +++ }}}
" ### End Syntax, Indentation and Invisibles }}}

" ##### Windows, Buffers and Navigation ##### {{{
" +++ General Window Settings +++ {{{
set scrolloff=2               " Minimal number of context lines above/below cursor
set sidescrolloff=5           " Minimal number of context columns on the sides
"set scrolljump=3             " Number of lines to jump when scrolling off-screen
set virtualedit=block,onemore " Allow cursor to move past end-of-line in block mode

" Settings for long lines
if s:wrap_long_lines
    set wrap              " Wrap long lines
    set linebreak         " Break lines at convenient points
    set display+=lastline " Show as much as possible of the last line
    set showbreak=...\    " Display '...' at wrapped line start
    if exists('+breakindent')
        set breakindent   " Indent wrapped lines
    endif
else
    set nowrap            " Do not wrap long lines

    " Easy horizontal navigation with custom mappings
    noremap zl zL
    noremap zh zH
endif

" Allow cursor to wrap between lines when using arrow keys and backspace
set whichwrap=b,s,h,l,<,>,[,]
"   +++ End General Window Settings +++ }}}

" +++ Splitting Windows +++ {{{
" Direction for new splits
set splitright  " Vertical splits open to the right
set splitbelow  " Horizontal splits open below
set diffopt+=vertical " Use vertical layout for diff mode
" Use :wincmd for window commands

" Mappings to open and close windows (splits)
nnoremap <Leader>wo :<C-u>only<Return>
nnoremap <Leader>wh :<C-u>hide<Return>
nnoremap \|   :<C-u>vsplit<Space>
nnoremap \|\| :<C-u>vsplit<Return>
nnoremap _    :<C-u>split<Space>
nnoremap __   :<C-u>split<Return>
" :ball - Turn all buffers into windows
" :new - Create a new vertical empty window
" :vnew - Create a new horizontal empty window

" Mappings for navigating between windows
" <C-h> - Left window
" <C-l> - Right window
" <C-k> - Top window
" <C-j> - Bottom window
" <C-w>t - First window
" <C-w>b - Last window
" <C-w>w - Next window
" <C-w>W - Previous window

" Mappings for rearranging windows
" <C-w>H - Move current window to far left
" <C-w>L - Move current window to far right
" <C-w>K - Move current window to top
" <C-w>J - Move current window to bottom
" <C-w>r - Rotate windows clockwise
" <C-w>R - Rotate windows counter-clockwise
" <C-w>x - Exchange current window with next

" Resize windows with custom mappings
nnoremap <C-w>- :<C-u>call RepeatWindowResize('-', v:count)<Return>
nnoremap <C-w>+ :<C-u>call RepeatWindowResize('+', v:count)<Return>
nnoremap <C-w>< :<C-u>call RepeatWindowResize('<', v:count)<Return>
nnoremap <C-w>> :<C-u>call RepeatWindowResize('>', v:count)<Return>
" <C-w>= - Equalize window sizes
" <C-w>_ - Set window to maximum height by default

function! RepeatWindowResize(initial, count)
    let l:key = a:initial
    let l:cnt = a:count ? a:count : 0
    while stridx('+-><', l:key) != -1 || l:key =~# '\d'
        if l:key =~# '\d'
            let l:cnt = l:cnt * 10 + l:key
        else
            execute l:cnt . 'wincmd ' . l:key
            let l:cnt = 0
            redraw
        endif
        let l:key = nr2char(getchar())
    endwhile
endfunction

" Toggle diff mode on all open windows
nnoremap <Leader>tdm :call ToggleDiffMode()<Return>
nnoremap <F4> :call ToggleDiffMode()<Return>
let s:diffModeActive = 0
function! ToggleDiffMode()
    if s:diffModeActive
        windo diffoff
        let s:diffModeActive = 0
    else
        windo diffthis
        let s:diffModeActive = 1
    endif
endfunction

" Compare unsaved changes with the original file
nnoremap <Leader>do :DiffOriginal<Return>
command! DiffOriginal vert new | set buftype=nofile | read ++edit # | 0d_
            \ | diffthis | wincmd p | diffthis

" Use vim -d <file1> <file2> to open files in diff mode

" Auto-equalize window sizes when the Vim window is resized
augroup WindowSize
    autocmd!
    autocmd VimResized * :wincmd =
augroup end
"   +++ End Splitting Windows +++ }}}

" +++ Tab Pages (Multiple Tabs) +++ {{{
set tabpagemax=15    " Limit to showing 15 tabs
" Use :tabs to list tabs and their contents
" :tabdo to execute a command on all tabs

" Mappings to open/close tabs
nnoremap <Leader>tn :tabnew<Space>
nnoremap <Leader>to :tabonly<Return>
" :tab all - Convert buffers into tabs
" :tabfind - Open a file from 'path'
" <C-w>gf - Open file under cursor in a new tab
" <C-w>T - Convert current window into a tab

" Mappings to navigate between tabs
nnoremap <Leader>th :tabfirst<Return>
nnoremap <Leader>tl :tablast<Return>
nnoremap <Leader>tj :tabprevious<Return>
nnoremap <Leader>tk :tabnext<Return>
" gt - Jump to tab number N

" Mappings to move the current tab
nnoremap <Leader>t- :tabmove -<Return>
nnoremap <Leader>t+ :tabmove +<Return>
nnoremap <Leader>t< :tabmove 0<Return>
nnoremap <Leader>t> :tabmove $<Return>

" A special mode to simplify tab operations
nnoremap <silent> <Leader>tm :<C-u>call TabActionMode()<Return>

function! TabActionMode()
    if tabpagenr('$') == 1
        echomsg 'Tab mode requires more than one tab'
        return
    endif

    echomsg 'Tab mode: use h, l, j, k, +, - or <, > to control tabs; any other key exits'
    let l:key = nr2char(getchar())
    let l:actions = {
                \'h': 'tabfirst',    'l': 'tablast',
                \'j': 'tabprevious', 'k': 'tabnext',
                \'<': 'tabmove 0',   '>': 'tabmove $'
                \}

    while stridx('hljk+-><', l:key) != -1
        if stridx('hljk><', l:key) != -1
            execute l:actions[l:key]
        else
            if (l:key ==# '+' && tabpagenr() != tabpagenr('$'))
                        \ || (l:key ==# '-' && tabpagenr() != 1)
                execute 'tabmove ' . l:key
            endif
        endif
        redraw
        let l:key = nr2char(getchar())
    endwhile
endfunction
"   +++ End Tabs Section +++ }}}

" +++ Buffers +++ {{{
set hidden                       " Allow hidden buffers
set switchbuf=useopen,usetab     " Prefer tabs/windows when switching buffers
" Use :bufdo to execute a command on all buffers

" Mappings to open and switch between buffers
nnoremap <Leader>bn :edit<Space>
" gf - Open file under the cursor in a new buffer
nnoremap <Leader>bg :ls<Return>:buffer<Space>
nnoremap <Leader>bh :bfirst<Return>
nnoremap <Leader>bk :bnext<Return>
nnoremap <Leader>bj :bprevious<Return>
nnoremap <Leader>bl :last<Return>

" Mapping to close a window, buffer, or tab
nnoremap <Leader>bd  :bdelete!<Return>

" Change working directory to the directory of the current buffer
nnoremap <Leader>cd :cd %:p:h<Return>:pwd<Return>
"   +++ End Buffers Section +++ }}}

" +++ Normal Mode Movements +++ {{{
" Move by visual lines instead of logical lines
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> gj j
nnoremap <silent> gk k

" Move to top/middle/bottom of screen similar to Emacs
nnoremap <C-l> :call ToggleScreenPosition()<return>
function! ToggleScreenPosition()
    let l:win_lines = (line('$') <= winheight('%') ? line('$') : winheight('%'))
    let l:current_line = winline()

    normal! zb
    let l:last_line = winline()

    if l:current_line == l:last_line
        normal! zt
    elseif l:current_line != l:win_lines / 2
         \ && l:current_line != l:win_lines / 2 + 1
        normal! z.
    endif

    redraw
endfunction
"   +++ End Normal Mode Movements +++ }}}

" +++ Command-line Mode Movements +++ {{{
cnoremap <C-a> <Home>
" <C-e> moves to the end of the line in command-line mode
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <A-b> <S-Left>
cnoremap <A-f> <S-Right>
cnoremap <C-d> <Del>
cnoremap <A-d> <S-Right><C-w>
cnoremap <A-D> <C-e><C-u>

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

cnoremap <Up>   <C-p>
cnoremap <Down> <C-n>
"   +++ End Command-line Mode Movements +++ }}}

" +++ Folding (Code Blocks) +++ {{{
set foldenable           " Enable code folding
set foldcolumn=1         " Display a column for fold markers
set foldopen-=block      " Do not open folds when using }, ), etc.
set foldnestmax=3        " Maximum fold nesting level
"set foldmethod=indent    " Create folds based on indent level
" Create and remove folds:
" :fold or zf to create a fold
" zd to delete the nearest fold
" zD to delete folds recursively
" zE to delete all folds in the window

" Toggle folds with:
nnoremap <Space>    za
" zO - Open folds recursively at current position
" zC - Close folds recursively at current position
" zR - Open all folds
" zM - Close all folds

" Function to automatically fold functions
nmap <Leader>ff zfaf
nnoremap <Leader>faf :call FoldFunctions()<Return>
function! FoldFunctions()
    set foldmethod=syntax
    set foldnestmax=1
endfunction
"   +++ End Folding Section +++ }}}
" ### End Windows, Buffers and Navigation }}}

" ##### Editing Aids ##### {{{
" +++ General Editing Settings +++ {{{
set backspace=2       " Make backspace work as in other editors
set undolevels=10000  " Allow virtually unlimited undos
set undofile          " Save undo history to file
if !has('nvim')
    if !isdirectory(expand('~/.vim/undo/'))
        call mkdir(expand('~/.vim/undo/'), 'p')
    endif
    set undodir=~/.vim/undo
endif
set undoreload=10000  " Number of changes preserved on reload
set history=1000      " Long command history
set nrformats-=octal  " Disable octal numbers (confusing with decimal)

nnoremap <leader>cf :CocCommand prettier.formatFile<CR>

" Toggle alphanumeric format (numbering letters, etc.)
nnoremap <Leader>taf :call ToggleAlphaFormat()<Return>
function! ToggleAlphaFormat()
    if stridx(&nrformats, 'alpha') == -1
        set nrformats+=alpha  " Enable letter counting
    else
        set nrformats-=alpha  " Disable letter counting
    endif
endfunction

set nojoinspaces      " Do not insert two spaces after punctuation
set lazyredraw        " Redraw only when necessary
set updatetime=500    " Update time in milliseconds
set ttimeout          " Timeout for key codes
set ttimeoutlen=1     " Timeout length for key codes

" Toggle visual mode types using 'v'
xnoremap <expr> v
               \ (mode() ==# 'v' ? 'V' : mode() ==# 'V' ?
               \ "\<C-v>" : 'v')
"   +++ End General Editing Settings +++ }}}

" +++ Copying, Pasting and Moving Text +++ {{{
set nopaste           " 'paste' mode is off by default
"set pastetoggle=<F2>  " Key to toggle paste mode

" Define behavior of the unnamed register (system clipboard support)
if s:use_system_clipboard && has('clipboard')
    if has('unnamedplus') " Use '+' register if available
        set clipboard=unnamed,unnamedplus
    else " On macOS and Windows, use '*' register
        set clipboard=unnamed
    endif
endif

" Mappings for paste operations that respect indentation
nnoremap <Leader>pu ]p
nnoremap <Leader>po [p

" Use the ñ key for registers
nnoremap ñ "
xnoremap ñ "

" Make Y behave like C and D (yank-to-end-of-line)
noremap Y y$

" Map Ctrl-c to copy to the system clipboard
xnoremap <C-c> "+y
nnoremap <C-c> "+yy

" Move visual lines up and down
if !s:use_plugins
    " Duplicate text above and below
    nnoremap <expr> <A-y> "<Esc>yy" . v:count . 'P'
    vnoremap <expr> <A-y> 'y`>' . v:count . 'pgv'
    nnoremap <expr> <A-Y> "<Esc>yy" . v:count . 'gpge'
    vnoremap <expr> <A-Y> 'y`<' . v:count . 'Pgv'

    nnoremap <expr> <A-j> ':<C-u>move +' . CountToMove(0) . "<Return>=="
    vnoremap <expr> <A-j> ":move '>+" . CountToMove(0) . "<Return>gv=gv"
    nnoremap <expr> <A-k> ':<C-u>move -' . CountToMove(1) . "<Return>=="
    vnoremap <expr> <A-k> ":move '<-" . CountToMove(1) . "<Return>gv=gv"

    function! CountToMove(down)
        return (v:count ? v:count : 1) + a:down
    endfunction

    " Move visual blocks left/right
    nnoremap <expr> <A-l> '<Esc>x' . (v:count > 1 ? (v:count - 1) . 'l' : '') . 'p'
    vnoremap <expr> <A-l> 'd' . (v:count > 1 ? (v:count - 1) . 'l' : '') . 'p`[<C-v>`]'
    nnoremap <expr> <A-h> '<Esc>x' . (v:count ? v:count : 1) . 'hP'
    vnoremap <expr> <A-h> 'd' . (v:count ? v:count : 1) . 'hP`[<C-v>`]'
else
    nmap <A-y> <Plug>(textmanip-duplicate-up)
    xmap <A-y> <Plug>(textmanip-duplicate-up)
    nmap <A-Y> <Plug>(textmanip-duplicate-down)
    xmap <A-Y> <Plug>(textmanip-duplicate-down)

    nmap <A-j> V<A-j><Esc>
    xmap <A-j> <Plug>(textmanip-move-down)
    nmap <A-k> V<A-k><Esc>
    xmap <A-k> <Plug>(textmanip-move-up)

    nmap <A-h> v<A-h><Esc>
    xmap <A-h> <Plug>(textmanip-move-left)
    nmap <A-l> v<A-l><Esc>
    xmap <A-l> <Plug>(textmanip-move-right)

    xmap <Up>     <Plug>(textmanip-move-up-r)
    xmap <Down>   <Plug>(textmanip-move-down-r)
    xmap <Left>   <Plug>(textmanip-move-left-r)
    xmap <Right>  <Plug>(textmanip-move-right-r)
endif

" Keep visual mode after indenting left/right
xnoremap < <gv
xnoremap > >gv
"   +++ End Copy/Paste Section +++ }}}

" +++ Common Text Modification Operations +++ {{{
if exists('+formatoptions')
    set formatoptions+=j " Remove comment character when joining lines
    set formatoptions+=l " Break long lines automatically
endif

" Quick exit to normal mode from insert mode
inoremap kj <Esc>

" Select previously inserted text
nnoremap gV `[v`]
" Select previously pasted text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
" gv - Reselect previous visual selection

" In visual block mode, select non-empty column upward/downward
xnoremap <leader><C-v>k :<C-u>call <SID>SelectColumn('up')<CR>
xnoremap <leader><C-v>j :<C-u>call <SID>SelectColumn('down')<CR>
xnoremap <leader><C-v>a :<C-u>call <SID>SelectColumn('both')<CR>

function! s:SelectColumn(direction)
    normal! gv

    let [l:_, l:line_num, l:col, l:_, l:_] = getcurpos()
    let l:swapped_position = 0
    if line("'>") == l:line_num && col("'>") == l:col
        normal! o
        let l:swapped_position = 1
    endif

    if a:direction ==# 'up' || a:direction ==# 'both'
        while match(getline(line('.') - 1)[l:col - 1], '\_S') != -1
            normal! k
        endwhile
    endif

    normal! o
    if a:direction ==# 'down' || a:direction ==# 'both'
        while match(getline(line('.') + 1)[l:col - 1], '\_S') != -1
            normal! j
        endwhile
    endif

    if !l:swapped_position
        normal! o
    endif
endfunction

" Delete text forward with commands based on D
inoremap <C-d> <Del>
inoremap <expr> <A-d> '<Esc>' . (col('.') == 1 ? "" : "l") . 'dwi'
inoremap <expr> <A-D> '<Esc>' . (col('.') == 1 ? "" : "l") . 'C'

" Exit insert mode and delete the current line
inoremap <A-k><A-j> <Esc>ddkk
inoremap <A-j><A-k> <Esc>ddj

" Insert an empty line above or below
nnoremap <A-o> :call append(line('.'), '')<Return>
nnoremap <A-O> :call append(line('.')-1, '')<Return>

" Emulate Vim-surround for wrapping text (if plugins are disabled)
if !s:use_plugins
    nnoremap ysiw   :call WrapWord()<Return>
    xnoremap S <Esc>:call WrapSelection()<Return>
    function! WrapWord()
        let l:char_read = nr2char(getchar())
        let [l:open_char, l:close_char] = GetMatchingChars(l:char_read)

        execute "normal! viw\<Esc>a" . l:close_char . "\<Esc>" . "hviwo\<Esc>i" . l:open_char . "\<Esc>lel"
    endfunction

    function! WrapSelection()
        let l:char_read = nr2char(getchar())
        let [l:open_char, l:close_char] = GetMatchingChars(l:char_read)

        execute 'normal! `>a' . l:close_char . "\<Esc>" . '`<i' . l:open_char . "\<Esc>"
    endfunction
endif

function! GetMatchingChars(char)
    if a:char ==# '(' || a:char ==# ')'
        let [l:initial, l:final] = ['(', ')']
    elseif a:char ==# '{' || a:char ==# '}'
        let [l:initial, l:final] = ['{', '}']
    elseif a:char ==# '<' || a:char ==# '>'
        let [l:initial, l:final] = ['<', '>']
    else
        let [l:final, l:initial] = [a:char, a:char]
    endif
    return [l:initial, l:final]
endfunction

" Alignment (a replacement for Tabularize if plugins are disabled)
command! -nargs=1 -range Align '<,'>call AlignText(<f-args>)

xnoremap <Leader>al :Align<Space>
nnoremap <Leader>al vip:Align<Space>

function! AlignText(pattern) range
    let l:start_col = min([virtcol("'<"), virtcol("'>")])
    let l:save_cursor = getpos('.')
    let l:max_col = s:MaxColumn(a:pattern, a:firstline, a:lastline, l:start_col)

    for l:line in range(a:lastline - a:firstline + 1)
        call cursor(a:firstline + l:line, l:start_col)
        if search(a:pattern, 'c', line('.')) != 0
            let l:delta = (l:max_col - col('.'))
            if l:delta > 0
                execute 'normal! ' . l:delta . 'i '
            endif
        endif
    endfor

    call setpos('.', l:save_cursor)
endfunction

function! s:MaxColumn(pattern, start_line, end_line, col)
    let l:max_col = 0
    for l:line in range(a:end_line - a:start_line + 1)
        call cursor(a:start_line + l:line, a:col)
        call search(a:pattern, 'c', line('.'))
        let l:current = col('.')
        if l:current > l:max_col
            let l:max_col = l:current
        endif
    endfor
    return l:max_col
endfunction

" Commenting (a simple replacement for vim-commentary if plugins are disabled)
if !s:use_plugins
    let b:comment_start = '//'
    augroup DetectCommentStart
        autocmd FileType py,sh   let b:comment_start = '#'
        autocmd FileType fortran let b:comment_start = '!'
        autocmd FileType vim     let b:comment_start = '"'
    augroup END

    nnoremap gc :set operatorfunc=CommentOperator<Return>g@
    xnoremap gc :<C-u>call CommentOperator(visualmode(), 1)<Return>

    function! CommentOperator(mode, ...)
        let l:start_mark = (a:0 ? "'<" : "'[")
        let l:end_mark  = (a:0 ? "'>" : "']")
        let l:first_line = getline(line(l:start_mark))
        let l:range = l:start_mark . ',' . l:end_mark
        if l:first_line =~# '^\s*' . b:comment_start
            execute l:range . 's/\v(^\s*)' . escape(b:comment_start, '\/') . '\v\s*/\1/e'
        else
            execute l:range . 's/^\s*/&' . escape(b:comment_start, '\/') . ' /e'
        endif
        execute 'normal! ' . l:start_mark
    endfunction
endif

" Variable extraction: extract a variable from the word under the cursor
nnoremap <Leader>ve viw:call ExtractVariable()<Return>
xnoremap <Leader>ve :call ExtractVariable()<Return>
function! ExtractVariable()
    let l:type = input('Variable type: ')
    let l:name = input('Variable name: ')

    if (visualmode() ==# '')
        normal! viw
    else
        normal! gv
    endif

    exec 'normal! c' . l:name
    let l:selection = @"
    exec 'normal! O' . l:type . ' ' . l:name . ' = '
    exec 'normal! pa;'
    call feedkeys(':.+1,$s/\V\C' . escape(l:selection, '/\') . '/' . escape(l:name, '/\') . "/gec\<cr>")
endfunction

" Insert a closing brace or parenthesis even if autopairs is active
inoremap <Leader>} <Space><Esc>r}==
nnoremap <Leader>} A<Space><Esc>r}==
inoremap <Leader>) <Space><Esc>r)a
nnoremap <Leader>) i<Space><Esc>r)

" Clear command-line except for the command itself
cnoremap <A-w> <C-\>esplit(getcmdline(), " ")[0]<return><space>
cmap <A-BS> <A-BS>

" Increase undo granularity
inoremap <C-u> <C-g>u<C-u>
inoremap <Return> <C-g>u<Return>
"   +++ End Modification Operations +++ }}}

" +++ Text Objects (if plugins are disabled) +++ {{{
if !s:use_plugins
    " 'line' text object
    xnoremap il g_o^
    onoremap il :<C-u>normal vil<Return>
    xnoremap al $o0
    onoremap al :<C-u>normal val<Return>

    " 'entire buffer' text object
    xnoremap i% GoggV
    onoremap i% :<C-u>normal vi%<Return>
    xnoremap a% GoggV
    onoremap a% :<C-u>normal vi%<Return>
endif
"   +++ End Text Objects +++ }}}
" ### End Editing Aids }}}

" ##### Search and Replace ##### {{{
" +++ General Search Settings +++ {{{
set wrapscan           " Searches wrap around the file
set incsearch          " Incremental search
if exists('+inccommand')
    set inccommand=nosplit " Incremental substitution preview
endif
set ignorecase         " Case-insensitive search
set smartcase          " Smart case: case-sensitive if any uppercase letter is used
set hlsearch           " Highlight search matches
set magic              " Use 'magic' mode for patterns
set gdefault           " Global flag is default for substitutions

" Mappings to disable search highlighting
nnoremap // :nohlsearch<Return>
nnoremap <Leader>hsc :nohlsearch<bar>let @/ = ''<Return>
"   +++ End General Search Settings +++ }}}

" +++ Search and Replace Enhancements +++ {{{
" Make the dot command (repeat) work in visual mode
xnoremap . :normal .<Return>

" Repeat last substitution with all flags
nnoremap & :&&<Return>
xnoremap & :&&<Return>

" Repeat the last command-line command
nnoremap Q @:
xnoremap Q @:

" Prevent moving when using * and #
nnoremap * *N
nnoremap # #N

" In visual mode, use * and # to search for the selected text instead of the current word
xnoremap * :<C-u>call VisualSelectionSearch()<Return>/<C-R>=@/<Return><Return>N
xnoremap # :<C-u>call VisualSelectionSearch()<Return>?<C-R>=@/<Return><Return>N

function! VisualSelectionSearch() range
    let l:saved_reg = @"
    execute 'normal! vgvy'
    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", '', '')
    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

" Center the line with the found match
nnoremap n nzzzv
nnoremap N Nzzzv
"   +++ End Search Enhancements +++ }}}

" +++ New Mappings for Search/Replace +++ {{{
" Search a word and store results in the location list
nnoremap <Leader>gg  :lvimgrep<Space>
nnoremap <Leader>gcw :lvimgrep<Space><C-r><C-w><Space>
nnoremap <Leader>gcd :lvimgrep<Space><Space>./*<Left><Left><Left><Left>
nnoremap <Leader>gwd :lvimgrep<Space><C-r><C-w><Space>./*<Return>

" Search text in all open buffers
command! -nargs=1 SearchBuffers call SearchBuffers(<q-args>)
nnoremap <Leader>gob :SearchBuffers<Space>

function! SearchBuffers(pattern)
    let l:files = map(filter(range(1, bufnr('$')), 'buflisted(v:val)'),
                \ 'fnameescape(bufname(v:val))')
    try
        silent noautocmd execute 'lvimgrep /' . a:pattern . '/gj ' . join(l:files)
    catch /^Vim\%((\a\+)\)\=:E480/
        echomsg 'No matches found'
    endtry
    lwindow
endfunction

" Open the location window to view grep results
nnoremap <Leader>gsr :lopen<Return>

" Replace text (local, global, or in the current range)
if !s:use_plugins
    " Remember: 'gdefault' is on; an extra g at the end disables it
    nnoremap <Leader>ss :s/
    xnoremap <Leader>ss :s/
    nnoremap <Leader>se :%s/
    xnoremap <Leader>se :<C-u>call VisualSelectionSearch()<Return>:%s/<C-r>=@/<Return>/
    nnoremap <Leader>sw :%s/\<<C-r><C-w>\>\C/
    nnoremap <Leader>sW :%s/\<<C-r>=expand("<cWORD>")<Return>\>\C/
    xnoremap <Leader>sx :<C-u>call VisualSelectionSearch()<Return>:s/<C-r>=@/<Return>/
endif

" Jump to merge conflict markers
nnoremap <silent> <Leader>ml /\v^(\<\|\=\|\>){7}([^=].+)?$<Return>
nnoremap <silent> <Leader>mh ?\v^(\<\|\=\|\>){7}([^=].+)\?$<Return>
"   +++ End New Search Mappings +++ }}}
" ### End Search and Replace }}}

" ##### Saving, Exiting and Returning to Vim ##### {{{
set fileformats=unix,dos,mac " Recognize various newline formats
set autowrite         " Auto-write when switching buffers, etc.
set autoread          " Auto-read file if changed externally

" +++ Backups and Crash Recovery +++ {{{
if s:use_local_backup
    set backup            " Enable backups
    set backupcopy=yes
    set backupdir=~/.vim/backup,~/tmp/,/var/tmp,/tmp
    if !isdirectory(expand('~/.vim/backup/'))
        call mkdir(expand('~/.vim/backup/'), 'p')
    endif
    set swapfile          " Enable swap files
    set directory=~/tmp,/var/tmp,/tmp
else
    set nobackup          " No backups
    set nowritebackup     " Do not keep write backup
    set noswapfile        " Do not use a swap file for the current buffer
endif

" Create a session with a specific name or default name
set sessionoptions-=options
set sessionoptions+=localoptions
set sessionoptions+=unix,slash
nnoremap <Leader>ms  :mksession! ~/.vim/session/<Return>
nnoremap <Leader>mds :mksession! ~/.vim/session/default<Return>
nnoremap <Leader>cs  :source ~/.vim/session/<Return>
nnoremap <Leader>cfs :source ~/.vim/session/default<Return>
" To start Vim with a session: vim -S <session_file>

if !isdirectory(expand('~/.vim/session/'))
    call mkdir(expand('~/.vim/session/'), 'p')
endif
"   +++ End Backups and Crash Recovery +++ }}}

" +++ Automatic Commands for Save/Reload/Exit +++ {{{
" Mappings to exit Vim from normal mode
nnoremap ZG :xa<Return>
nnoremap ZA :quitall!<Return>
" ZQ - Close the current window without saving
" ZZ - Save and close the current window

" Define alternative commands for saving with uppercase commands
command! -bang -nargs=* -complete=file E  e<bang> <args>
command! -bang -nargs=* -complete=file W  w<bang> <args>
command! -bang -nargs=* -complete=file Wq wq<bang> <args>
command! -bang -nargs=* -complete=file WQ wq<bang> <args>
command! -bang -nargs=* -complete=file Wa wa<bang>
command! -bang -nargs=* -complete=file WA wa<bang>
command! -bang -nargs=* -complete=file Q q<bang>
command! -bang -nargs=* -complete=file Qa qa<bang>
command! -bang -nargs=* -complete=file QA qa<bang>
command! -bang -nargs=* -complete=file Wqa wqa<bang>
command! -bang -nargs=* -complete=file WQa wqa<bang>
command! -bang -nargs=* -complete=file WQA wqa<bang>
command! -bang -nargs=* -complete=file Xa xa<bang>
command! -bang -nargs=* -complete=file XA xa<bang>

" Map Ctrl-s to save like in most editors
nnoremap <C-s> :update<Return>
inoremap <C-s> <Esc>:update<Return>a

" Save with sudo (if started without sudo, will ask for password)
cnoremap w!! w !sudo tee % > /dev/null<Return>

augroup AutoSaveReload
    autocmd!
    " Remove trailing whitespace on save
    autocmd BufWritePre * :%s/\s\+$//e

    " Open file at last edit position on load (if plugins are disabled)
    if !s:use_plugins
        autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$")
                    \ | execute "normal! g`\"" | endif
    endif

    " Reload the configuration when the config file is saved
    autocmd BufWritePost $MYVIMRC source $MYVIMRC

    autocmd QuitPre .exrc call ApplyConfiguration()

    " If editing a file in a non-existent directory, create the directory
    autocmd BufNewFile * call CreateDirIfNotExist()
augroup END

function! CreateDirIfNotExist()
    let l:required_dir = expand('%:h')
    if !isdirectory(l:required_dir)
        let l:answer = confirm('Directory ' . l:required_dir
                    \ . ' does not exist. Create it?',
                    \   "&Yes\n&No", 1)
        if l:answer != 1
            return
        endif
        try
            call mkdir(l:required_dir, 'p')
        catch
            echoerr 'Could not create ' . l:required_dir
        endtry
    endif
endfunction
"   +++ End Save/Reload/Exit Commands +++ }}}

" +++ Configuration for Large Files +++ {{{
augroup LargeFile
    let s:LARGE_SIZE = 10 * 1024 * 1024
    autocmd!
    autocmd BufReadPre * let s:file_size = getfsize(expand("<afile>"))
                \ | if s:file_size > s:LARGE_SIZE || s:file_size == -2
                \ |     call LargeFileSettings()
                \ | endif
augroup END

function! LargeFileSettings()
    " This function is called when the file exceeds 10MB
    syntax off
    set eventignore+=FileType  " Disable filetype-dependent features
    setlocal bufhidden=unload  " Unload buffer when not in use to save memory
    setlocal undolevels=-1     " Disable undo history
    setlocal nospell           " Disable spell checking
endfunction
"   +++ End Large File Settings +++ }}}
" ### End Saving, Exiting and Reloading }}}

" ##### Compilation, Error Checking and Language Specific Settings ##### {{{
" +++ Compilation and Execution Commands +++ {{{
let g:compile_options = {}
let g:compile_options['files'] = '%'
let g:compile_options['executable_name'] = '%:t:r'
let g:compile_options['c'] = {
            \ 'compiler': 'gcc',
            \ 'flags': '-std=gnu11 -Wall -Wextra -Wno-missing-field-initializers -Wstrict-prototypes',
            \ 'output': '-o'
            \}
let g:compile_options['cpp'] = {
            \ 'compiler': 'g++',
            \ 'flags': '-std=c++14 -Wall -Wextra',
            \ 'output': '-o'
            \}
let g:compile_options['fortran'] = {
            \ 'compiler': 'gfortran',
            \ 'flags': '-Wall -Wextra',
            \ 'output': '-o'
            \}
let g:compile_options['java'] = {
            \ 'compiler': 'javac',
            \ 'flags': '',
            \ 'output': ''
            \}
let g:compile_options['cs'] = {
            \ 'compiler': 'mcs',
            \ 'flags': '',
            \ 'output': ''
            \}
let g:compile_options['haskell'] = {
            \ 'compiler': 'ghc',
            \ 'flags': '-dynamic',
            \ 'output': ''
            \}
" For interpreted languages like python, bash, ruby, we perform code checking
let g:compile_options['python'] = {
            \ 'compiler': 'flake8',
            \ 'flags': '',
            \ 'output': ''
            \}
let g:compile_options['sh'] = {
            \ 'compiler': 'bash -n',
            \ 'flags': '',
            \ 'output': ''
            \}
let g:compile_command = {}
function! UpdateCompileCommands()
    let l:dict = {}
    for l:el in items(g:compile_options)
        let l:opt = l:el[1]
        if !exists('g:use_custom_make') || g:use_custom_make == 0
            let l:dict[l:el[0]] = l:opt['compiler'] . ' '
            let l:dict[l:el[0]] .= l:opt['output'] . ' '
            if (!empty(l:opt['output']))
                let l:dict[l:el[0]] .= g:compile_options['executable_name'] . ' '
            endif
            let l:dict[l:el[0]] .= g:compile_options['files'] . ' '
            let l:dict[l:el[0]] .= l:opt['flags']
            let g:compile_command[l:el[0]] = l:dict[l:el[0]]
        else
            let g:compile_command[l:el[0]] = 'make'
        endif
    endfor
endfunction
call UpdateCompileCommands()

function! GenerateLocalConfig()
    if &filetype ==# ''
        let g:file_language = input('Enter the language: ')
    else
        let g:file_language = &filetype
    endif

    if filereadable(expand('~/.vimtags'))
        silent !rm ~/.vimtags
    endif

    if filereadable('./.exrc')
        tabnew .exrc
        return
    endif

    let l:lines = [
            \ '" Local Vim settings:',
            \ 'scriptencoding utf-8',
            \ 'call ChangeIndentation(4) " 4 spaces per tab',
            \ '',
            \ '" Compiler settings:',
            \ "let g:compile_options.files = '" . expand('%') . "'",
            \ "let g:compile_options.executable_name = '" . expand('%:t:r') . "'",
            \ "let g:compile_options['" . g:file_language . "'] = {" ]
    if has_key(g:compile_options, g:file_language)
        let l:opts = g:compile_options[g:file_language]
        let l:lines += [
                \ "\\ 'compiler': '" . l:opts.compiler . "',",
                \ "\\ 'flags': '" . l:opts.flags . "',",
                \ "\\ 'output': '" . l:opts.output . "'" ]
    else
        let l:lines += [
                \ "\\ 'compiler': '',",
                \ "\\ 'flags': '',",
                \ "\\ 'output': ''" ]
    endif

    let l:lines += [
            \ '\}',
            \ '',
            \ 'let g:use_custom_make = 0',
            \ 'call UpdateCompileCommands()' ]

    tabnew .exrc
    call append(0, l:lines)
    normal! gg=G
endfunction

function! ApplyConfiguration()
    update
    tabprevious
    source .exrc
    let &makeprg = g:compile_command['c']
    tabnext
endfunction

augroup make_commands " Define :make for various filetypes
    autocmd!
    autocmd FileType c       let &l:makeprg = g:compile_command['c']
    autocmd FileType cpp     let &l:makeprg = g:compile_command['cpp']
    autocmd FileType fortran let &l:makeprg = g:compile_command['fortran']
    autocmd FileType java    let &l:makeprg = g:compile_command['java']
    autocmd FileType python  let &l:makeprg = g:compile_command['python']
    autocmd FileType cs      let &l:makeprg = g:compile_command['cs']
    autocmd FileType sh      let &l:makeprg = g:compile_command['sh']
    autocmd FileType haskell let &l:makeprg = g:compile_command['haskell']
augroup END

" Map F9 to compile and run if there are no errors
nnoremap <F9> :call ExecuteIfNoErrors()<Return>

function! ExecuteIfNoErrors()
    if g:use_custom_make || &makeprg !=# 'make'
        make
    endif

    if len(getqflist()) ==# 0
        " If no errors, execute the program
        if ( &filetype ==# 'c' ||
                    \ &filetype ==# 'cpp' ||
                    \ &filetype ==# 'haskell' ||
                    \ &filetype ==# 'fortran')
            execute '!./' . g:compile_options['executable_name']
        elseif (&filetype ==# 'java')
            execute '!./' . g:compile_options['executable_name']
        elseif (&filetype ==# 'python')
            !python3 %
        elseif (&filetype ==# 'sh')
            !bash %
        elseif (&filetype ==# 'html')
            !xdg-open %
        endif
    else
        " If errors exist, open the quickfix window
        copen
        setlocal nospell
    endif
endfunction
"   +++ End Compilation Commands +++ }}}

" +++ Code Linting Settings +++ {{{
if s:use_plugins >= 2 && (has('nvim') || (v:version >= 800))
    let g:ale_set_quickfix = 1
    let g:ale_cpp_clangcheck_options = "-extra-arg='" . g:compile_options['cpp'].flags
    let g:ale_cpp_gcc_options = g:compile_options['cpp'].flags
    let g:ale_cpp_clang_options = g:compile_options['cpp'].flags
    let g:ale_cpp_clangtidy_options = g:compile_options['cpp'].flags
    let g:ale_c_gcc_options = g:compile_options['c'].flags
    let g:ale_c_clang_options = g:compile_options['c'].flags
    let g:ale_c_clangtidy_options = g:compile_options['c'].flags
    let g:ale_c_clangtidy_checks = ['*', '-readability-braces-around-statements',
                \'-google-readability-braces-around-statements', '-llvm-header-guard']
    let g:ale_haskell_ghc_options = g:compile_options['haskell'].flags
    let g:ale_fortran_gcc_options = g:compile_options['fortran'].flags
elseif s:use_plugins
    let g:syntastic_cpp_compiler_options = g:compile_options['cpp'].flags
    let g:syntastic_c_compiler_options = g:compile_options['c'].flags
    let g:syntastic_haskell_compiler_options = g:compile_options['haskell'].flags
    let g:syntastic_fotran_compiler_options = g:compile_options['fortran'].flags
endif
"   +++ End Code Linting Settings +++ }}}

" +++ File Type Detection and Local Configurations +++ {{{
augroup LanguageDetection
    autocmd!
    autocmd BufNewFile,BufRead *.nasm setlocal filetype=nasm
    autocmd BufNewFile,BufRead *.jade setlocal filetype=pug
    autocmd BufNewFile,BufRead *.h    setlocal filetype=c
augroup END

augroup LanguageSpecificSettings
    autocmd!
    " For HTML/CSS/SCSS/SASS/PUG/PHO, add '-' to iskeyword (for CSS identifiers)
    autocmd FileType html,css,scss,sass,pug     setlocal iskeyword+=-
    if s:use_plugins >= 1
        autocmd FileType html,xml,jade,pug,htmldjango,css,scss,sass,php imap <buffer> <expr> <Tab> emmet#expandAbbrIntelligent("\<Tab>")
    endif
augroup END

" Toggle between help and text files
nnoremap <leader>tth :call ToggleHelpAndText()<Return>
function! ToggleHelpAndText()
    let &filetype = (&filetype ==# 'help' ? 'text' : 'help')
endfunction

augroup CommandKConfig
    autocmd!
    " By default, the :Man command uses the system man; override for Vim help
    autocmd FileType vim,help setlocal keywordprg=:help
    " For C++ help, ensure cppman is installed and map K appropriately
    autocmd FileType cpp nnoremap <buffer> K yiw:sp<CR>:terminal<CR>Acppman <C-\><C-n>pA<CR>
augroup end
"   +++ End Language Specific Configurations +++ }}}
" ### End Compilation, Linting and Language Settings }}}

" ##### Editing and Evaluating the Configuration ##### {{{
" Open and edit the main configuration file and the plugins file
nnoremap <Leader>av :edit $MYVIMRC<Return>
nnoremap <Leader>sv :source $MYVIMRC<Return>

" Evaluate an external shell command (EValuate Shell)
nnoremap <Leader>evs !!$SHELL<Return>
xnoremap <Leader>evs !$SHELL<Return>

" Terminal emulator configurations
if has('nvim')
    " Open a terminal emulator split (open terminal)
    nnoremap <Leader>ot :5sp<bar>te<CR>:setlocal nospell nonu<Return>A
    " Exit terminal emulator to normal mode
    tnoremap <Esc> <C-\><C-n>
elseif has('terminal')
    nnoremap <Leader>ot :terminal<Return>
    tnoremap <Esc> <C-\><C-n>
endif

" Evaluate a normal-mode command with <Leader>evn
nnoremap <Leader>evn ^vg_y@"
xnoremap <Leader>evn y@"

" Evaluate a VimL command (command-line mode) with <Leader>evv
nnoremap <silent> <Leader>evv :execute getline(".")<Return>
xnoremap <silent> <Leader>evv :<C-u>
            \       for l:line in getline("'<", "'>")
            \ <bar>     execute l:line
            \ <bar> endfor
            \ <Return>

" Paste output of a Vim command into a new buffer.
" Usage: SalidaBuffer {normal-command}
command! -nargs=* -complete=command OutputToBuffer call OutputToBuffer(<q-args>)
function! OutputToBuffer(cmd)
    redir => l:output
    silent exe a:cmd
    redir END
    new
    setlocal nonumber
    call setline(1, split(l:output, "\n"))
    setlocal nomodified
endfunction

" List all active mappings
function! ShowActiveMappings()
    let l:options = "Normal mode mappings\n"
                 \ . "Insert mode mappings\n"
                 \ . "Visual mode mappings\n"
                 \ . "All mappings\n"
    let l:answer = confirm('Which type of mappings do you want to list?',
                            \ l:options, 4)
    if l:answer == 0
        return
    elseif l:answer == 1
        nmap
    elseif l:answer == 2
        imap
    elseif l:answer == 3
        vmap
    else
        map
    endif
endfunction
" ### End Editing and Evaluation Configurations }}}

" ##### Code Completion, Tag Generation, Dictionaries and Spell Checking ##### {{{
if s:use_plugins
    set complete-=i        " Let plugins handle completion
    set complete-=t
else
    set complete+=i        " Complete words from included files
endif

" Generate tags for definitions and 'go to definition' command
set tags=./tags;/,~/.vimtags
if s:use_plugins >= 2
    if !executable('ctags')
        echoerr 'A ctags implementation is required for generating tags'
        echoerr 'for some commands (and possibly plugins).'
    endif
    nnoremap <Leader>ut :UpdateTags<Return>
else
    nnoremap <Leader>ut :!ctags -R .&<Return>
endif
" <C-]> - Jump to the definition (if tags have been generated)

" Some abbreviations for languages like C, C++ and Java (if plugins are disabled)
if !s:use_plugins
    iabbrev fori  for (int i = 0; i <; i++) {<return>}<esc>kf<a
    iabbrev forr for (int i =; i >= 0; --i) {<return>}<esc>kf;i
    iabbrev pf   printf("");<esc>2hi
    iabbrev cl   cout << << endl;<esc>8hi
    iabbrev pl   System.out.println();<esc>hi
endif

" Spell checking configuration
if s:enable_spell_check
    set spell             " Enable spell checking
    " Toggle spell checking with ,tsp
    nnoremap <Leader>spt :setlocal spell!<Return>
    if s:spell_check_in_spanish
        set spelllang=es      " Set spell check language to Spanish
        " Note: On some systems, you may be prompted to download the Spanish dictionary.
    else
        set spelllang=en,es
        set dictionary=/usr/share/dict/words " Use system dictionary
    endif

    " Navigate misspelled words and correct them
    nnoremap <Leader>sl ]szzzv
    nnoremap <Leader>sh [szzzv

    " Commands to add or remove words from the spell-check list:
    " zg - Add word to the whitelist
    " zw - Remove word from the whitelist (mark as incorrect)
    " z= - Show correction suggestions
    " 1z= - Choose the first suggestion
endif

let s:languages = ['en', 'es']

function! ChangeLanguage()
    let l:index = index(s:languages, &spelllang)
    let l:index = (l:index + 1) % len(s:languages)
    let &spelllang = s:languages[l:index]
endfunction

nnoremap <leader>spr :call ChangeLanguage()<CR>
" ### End Completion, Tags, Dictionaries and Spell Checking }}}

" vim: fdm=marker

"vim.api.nvim_create_autocmd('LspAttach',{
"    callback = function(ev)
"        local client = vim.lsp.get_client_by_id(ev.data.client_id)
"        if client:supports_method('textDocument/completion') then
"            vim.lsp.completion.enable(true, client.id, ev.buf {autotrigger = true })
"        end
"    end,
"})


" CoC configuration for TypeScript
let g:coc_global_extensions = ['coc-tsserver', 'coc-json', 'coc-prettier']

" Autocomplete will be triggered automatically
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" Enable Treesitter for TypeScript and related languages.
" The Treesitter configuration is wrapped in a protected call to avoid errors if it is not installed.
lua <<EOF
local ts_status, ts_configs = pcall(require, "nvim-treesitter.configs")
if not ts_status then
  vim.notify("nvim-treesitter is not installed", vim.log.levels.WARN)
  return
end
ts_configs.setup {
  ensure_installed = { "typescript", "tsx", "javascript", "json" },
  highlight = { enable = true },
}
EOF

" =============================================================================
"                            End of Configuration File
" =============================================================================
" vim: fdm=marker

