""" Plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'editorconfig/editorconfig-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
call plug#end()

""" Display
set number
set numberwidth=1
set showcmd
set ignorecase
set smartcase
set foldmethod=indent

""" Key Mappings

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

" sort selected space-separated list
nnoremap <C-s> f"i<Space><Esc>vi":s/\%V.*\%V"\@!/\=join(sort(split(submatch(0), '\s* \s*')), ' ')<CR>gv<Esc>x

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
map <Leader>x :bp\|bd #<Return> " delete current buffer (close)
map <Leader>q :%bd\|e#<Return> " delete all other buffers
map gn :bn<cr> " <number> + 'gn' goes to buffer number

" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" bind \ (backward slash) + f to grep shortcut
command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
nnoremap <Leader>f :Ag<SPACE>


""" Preferences

" run local rc files
set exrc
set secure

" Use ag over grep
if executable('/usr/bin/ag') || executable('/usr/local/bin/ag')
  set grepprg=ag\ --nogroup\ --nocolor\ --hidden

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'

  " No caching ag for CtrlP
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
let g:python3_host_prog = $HOME.'/.pyenv/shims/python'

"" CoC
"" Largely taken from https://github.com/neoclide/coc.nvim/blob/master/Readme.md

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" navigate within a snippet
let g:coc_snippet_prev = '<C-a>'
let g:coc_snippet_next = '<C-s>'
nmap <silent> <leader>a <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>s <Plug>(coc-diagnostic-next)

" Use [+d to jump to defintion
nnoremap <silent> [d :call CocActionAsync('jumpDefinition')<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Use ]+d to show documentation in preview window
nnoremap <silent> ]d :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
