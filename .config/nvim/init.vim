""" Plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'alvan/vim-closetag'
Plug 'christoomey/vim-tmux-navigator'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/goyo.vim'
Plug 'micarmst/vim-spellsync'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdcommenter'
Plug 'sheerun/vim-polyglot'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vimwiki/vimwiki'
call plug#end()

""" Display
set number
set numberwidth=1
set showcmd
set ignorecase
set smartcase
set foldmethod=indent
let g:dracula_colorterm = 0
syntax enable
colorscheme dracula

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
command! -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
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
let g:python3_host_prog = $HOME.'/.asdf/shims/python'

" Specify react files for vim-closetag
let g:closetag_filetypes = 'html,xhtml,phtml,javascriptreact,typescriptreact'

"" CoC

" Make <tab> used for trigger completion, completion confirm, snippet expand and jump
" https://github.com/neoclide/coc-snippets/blob/master/Readme.md
inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Edit snippets for current filetype
nnoremap <silent> <Leader>es :CocCommand snippets.openSnippetFiles<CR>

" auto-format golang
autocmd BufWritePre *.go :call CocAction('runCommand', 'editor.action.organizeImport')

"" vimwiki
let g:vimwiki_list = [{'path': '~/dev/garden/',
                      \ 'path_html': '/tmp/garden_html/',
                      \ 'syntax': 'markdown',
                      \ 'ext': '.md'}]
let g:vimwiki_global_ext = 0
hi VimwikiLink term=underline ctermfg=cyan guifg=cyan gui=underline
hi VimwikiHeader2 ctermfg=DarkMagenta guifg=DarkMagenta
hi VimwikiHeader3 ctermfg=DarkBlue guifg=DarkBlue
" Disable table_mappings that override <tab>
let g:vimwiki_key_mappings = {
      \ 'table_mappings': 0,
      \ }
