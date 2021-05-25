# AutoSource
AutoSource is a VIM plugin that finds each vim configuration file (`.vimrc` or `.vimrc.lua`) from your `$HOME` directory to the opened file.

![Example usage](static/example.gif)

## Security
To prevent arbitrary code execution attacks, AutoSource will prompt you to approve new `.vimrc` files and to re-approve those which have changed. By default AutoSource will automatically approve config changes made through VIM. See [`g:autosource_approve_on_save`](#g:autosource_approve_on_save) for more info.

### WARNING
This plugin does not yet have tests and so this feature can not be guaranteed.

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

Run `:PackerCompile` after updating your packer config.

## Lua files
AutoSource will also look for `.vimrc.lua` files and source them with `:luafile`.

## Variables
### `g:autosource_hashdir`
**Default:** `$HOME/.autosource_hashes`

This directory is where AutoSource stores the hashes of your files. These hases are used to check for changes so the plugin can prompt you for re-approval.

### `g:autosource_disable_autocmd`
**Default:** `0`

If set to `1`, the autocmd that triggers AutoSource will not be enabled. This can be useful if you would like more fine-grained control over when and how it is run. For example, if you only want to run it when you start VIM you can set the following `autocmd`:

```vim
augroup sourceparents
    autocmd!
    autocmd VimEnter * nested call AutoSource(expand('<afile>:p:h'))
augroup END
```

### `g:autosource_approve_on_save`
**Default:** 1

When set to 1, AutoSource will automatically approve `.vimrc` and `.vimrc.lua` files when you save them. This reduces the number of approval prompts you'll have to see while still getting prompted when the file is changed outside of vim (e.g. someone puts a malicious `.vimrc` file in a repo that you've cloned).

If you'd like to be approved even when you saved the config through vim, set this option to 0.

## Planned Work
Features are being tracked in the [issues page](https://github.com/jenterkin/vim-autosource/issues?q=is%3Aopen+is%3Aissue+label%3Aenhancement). If you would like to request a feature feel free to create an issue with the `enhancement` tag.

## Supported Operating Systems
AutoSource currently only supports MacOS and Linux. Windows is not actively tested. If you would like to add Windows support, PRs are welcome.
