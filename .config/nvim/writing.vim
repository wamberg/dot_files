""" Plugins
call plug#begin('~/.local/share/nvim/writing-plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
call plug#end()


""" Key Mappings

" work more logically with wrapped lines
noremap j gj
noremap k gk


""" Plugin preferences

" goyo.vim
function! s:goyo_enter()
  set bg=light
  set complete+=s
  set noai
  set noci
  set noshowcmd
  set noshowmode
  set nosi
  set spell
  if !has('gui_running')
    let g:solarized_termcolors=256
  endif
  colors solarized
  Limelight

  " https://github.com/junegunn/goyo.vim/wiki/Customization#ensure-q-to-quit-even-when-goyo-is-active
  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

function! s:goyo_leave()
  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" limelight
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_guifg = 'DarkGray'

autocmd VimEnter * Goyo
