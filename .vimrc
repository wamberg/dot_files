set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'

Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/vim-colors-solarized'
Plugin 'bling/vim-airline'
Plugin 'cohama/vim-smartinput-endwise'
Plugin 'fisadev/vim-isort'
Plugin 'hynek/vim-python-pep8-indent'
Plugin 'kana/vim-smartinput'
Plugin 'kien/ctrlp.vim'
Plugin 'nvie/vim-flake8'
Plugin 'pangloss/vim-javascript'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-surround'
Plugin 'SirVer/ultisnips'

call smartinput_endwise#define_default_rules()

syntax enable
set background=dark
let g:solarized_termtrans=1
colorscheme solarized

" work more logically with wrapped lines
noremap j gj
noremap k gk

"""" Searching and Patterns
set ignorecase							" search is case insensitive
set smartcase							" search case sensitive if caps on
set hlsearch							" Highlight matches to the search

"""" Display
set lazyredraw							" Don't repaint when scripts are running
set ruler								" line numbers and column the cursor is on
set number								" Show line numbering
set numberwidth=1						" Use 1 col + 1 space for numbers

" Ctrl-N twice toggle line numbers
nnoremap <silent> <C-N><C-N> :set invnumber<CR>

" tab labels show the filename without path(tail)
set guitablabel=%N/\ %t\ %M

"""" Messages, Info, Status
set shortmess+=a						" Use [+] [RO] [w] for modified, read-only, modified
set report=0							" Notify me whenever any lines have changed
set confirm								" Y-N-C prompt if closing with unsaved changes
set vb t_vb=							" Disable visual bell!  I hate that flashing.

"""" Editing
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
set showfulltag							" Show more information while completing tags


filetype plugin indent on				" Let filetype plugins indent for me

""""" Folding
set foldmethod=syntax					" By default, use syntax to determine folds
set foldlevelstart=99					" All folds open by default

set list
set listchars=tab:>.,trail:.,nbsp:.

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

""" Set a virtualenv if one is activated
:python << EOF
import os
virtualenv = os.environ.get('VIRTUAL_ENV')
if virtualenv:
    activate_this = os.path.join(virtualenv, 'bin', 'activate_this.py')
    if os.path.exists(activate_this):
        execfile(activate_this, dict(__file__=activate_this))
EOF

""" Convert a file to hex - don't forget 'ga' shows you the hex for a char
nmap <C-F6> :%!xxd<CR>

""" CtrlP mappings
nnoremap <silent> <Leader>t :CtrlP<CR>
nnoremap <silent> <Leader>b :CtrlPBuffer<CR>
let g:ctrlp_prompt_mappings = {
            \ 'AcceptSelection("e")': ['<c-e>'],
            \ 'AcceptSelection("h")': ['<c-h>'],
            \ 'AcceptSelection("t")': ['<cr>'],
            \ 'AcceptSelection("v")': ['<c-x>'],
            \ 'PrtCurEnd()':          ['']
            \ }
let g:ctrlp_custom_ignore = '\v[\/](node_modules)|(\.(swp|git|png|jpg|gif))$'

""" Snippet control
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

""" Window navigation shortcuts
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l
""" Natural splits
set splitbelow
set splitright
