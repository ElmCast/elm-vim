# elm-vim

[Elm](http://elm-lang.org) support for Vim.

## Features

1. Syntax highlighting
1. Automatic Indentation
1. Documentation and Type Lookup
1. Integration with [elm-make](https://github.com/elm-lang/elm-make)
1. Integration with [elm-repl](https://github.com/elm-lang/elm-repl)
1. Integration with [elm-package](https://github.com/elm-lang/elm-package)
1. Integration with [elm-oracle](https://github.com/elmcast/elm-oracle)
1. Integration with [elm-format](https://github.com/avh4/elm-format)
1. Integration with [elm-test](https://github.com/deadfoxygrandpa/elm-test)
1. Integration with [syntastic](https://github.com/scrooloose/syntastic)

Check out this [ElmCast video](https://vimeo.com/132107269) for more detail.

## Install

elm-vim follows the standard runtime path structure, so you can use your favorite plugin manager to install it.

Please be sure all necessary binaries are installed (such as `elm-make`, `elm-doc`, `elm-reactor`, etc..) from http://elm-lang.org/.

```
npm install -g elm
```

In order to run unit tests from within vim, install `elm-test`.

```
npm install -g elm-test
```

For code completion and doc lookups, install `elm-oracle`.

```
npm install -g elm-oracle
```

To automatically format your code, install `elm-format` from the [github page](https://github.com/avh4/elm-format).

```vim
let g:elm_format_autosave = 1
```

## Mappings

The plugin provides several `<Plug>` mappings which can be used to create custom
mappings. The following keybindings are provided by default:

| Keybinding             | Description                                                         |
| ---------------------- | ------------------------------------------------------------------- |
| <Leader>m              | Compile the current buffer.                                         |
| <Leader>b              | Compile the Main.elm file in the project.                           |
| <Leader>t              | Runs the tests of the current buffer.                               |
| <Leader>r              | Opens an elm repl in a subprocess.                                  |
| <Leader>e              | Shows the detail of the current error or warning.                   |
| <Leader>d              | Shows the type and docs for the word under the cursor.              |
| <Leader>w              | Opens the docs web page for the word under the cursor.              |


You can disable these mappings if you want to use your own.

```vim
let g:elm_setup_keybindings = 0
```

# Integration

## [Syntastic](https://github.com/scrooloose/syntastic)

Syntastic support should work out of the box, but we recommend the following settings:

```vim
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1

let g:elm_syntastic_show_warnings = 1
```

## [YouCompleteMe](https://github.com/Valloric/YouCompleteMe)

```vim
let g:ycm_semantic_triggers = {
     \ 'elm' : ['.'],
     \}
```

## [Neocomplete](https://github.com/Shougo/neocomplete.vim)

```vim
call neocomplete#util#set_default_dictionary(
  \ 'g:neocomplete#sources#omni#input_patterns',
  \ 'elm',
  \ '\.')
```

## Usage

Many of the [features](#features) are enabled by default. There are no
additional settings needed. All usages and commands are listed in
`doc/elm-vim.txt`.

    :help elm-vim

```vim
let g:elm_jump_to_error = 1
let g:elm_make_output_file = "elm.js"
let g:elm_make_show_warnings = 0
let g:elm_syntastic_show_warnings = 0
let g:elm_browser_command = ""
let g:elm_detailed_complete = 0
let g:elm_format_autosave = 0
let g:elm_setup_keybindings = 1
```

* `:ElmMake [filename]` calls `elm-make` with the given file. If no file is given it uses the current file being edited.

* `:ElmMakeMain` attempts to call `elm-make` with "Main.elm".

* `:ElmTest` calls `elm-test` with the given file. If no file is given it attempts to run the tests in 'Test[filename].elm'.

* `:ElmRepl` runs `elm-repl`, which will return to vim on exiting.

* `:ElmErrorDetail` shows the detail of the current error in the quickfix window.

* `:ElmShowDocs` queries elm-oracle, then echos the type and docs for the word under the cursor.

* `:ElmBrowseDocs` queries elm-oracle, then opens docs web page for the word under the cursor.
*
* `:ElmFormat` formats the current buffer with elm-format.

## Credits

* Other vim-plugins, thanks for inspiration (elm.vim, ocaml.vim, haskell-vim)
* [Contributors](https://github.com/elmcast/elm-vim/graphs/contributors) of elm-vim

## License

The BSD 3-Clause License - see `LICENSE` for more details
