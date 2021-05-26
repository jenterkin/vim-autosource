" Used to init tests

" vint: next-line -ProhibitSetNoCompatible
set nocompatible  " required by Vader

set runtimepath+=.
set runtimepath+=./vader

source ./autosource.vim
source ./vader/plugin/vader.vim

filetype plugin indent on
syntax enable

set autochdir
let g:autosource_disable_autocmd = 1
