" Used to init tests

" vint: next-line -ProhibitSetNoCompatible
" set nocompatible  " required by Vader

set runtimepath+=~.
set runtimepath+=./vader

source ./plugin/autosource.vim
source ./vader/plugin/vader.vim

set autochdir
let g:autosource_disable_autocmd = 1
