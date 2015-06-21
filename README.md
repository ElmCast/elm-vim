# elm-vim [![Release](https://img.shields.io/github/release/ajhager/elm-vim.svg?style=flat-square)](https://github.com/ajhager/elm-vim/releases)

Elm (elm-lang) support for Vim.

## Features

* Improved Syntax highlighting
* Improved Indentation
* Run commands like elm-make

## Install

Elm-vim follows the standard runtime path structure, so you should use a common
and well known plugin manager to install it. Do not use elm-vim with other Elm
plugins.

*  [Pathogen](https://github.com/tpope/vim-pathogen)
  * `git clone https://github.com/ajhager/elm-vim.git ~/.vim/bundle/elm-vim`
*  [vim-plug](https://github.com/junegunn/vim-plug)
  * `Plug 'ajhager/elm-vim'`
*  [NeoBundle](https://github.com/Shougo/neobundle.vim)
  * `NeoBundle 'ajhager/elm-vim'`
*  [Vundle](https://github.com/gmarik/vundle)
  * `Plugin 'ajhager/elm-vim'`

Please be sure all necessary binaries are installed (such as `elm-make`, `elm-doc`,
`elm-reactor`, etc..) from http://elm-lang.org/.

## Usage

Many of the [features](#features) are enabled by default. There are no
additional settings needed. All usages and commands are listed in
`doc/elm-vim.txt`.

    :help elm-vim

## Indentation

The current indentation function is still rough, but should work for a lot of cases. It is not always possible to know the perfect indentation level just from context, but we should be able to generate a list of candidates.

## Credits

* Other vim-plugins, thanks for inspiration (elm.vim, ocaml.vim, haskell-vim)
* [Contributors](https://github.com/ajhager/elm-vim/graphs/contributors) of elm-vim

## License

The BSD 3-Clause License - see `LICENSE` for more details
