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

function! s:EchoWarning(msg)
  echohl WarningMsg
  echo 'Warning'
  echohl None
  echon ': ' a:msg
endfunction

function! s:GetPromptForChangedConf()
    if exists('g:autosource_prompt_for_changed_conf')
        return g:autosource_prompt_for_changed_conf
    endif
    return 1
endfunction

function! s:GetPromptForNewConf()
    if exists('g:autosource_prompt_for_new_conf')
        return g:autosource_prompt_for_new_conf
    endif
    return 1
endfunction

function! s:GetAutoSourceConfNames()
    if exists('g:autosource_conf_names')
        if type(g:autosource_conf_names) !=# v:t_list
            return [g:autosource_conf_names]
        endif
        return g:autosource_conf_names
    endif
    return ['.vimrc', '.vimrc.lua']
endfunction

function! s:GetAutoSourceApproveOnSave()
    if exists('g:autosource_approve_on_save')
        return g:autosource_approve_on_save
    endif
    return 1
endfunction

function! s:GetAutoSourceDisableAutoCmd()
    if exists('g:autosource_disable_autocmd')
        return g:autosource_disable_autocmd
    endif
    return 0
endfunction

function! s:GetAutoSourceLoadOncePerSession()
    if exists('g:autosource_load_once_per_session')
        return g:autosource_load_once_per_session
    endif
    return 0
endfunction

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
            call mkdir(dir, 'p')
            return dir
        endif
    endif
endfunction

function! s:GetHashLocation(path)
    let filename_hash = s:HashString(a:path)
    return s:GetAutoSourceHashDir() . '/' . filename_hash
endfunction

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
    let found = 0
    let filename = split(a:path, '/')[-1]
    let names = s:GetAutoSourceConfNames()
    for name in names
        if filename == name
            let found = 1
        endif
    endfor
    if found ==# 0
        " TODO: warn
        call s:EchoWarning('Attempted to approve file not in g:autosource_conf_names (' . join(names, ', ') .'): ' . filename)
        return
    endif
    let hash_location = s:GetHashLocation(a:path)
    let data_hash = s:HashFile(a:path)
    call writefile([data_hash], hash_location)
endfunction

function! s:CheckHash(path)
    let dir = s:GetAutoSourceHashDir()
    let known_hash = s:GetKnownHash(a:path)

    " Check if new file
    if known_hash ==# ''
        if s:GetPromptForNewConf() ==# 0
            return 0
        endif
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
        if s:GetPromptForChangedConf() ==# 0
            return 0
        endif
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

" Source all `.vimrc` files in your pwd and parents up to your home dir
function! AutoSource(dir, load_once_per_session)
    if a:dir !~ $HOME
        return
    endif

    if a:load_once_per_session && !exists('s:sourced')
        let s:sourced = {}
    endif

    let i = 0
    let crumbs = split(a:dir, '/')
    while i < len(crumbs)
        let cur = '/' . join(crumbs[0:i], '/')
        let i += 1

        if cur !~ $HOME
            continue
        endif

        for fname in s:GetAutoSourceConfNames()
            let rc = cur . '/' . fname
            if filereadable(rc) && s:CheckHash(rc) ==# 1
                if a:load_once_per_session
                    if has_key(s:sourced, rc)
                        continue
                    endif
                    let s:sourced[rc] = 1
                endif
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

" Function that autocmd calls to trigger AutoSource. Used to allow
" enabling/disabling on the fly.
function! s:autocmdTriggerAutoSource(dir)
    if s:GetAutoSourceDisableAutoCmd() !=# 1
        call AutoSource(a:dir, s:GetAutoSourceLoadOncePerSession())
    endif
endfunction

function! AutoSourceApproveFile(path)
    call s:SetHash(a:path)
endfunction

" Function that autocmd calls to trigger AutoSourceApproveFile. Used to allow
" enabling/disabling on the fly.
function! s:autocmdTriggerAutoSourceApproveFile(path)
    if s:GetAutoSourceApproveOnSave() ==# 1
        call AutoSourceApproveFile(a:path)
    endif
endfunction

augroup AutoSource
    autocmd!
    autocmd BufReadPre,BufNewFile * nested call s:autocmdTriggerAutoSource(expand('<afile>:p:h'))
    execute 'autocmd BufWritePost ' . join(s:GetAutoSourceConfNames(), ',') . ' call s:autocmdTriggerAutoSourceApproveFile(expand("<afile>:p"))'
augroup END

command! AutoSource call AutoSource(expand('%:p:h'), 0)
command! AutoSourceApproveFile call AutoSourceApproveFile(expand('%:p'))
