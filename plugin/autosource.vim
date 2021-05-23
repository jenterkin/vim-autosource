" autosource.vim - AutoSource
" Author:       Jordan Enterkin
" Version:      0.1

function! s:GetAutoSourceHashDir()
    if exists('g:autosource_hashdir')
        return g:autosource_hashdir
    endif
    let dir = $HOME . '/.autosource_hashes'
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
    return split(system('shasum ' . a:file))[0]
endfunction

function! s:HashString(string)
    return split(system('shasum', a:string))[0]
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
        let answer = confirm(a:path . ' has changed since it was last read. Would you like to approve it? (Choose no to inspect this file and re-open it to approve.)', "&yes\n&No", 2)
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
function! s:Source(dir)
    let cur = a:dir
    let prev = ''
    while prev !=# cur
        " don't source outside of home dir
        if cur !~ $HOME
            return
        endif

        for fname in s:fnames
            let rc = cur . '/' . fname
            if filereadable(rc)
                if s:CheckHash(rc) !=# 1
                    continue
                endif

                if rc =~? '\M.lua$' " case insensitive, nomagic
                    if has('lua')
                        exec printf('luafile %s', rc)
                    endif
                else
                    exec printf('source %s', rc)
                endif
            endif
        endfor

        let prev = cur
        " get head from path
        let cur = fnamemodify(cur, ':h')
        " if directory didn't change, that means we hit the root directory.
        " I have no idea how paths work on windows, so this is probably the safest way.
    endwhile
endfunction

augroup sourceparents
    autocmd!
    autocmd BufReadPre * nested call s:Source(expand('<afile>:p:h'))
augroup END
