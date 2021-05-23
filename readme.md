# AutoSource
AutoSource is a VIM plugin that finds each `.vimrc` file from your `$HOME` directory to the opened file. For example, with the given tree, while editing `myfile`, AutoSource will source the `.vimrc` files in `a/` and `c/`, but not `d/`.
```
.
└── a
    ├── .vimrc
    ├── b
    │   └── c
    │       ├── .vimrc
    │       └── myfile
    └── d
        └── .vimrc
```

## Security
To prevent arbitrary code execution attacks, AutoSource will prompt you to approve new `.vimrc` files and to re-approve those which have changed. This check happens whenever a file is opened.

### WARNING
This plugin does not yet have tests and so this feature can not be guaranteed.

## Lua files
AutoSource will also look for `.vimrc.lua` files and source them with `:luafile`.

## Variables
### `g:autosource_hashdir`
**Default:** `$HOME/.autosource_hashes`

This directory is where AutoSource stores the hashes of your files. These hases are used to check for changes so the plugin can prompt you for re-approval.

## Planned Work
Features are being tracked in the [issues page](https://github.com/jenterkin/vim-autosource/issues?q=is%3Aopen+is%3Aissue+label%3Aenhancement). If you would like to request a feature feel free to create an issue with the `enhancement` tag.

## Supported Operating Systems
AutoSource currently only supports MacOS and Linux. If you would like to add Windows support, PRs are welcome.
