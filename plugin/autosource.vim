" autosource.vim - AutoSource
" Author:       Jordan Enterkin
" Version:      0.1
" Licence:      MIT
" The MIT License (MIT)
" 
" Copyright (c) 2021 Jordan Enterkin
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


function! s:GetAutoSourceHashDir()
    if exists('g:autosource_hashdir')
        let dir = g:autosource_hashdir
    else
        let dir = $HOME . '/.autosource_hashes'
    endif

    if isdirectory(dir)
        return dir
    else
        if filereadable(dir)
            echo dir . ' is a file. Please delete it or set `g:autosource_hashdir` to another location'
        else
            call mkdir(dir)
        endif
    endif
endfunction

function! s:GetHashLocation(path)
    let filename_hash = s:HashString(a:path)
    return s:GetAutoSourceHashDir() . '/' . filename_hash
endfunc

function! s:HashFile(file)
    let content = join(readfile(a:file), '\n')
    return sha256(content)
endfunction

function! s:HashString(string)
    return sha256(a:string)
endfunction

function! s:GetKnownHash(path)
    let hash_location = s:GetHashLocation(a:path)
    " TODO: check if file exists, warn separately if exists and is not
    " readable.
    if !filereadable(hash_location)
        return ''
    endif
    let data = join(readfile(hash_location), '\n')
    return data
endfunction

function! s:SetHash(path)
    let hash_location = s:GetHashLocation(a:path)
    let data_hash = s:HashFile(a:path)
    call writefile([data_hash], hash_location)
endfunction

function! s:CheckHash(path)
    let dir = s:GetAutoSourceHashDir()
    let known_hash = s:GetKnownHash(a:path)

    " Check if new file
    if known_hash ==# ''
        let answer = confirm(a:path . ' is a new file. Would you like to allow sourcing it? (Choose no to inspect this file and re-open it to approve.)', "&yes\n&No", 2)
        if answer ==# 1
            call s:SetHash(a:path)
            return 1
        else
            return 0
        endif
    endif

    " Check if file has changed
    if known_hash !=# s:HashFile(a:path)
        let answer = confirm(a:path . ' has been updated. Would you like to allow sourcing it? (Choose no to inspect this file and re-open it to approve.)', "&yes\n&No", 2)
        if answer ==# 1
            call s:SetHash(a:path)
            return 1
        else
            return 0
        endif
    endif
    return 1
endfunction

let s:fnames = ['.vimrc', '.vimrc.lua']

" Source all `.vimrc` files in your pwd and parents up to your home dir
function! AutoSource(dir)
    if a:dir !~ $HOME
        return
    endif

    let i = 0
    let crumbs = split(a:dir, '/')
    while i < len(crumbs)
        let cur = '/' . join(crumbs[0:i], '/')
        let i += 1

        if cur !~ $HOME
            continue
        endif

        for fname in s:fnames
            let rc = cur . '/' . fname
            if filereadable(rc) && s:CheckHash(rc) ==# 1
                if rc =~? '\M.lua$'
                    if has('nvim')
                        exec printf('luafile %s', rc)
                    endif
                else
                    exec printf('source %s', rc)
                endif
            endif
        endfor
    endwhile
endfunction

function! s:GetAutoSourceDisableAutoCmd()
    if exists('g:autosource_disable_autocmd')
        return g:autosource_disable_autocmd
    endif
    return 0
endfunction

if s:GetAutoSourceDisableAutoCmd() !=# 1
    augroup sourceparents
        autocmd!
        autocmd BufReadPre,BufNewFile * nested call AutoSource(expand('<afile>:p:h'))
    augroup END
endif
