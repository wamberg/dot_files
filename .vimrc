set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle, required
Plugin 'gmarik/vundle'

Plugin 'Glench/Vim-Jinja2-Syntax'
Plugin 'SirVer/ultisnips'
Plugin 'airblade/vim-gitgutter'
Plugin 'bling/vim-airline'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'fisadev/vim-isort'
Plugin 'honza/vim-snippets'
Plugin 'hynek/vim-python-pep8-indent'
Plugin 'isRuslan/vim-es6'
Plugin 'kana/vim-smartinput'
Plugin 'kien/ctrlp.vim'
Plugin 'mxw/vim-jsx'
Plugin 'pangloss/vim-javascript'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-surround'


syntax enable

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
set foldmethod=indent					" By default, use indent to determine folds
set foldlevelstart=99					" All folds open by default

set list
set listchars=tab:>.,trail:.,nbsp:.

"""" Autocommands
if has("autocmd")
    augroup vimrcEx
        au!
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

""" Check spelling
map <F8> :w!<CR>:!aspell check %<CR>:e! %<CR>

""" toggle formatting for pasting
map <F9> :set invpaste<CR>

""" Set a virtualenv if one is activated
:python3 << EOF
import os
virtualenv = os.environ.get('VIRTUAL_ENV')
if virtualenv:
    activate_this = os.path.join(virtualenv, 'bin', 'activate_this.py')
    if os.path.exists(activate_this):
        with open(activate_this) as f:
            code = compile(f.read(), activate_this, 'exec')
            exec(code, {'__file__': activate_this})
EOF

""" Convert a file to hex - don't forget 'ga' shows you the hex for a char
nmap <C-F6> :%!xxd<CR>

""" CtrlP mappings
nnoremap <silent> <Leader>t :CtrlP<CR>
nnoremap <silent> <Leader>b :CtrlPBuffer<CR>
nnoremap <silent> <Leader>x :CtrlPTag<CR>
let g:ctrlp_prompt_mappings = {
            \ 'AcceptSelection("e")': ['<cr>'],
            \ 'AcceptSelection("h")': ['<c-h>'],
            \ 'AcceptSelection("t")': ['<c-b>'],
            \ 'AcceptSelection("v")': ['<c-x>'],
            \ 'PrtCurEnd()':          ['']
            \ }

""" Buffer navigation
map <Leader>a :bprev<Return>
map <Leader>s :bnext<Return>
map <Leader>d :bd%<Return>"delete current buffer


" Use ag over grep
if executable('/usr/bin/ag') || executable('/usr/local/bin/ag')
  set grepprg=ag\ --nogroup\ --nocolor\ --hidden

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" bind \ (backward slash) + a to grep shortcut
command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
nnoremap <Leader>f :Ag<SPACE>

""" Snippet control
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippets="<c-l>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

""" Syntastic settings
let g:syntastic_javascript_checkers = ['eslint']

""" Natural splits
set splitbelow
set splitright

""" mxw/vim-jsx settings
let g:jsx_ext_required = 0
