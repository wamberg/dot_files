""" Plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'Rykka/riv.vim', { 'for': 'rst' }
Plug 'SirVer/ultisnips'
Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'fisadev/vim-isort', { 'for': 'python' }
Plug 'hynek/vim-python-pep8-indent'
Plug 'mxw/vim-jsx'
Plug 'neomake/neomake'
Plug 'pangloss/vim-javascript'
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

" Ctrl-N twice toggle line numbers
nnoremap <silent> <C-N><C-N> :set invnumber<CR>

" \+c redraws the screen and removes any search highlighting.
nnoremap <silent> <Leader>c :noh<CR>

" toggle formatting for pasting
map <F9> :set invpaste<CR>

" CtrlP mappings
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

" Buffer navigation
map <Leader>a :bprev<Return>
map <Leader>s :bnext<Return>
map <Leader>d :bd%<Return> " delete current buffer
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

""" Preferences

" two spaces over tabs
set tabstop=4 softtabstop=0 expandtab shiftwidth=2 smarttab

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

" run local rc files
set exrc
set secure

" Specify python3 for plugins
let g:python3_host_prog = $HOME.'/.local/share/nvim/venv/bin/python3.6'


""" Plugin preferences

"" Neomake
" Lint on write
autocmd! BufReadPost,BufWritePost * Neomake

" Change warning and error signs in gutter
let g:neomake_warning_sign = {
  \ 'text': 'W',
  \ 'texthl': 'WarningMsg',
  \ }
let g:neomake_error_sign = {
  \ 'text': 'E',
  \ 'texthl': 'ErrorMsg',
  \ }
