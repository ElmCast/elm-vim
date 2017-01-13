# elm-vim

![logo](https://raw.github.com/elmcast/elm-vim/master/screenshots/logo.png)

## Features

1. Syntax highlighting
1. Automatic indentation
1. Function completion
1. Build and package commands
1. Code formatting and linting
1. Documentation lookup
1. REPL integration

Check out this [ElmCast video](https://vimeo.com/132107269) for more detail.

## Installation

If you don't have a preferred installation method, I recommend installing [vim-plug](https://github.com/junegunn/vim-plug), and then simply add `Plug 'elmcast/elm-vim'` to your plugin section:

Once help tags have been generated, you can view the manual with :help elm-vim.

### Requirements

First, make sure you have the [Elm Platform](http://elm-lang.org/install) installed. The simplest method to get started is to use the official [npm](https://www.npmjs.com/package/elm) package.

```
npm install -g elm
```

In order to run unit tests from within vim, install [elm-test](https://github.com/rtfeldman/node-elm-test)

```
npm install -g elm-test
```

For code completion and doc lookups, install [elm-oracle](https://github.com/elmcast/elm-oracle).

```
npm install -g elm-oracle
```

To automatically format your code, install `elm-format` from its [github page](https://github.com/avh4/elm-format).

```vim
let g:elm_format_autosave = 1
```

## Mappings

The plugin provides several `<Plug>` mappings which can be used to create custom
mappings. The following keybindings are provided by default:

| Keybinding             | Description                                                         |
| ---------------------- | ------------------------------------------------------------------- |
| \<Leader>m              | Compile the current buffer.                                        |
| \<Leader>b              | Compile the Main.elm file in the project.                          |
| \<Leader>t              | Runs the tests of the current buffer or 'tests/TestRunner'.                              |
| \<Leader>r              | Opens an elm repl in a subprocess.                                 |
| \<Leader>e              | Shows the detail of the current error or warning.                  |
| \<Leader>d              | Shows the type and docs for the word under the cursor.             |
| \<Leader>w              | Opens the docs web page for the word under the cursor.             |

You can disable these mappings if you want to use your own.

```vim
let g:elm_setup_keybindings = 0
```

## Integration

### [Syntastic](https://github.com/scrooloose/syntastic)

Syntastic support should work out of the box, but we recommend the following settings:

```vim
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1

let g:elm_syntastic_show_warnings = 1
```

### [YouCompleteMe](https://github.com/Valloric/YouCompleteMe)

```vim
let g:ycm_semantic_triggers = {
     \ 'elm' : ['.'],
     \}
```

### [Neocomplete](https://github.com/Shougo/neocomplete.vim)

```vim
call neocomplete#util#set_default_dictionary(
  \ 'g:neocomplete#sources#omni#input_patterns',
  \ 'elm',
  \ '\.')
```

## Usage

```vim
:help elm-vim
```

```vim
let g:elm_jump_to_error = 0
let g:elm_make_output_file = "elm.js"
let g:elm_make_show_warnings = 0
let g:elm_syntastic_show_warnings = 0
let g:elm_browser_command = ""
let g:elm_detailed_complete = 0
let g:elm_format_autosave = 0
let g:elm_format_fail_silently = 0
let g:elm_setup_keybindings = 1
```

* `:ElmMake [filename]` calls `elm-make` with the given file. If no file is given it uses the current file being edited.

* `:ElmMakeMain` attempts to call `elm-make` with "Main.elm".

* `:ElmTest` calls `elm-test` with the given file. If no file is given it runs it in the root of your project. 

* `:ElmRepl` runs `elm-repl`, which will return to vim on exiting.

* `:ElmErrorDetail` shows the detail of the current error in the quickfix window.

* `:ElmShowDocs` queries elm-oracle, then echoes the type and docs for the word under the cursor.

* `:ElmBrowseDocs` queries elm-oracle, then opens docs web page for the word under the cursor.
*
* `:ElmFormat` formats the current buffer with elm-format.

## Screenshots

![errors and completion](https://raw.github.com/elmcast/elm-vim/master/screenshots/syntax_highlighting.png)

## Credits

* Other vim-plugins, thanks for inspiration (elm.vim, ocaml.vim, haskell-vim)
* [Contributors](https://github.com/elmcast/elm-vim/graphs/contributors) of elm-vim

## License

Copyright © Joseph Hager. See `LICENSE` for more details.
