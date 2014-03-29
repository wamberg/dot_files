set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'
Plugin 'bling/vim-airline'
Plugin 'kien/ctrlp.vim'
Plugin 'nvie/vim-flake8'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'digitaltoad/vim-jade'
Plugin 'pangloss/vim-javascript'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-surround'
Plugin 'hynek/vim-python-pep8-indent'
Plugin 'kana/vim-smartinput'
Plugin 'cohama/vim-smartinput-endwise'
Plugin 'slim-template/vim-slim'


call smartinput_endwise#define_default_rules()


" work more logically with wrapped lines
noremap j gj
noremap k gk

"""" Searching and Patterns
set ignorecase							" search is case insensitive
set smartcase							" search case sensitive if caps on
" set incsearch							" show best match so far
set hlsearch							" Highlight matches to the search

"""" Display
set lazyredraw							" Don't repaint when scripts are running
set scrolloff=3							" Keep 3 lines below and above the cursor
set ruler								" line numbers and column the cursor is on
set number								" Show line numbering
set numberwidth=1						" Use 1 col + 1 space for numbers

" Ctrl-N twice toggle line numbers
nnoremap <silent> <C-N><C-N> :set invnumber<CR>

" tab labels show the filename without path(tail)
set guitablabel=%N/\ %t\ %M

"""" Messages, Info, Status
set shortmess+=a						" Use [+] [RO] [w] for modified, read-only, modified
set showcmd								" Display what command is waiting for an operator
set ruler								" Show pos below the win if there's no status line
set laststatus=2						" Always show statusline, even if only 1 window
set report=0							" Notify me whenever any lines have changed
set confirm								" Y-N-C prompt if closing with unsaved changes
set vb t_vb=							" Disable visual bell!  I hate that flashing.

"""" Editing
set backspace=2							" Backspace over anything! (Super backspace!)
set showmatch							" Briefly jump to the previous matching paren
set matchtime=2							" For .2 seconds
set formatoptions-=tc					" I can format for myself, thank you very much
set tabstop=4							" Tab stop of 4
set shiftwidth=4						" sw 4 spaces (used on auto indent)
set softtabstop=4						" 4 spaces as a tab for bs/del
set expandtab

" we don't want to edit these type of files
set wildignore=*.o,*.obj,*.bak,*.exe,*.pyc,*.swp

"""" Coding
set history=100							" 100 Lines of history
set showfulltag							" Show more information while completing tags


filetype plugin indent on				" Let filetype plugins indent for me

""""" Folding
set foldmethod=syntax					" By default, use syntax to determine folds
set foldlevelstart=99					" All folds open by default

"""" Command Line
set wildmenu							" Autocomplete features in the status bar

"""" Autocommands
if has("autocmd")
    augroup vimrcEx
        au!
        " In plain-text files and svn commit buffers, wrap automatically at 78 chars
        au FileType text,svn setlocal tw=78 fo+=t

        " In all files, try to jump back to the last spot cursor was in before exiting
        au BufReadPost *
                    \ if line("'\"") > 0 && line("'\"") <= line("$") |
                    \   exe "normal g`\"" |
                    \ endif

        " kill calltip window if we move cursor or leave insert mode
        au CursorMovedI * if pumvisible() == 0|pclose|endif
        au InsertLeave * if pumvisible() == 0|pclose|endif

    augroup END
endif

"""" Key Mappings
" CTRL-g shows filename and buffer number, too.
nnoremap <C-g> 2<C-g>

" \+c redraws the screen and removes any search highlighting.
nnoremap <silent> <Leader>c :noh<CR>

" Q formats paragraphs, instead of entering ex mode
noremap Q gq

" * and # search for next/previous of selected text when used in visual mode
vnoremap * y/<C-R>"<CR>
vnoremap # y?<C-R>"<CR>

""" Abbreviations
function! EatChar(pat)
    let c = nr2char(getchar(0))
    return (c =~ a:pat) ? '' : c
endfunc

""" Pylint compiler
autocmd FileType python compiler pylint
let g:pylint_onwrite = 0

""" Find lines longer than 80 characters
nmap <F12> /\%81c<CR>

""" Check spelling
map <F8> :w!<CR>:!aspell check %<CR>:e! %<CR>

""" toggle formatting for pasting
map <F9> :set invpaste<CR>

""" python debugging set_trace
map st oimport ipdb; ipdb.set_trace()<esc>

""" Convert a file to hex - don't forget 'ga' shows you the hex for a char
nmap <C-F6> :%!xxd<CR>

""" CtrlP mappings
nnoremap <silent> <Leader>t :CtrlP<CR>
nnoremap <silent> <Leader>b :CtrlPBuffer<CR>
let g:ctrlp_prompt_mappings = {
            \ 'AcceptSelection("e")': [],
            \ 'AcceptSelection("t")': ['<cr>', '<c-m>'],
            \ }
let g:ctrlp_custom_ignore = 'node_modules'

""" Window navigation shortcuts
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l
