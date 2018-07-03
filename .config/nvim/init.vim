""" Plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'Glench/Vim-Jinja2-Syntax', { 'for': 'jinja' }
Plug 'Rykka/riv.vim', { 'for': 'rst' }
Plug 'SirVer/ultisnips'
Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'godlygeek/tabular'
Plug 'jez/vim-colors-solarized'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
call plug#end()

""" Display
set number
set numberwidth=1
set showcmd
set ignorecase
set smartcase

""" Key Mappings

" work more logically with wrapped lines
noremap j gj
noremap k gk

" Check spelling
set spell spelllang=en_us
map <F8> :set spell!<CR>
set nospell

" Ctrl-N twice toggle line numbers
nnoremap <silent> <C-N><C-N> :set invnumber<CR>

" \+c redraws the screen and removes any search highlighting.
nnoremap <silent> <Leader>c :noh<CR>

" toggle formatting for pasting
map <F9> :set invpaste<CR>

" CtrlP mappings
nnoremap <silent> <Leader>t :CtrlP<CR>
nnoremap <silent> <Leader>b :CtrlPBuffer<CR>
nnoremap <silent> <Leader>g :CtrlPTag<CR>
let g:ctrlp_prompt_mappings = {
            \ 'AcceptSelection("e")': ['<cr>'],
            \ 'AcceptSelection("h")': ['<c-h>'],
            \ 'AcceptSelection("t")': ['<c-b>'],
            \ 'AcceptSelection("v")': ['<c-x>'],
            \ 'PrtCurEnd()':          ['']
            \ }

" Buffer navigation
map <Leader>a :bprev<Return>
map <Leader>s :bnext<Return>
map <Leader>x :bd%<Return> " delete current buffer (close)
map gn :bn<cr> " <number> + 'gn' goes to buffer number

" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" bind \ (backward slash) + f to grep shortcut
command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
nnoremap <Leader>f :Ag<SPACE>

" Ultisnip control
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsListSnippets="<c-l>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" vim-dispatch
noremap <Leader>ds :Start!<CR>
noremap <Leader>dd :Dispatch<CR>
noremap <Leader>dc :cclose<CR>

""" Preferences

" run local rc files
set exrc
set secure

" Use ag over grep
if executable('/usr/bin/ag') || executable('/usr/local/bin/ag')
  set grepprg=ag\ --nogroup\ --nocolor\ --hidden

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" Natural splits
set splitbelow
set splitright

" restore-cursor
autocmd BufReadPost *
	\ if line("'\"") > 1 && line("'\"") <= line("$") |
	\   exe "normal! g`\"" |
	\ endif

" Specify python3 for plugins
let g:python3_host_prog = $HOME.'/.local/share/nvim/venv/bin/python3.6'


""" Plugin preferences
set background=light
colorscheme solarized
