""" Plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'ctrlpvim/ctrlp.vim'
call plug#end()

""" Display
set number
set numberwidth=1
set showcmd
set ignorecase
set smartcase

""" Key Mappings

" Navigate regular and terminal buffers
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" work more logically with wrapped lines
noremap j gj
noremap k gk

" Check spelling
map <F8> :w!<CR>:!aspell check %<CR>:e! %<CR>

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

""" Preferences

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
