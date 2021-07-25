""" Plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'christoomey/vim-tmux-navigator'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'micarmst/vim-spellsync'
Plug 'junegunn/goyo.vim'
call plug#end()

""" Display
set showcmd
set ignorecase
set smartcase
let g:dracula_colorterm = 0
colorscheme dracula

"" line numbers
set number relativenumber
set numberwidth=1

""" Key Mappings

let mapleader = ";"

" work more logically with wrapped lines
noremap j gj
noremap k gk

"" Move viewport
" scroll up
noremap <silent> <C-U> <C-Y>
" scroll down
noremap <silent> <C-D> <C-E>

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

" Start Goyo
nnoremap <silent><leader>w :Goyo<cr>


" Buffer navigation
map <Leader>x :bp\|bd #<Return> " delete current buffer (close)
map <Leader>q :%bd\|e#<Return> " delete all other buffers
map gn :bn<cr> " <number> + 'gn' goes to buffer number

" Open all folds in current fold
nnoremap <leader>o zczA

""" Preferences

" run local rc files
set exrc
set secure

" Use rg over grep
set grepprg=rg\ --vimgrep

" Natural splits
set splitbelow
set splitright

" restore-cursor
autocmd BufReadPost *
	\ if line("'\"") > 1 && line("'\"") <= line("$") |
	\   exe "normal! g`\"" |
	\ endif

" Specify python3 for plugins
let g:python3_host_prog = $HOME.'/.asdf/shims/python'

" Goyo overrides
function! s:goyo_enter()
  set noshowmode
  set noshowcmd
  set scrolloff=999
  set linebreak
  set wrap
endfunction

function! s:goyo_leave()
  set showmode
  set showcmd
  set scrolloff=5
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()
