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

" Source all `.vimrc` files in your pwd and parents up to your home dir
function! SourceParentRCs(path, uuid)
    " Prevent this function from being invoked by multiple autocmds
    if exists('g:autosource_running') && g:autosource_running !=# a:uuid
        return
    elseif has('macunix')
        if !executable('uuid')
            echo 'Please install the `uuid` command'
        endif
        let g:autosource_running = system('uuid')
    elseif has('unix')
        if !executable('uuidgen')
            echo 'Please install the `uuidgen` command'
        endif
        let g:autosource_running = system('uuidgen')
    endif

    if a:path ==# ''
        let cur = expand('%:p:h')
    else
        let cur = a:path
    endif

    " don't source outside of home dir
    if cur !~ $HOME
        return
    endif

    " source file if found
    let rc = cur . '/.vimrc'
    if filereadable(rc)
        if s:CheckHash(rc) ==# 1
            exec printf('source %s', rc)
        endif
    endif

    " run again with parent dir
    let parent = '/' . join(split(cur, '/')[:-2], '/')
    call SourceParentRCs(parent, g:autosource_running)

    " Unset when done to allow check to run again
    if a:path ==# ''
        unlet g:autosource_running
    endif
endfunction

augroup sourceparents
    autocmd BufReadPre,FileReadPre * :call SourceParentRCs("", "")
augroup END
