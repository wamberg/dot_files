""" Plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'alvan/vim-closetag'
Plug 'christoomey/vim-tmux-navigator'
Plug 'editorconfig/editorconfig-vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'micarmst/vim-spellsync'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'projekt0n/github-nvim-theme'
Plug 'smithbm2316/centerpad.nvim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vimwiki/vimwiki'
call plug#end()

""" Display
set showcmd
set ignorecase
set smartcase
set foldlevel=99
colorscheme github_light

"" line numbers
set cursorline
set cursorlineopt=number
set number relativenumber
set numberwidth=1
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

""" Key Mappings

let mapleader = ";"

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

" Buffer navigation
map <Leader>x :bp\|bd #<Return> " delete current buffer (close)
map <Leader>q :%bd\|e#<Return> " delete all other buffers
map gn :bn<cr> " <number> + 'gn' goes to buffer number

" three-way merge conflict
nnoremap <Leader>d :Gvdiffsplit!<CR>

" Open all folds in current fold
nnoremap <leader>o zczA

""" Preferences

"" treesitter
lua <<EOF
require'nvim-treesitter.configs'.setup {
ensure_installed = {
      \"go",
      \"javascript",
      \"python",
      \"toml",
      \"tsx",
      \"typescript",
      \"yaml",
      \},
  highlight = {
    enable = true,
  },
}

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.python.used_by = "bzl"
EOF

set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()

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

" Specify react files for vim-closetag
let g:closetag_filetypes = 'html,xhtml,phtml,javascriptreact,typescriptreact'

" Centerpad
nnoremap <silent><leader>m <cmd>lua require'centerpad'.toggle { leftpad = 50, rightpad = 30 }<cr>

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

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> U :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

"" vimwiki
let g:zettelkasten = '~/dev/garden/'
let g:vimwiki_list = [{'path': zettelkasten,
                      \ 'path_html': '/tmp/garden_html/',
                      \ 'syntax': 'markdown',
                      \ 'ext': '.md'}]
let g:vimwiki_global_ext = 0
hi VimwikiLink term=underline ctermfg=DarkBlue guifg=DarkBlue gui=underline
hi VimwikiHeader2 ctermfg=DarkMagenta guifg=DarkMagenta
hi VimwikiHeader3 ctermfg=DarkGreen guifg=DarkBlue

" Disable table_mappings that override <tab>
let g:vimwiki_key_mappings = {
      \ 'table_mappings': 0,
      \ }

" Create new notes
command! NewNote :execute ":e" zettelkasten . strftime("%Y%m%d%H%M") . ".md"
nnoremap <silent> <leader>nn :NewNote<CR>

lua require('config')
