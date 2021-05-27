# AutoSource  ![ci workflow](https://github.com/jenterkin/vim-autosource/actions/workflows/ci.yml/badge.svg)
AutoSource is a Vim plugin that finds each Vim configuration file (`.vimrc` or `.vimrc.lua`) from your `$HOME` directory to the opened file.

![Example usage](static/example.gif)

## Security
To prevent arbitrary code execution attacks, AutoSource will prompt you to approve new `.vimrc` files and to re-approve those which have changed. By default AutoSource will automatically approve config changes made through Vim. See [`g:autosource_approve_on_save`](#g:autosource_approve_on_save) for more info.

![Security example](static/security_example.gif)

In this gif I answered "no" to the prompt so that it was not sourced, then opened the `.vimrc` file that was cloned with the repo to see the _very_ malicious code inside.

## Why AutoSource
I work on many projects and each project has its' own standards and requirements. This means I can't configure Vim to handle a given language in a single way. I'll also commonly open a file in a different repo than I'm currently in to tweak something (e.g. an API response), then hop back to what I was originally doing (e.g. writing some client code that consumes said API endpoint).

I wrote AutoSource because the available options (`exrc` and other plugins) didn't have either the functionality or security features that I wanted. AutoSource is configurable, unobtrusive, and secure.

## Installation
### Plug
**[Home Page](https://github.com/junegunn/vim-plug)**

```vim
Plug 'jenterkin/vim-autosource'
```

### packer.nvim
**[Home Page](https://github.com/wbthomason/packer.nvim)**

```lua
use 'jenterkin/vim-autosource'
```

or if you'd like to set options after it loads:

```lua
use {
    'jenterkin/vim-autosource',
    config = function()
        vim.g.autosource_hashes = '$XDG_CACHE_HOME/vim-autosource/hashes'
    end
}
```

## Lua files
AutoSource will also look for `.vimrc.lua` files and source them with `:luafile`.

## Variables
### `g:autosource_hashdir`
**Default:** `$HOME/.autosource_hashes`

This directory is where AutoSource stores the hashes of your files. These hashes are used to check for changes so the plugin can prompt you for re-approval.

### `g:autosource_disable_autocmd`
**Default:** `0`

If set to `1`, the autocmd that triggers AutoSource will not be enabled. This can be useful if you would like more fine-grained control over when and how it is run. For example, if you only want to run it when you start Vim you can set the following `autocmd`:

```vim
augroup sourceparents
    autocmd!
    autocmd VimEnter * nested call AutoSource(expand('<afile>:p:h'))
augroup END
```

### `g:autosource_approve_on_save`
**Default:** `1`

When set to 1, AutoSource will automatically approve `.vimrc` and `.vimrc.lua` files when you save them. This reduces the number of approval prompts you'll have to see while still getting prompted when the file is changed outside of Vim (e.g. someone puts a malicious `.vimrc` file in a repo that you've cloned).

If you'd like to be approved even when you saved the config through Vim, set this option to 0.

### `g:autosource_conf_names`
**Default:** `['.vimrc', '.vimrc.lua']`

These are the file names that AutoSource looks for to source. You can set this to either a string if you're only specifying a single file, or a list if you'd like to check against multiple.

```vim
let g:autosource_conf_names = '.lvimrc'
" or to check multiple
let g:autosource_conf_names = ['.lvimrc', '.lvimrc.lua']
```

### `g:autosource_prompt_for_new_file`
**Default:** `1`

The primary use-case of this option is to support automated testing.

When set to `0` AutoSource will not prompt you when it detects a new file. The file will **NOT** be sourced.

### `g:autosource_prompt_for_changed_file`
**Default:** `1`

The primary use-case of this option is to support automated testing.

When set to `0` AutoSource will not prompt you when it detects when a file is changed. The file will **NOT** be sourced.

#### Lua Support
In order for a lua file to be sourced correctly it **must** end with `.lua`.

## Commands

### `:AutoSource`
Sources parents of the current file.

### `:AutoSourceApproveFile`
Approves the current file.

## Want to see a new feature? Report a bug?
Feel free to submit issues on the [issues page](https://github.com/jenterkin/vim-autosource/issues).

## Similar Projects
- [exrc.vim](https://github.com/ii14/exrc.vim)
- [local_vimrc](https://github.com/LucHermitte/local_vimrc)
- [vim-projectlocal](https://github.com/krisajenkins/vim-projectlocal)

## Supported Operating Systems
AutoSource only supports MacOS and Linux. Windows is not actively tested. If you would like to fix any Windows-specific issues, feel free to submit a PR.
