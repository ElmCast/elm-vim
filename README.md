# elm-vim

[Elm](http://elm-lang.org) support for Vim.

## Features

* Improved Syntax highlighting, including backtick operators, booleans, chars, triple quotes, string escapes, and tuple functions
* Improved Indentation
* Commands and mappings for interfacing with the elm platform
* Auto-complete and Doc strings
* Code formatting

Check out this [ElmCast video](https://vimeo.com/132107269) for more detail.

## Install

Elm-vim follows the standard runtime path structure, so you can use your favorite plugin manager to install it.

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

## Settings

Below are some (default) settings you might find useful to change.

```
let g:elm_jump_to_error = 1
let g:elm_make_output_file = "elm.js"
let g:elm_make_show_warnings = 0
let g:elm_syntastic_show_warnings = 0
let g:elm_browser_command = ""
let g:elm_detailed_complete = 0
let g:elm_format_autosave = 0
```

## Mappings

Elm-vim has several `<Plug>` mappings which can be used to create custom
mappings. Below are some examples you might find useful:

```vim
au FileType elm nmap <leader>b <Plug>(elm-make)
au FileType elm nmap <leader>m <Plug>(elm-make-main)
au FileType elm nmap <leader>t <Plug>(elm-test)
au FileType elm nmap <leader>r <Plug>(elm-repl)
au FileType elm nmap <leader>e <Plug>(elm-error-detail)
au FileType elm nmap <leader>d <Plug>(elm-show-docs)
au FileType elm nmap <leader>w <Plug>(elm-browse-docs)
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
