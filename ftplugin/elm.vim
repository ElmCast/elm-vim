" plugin for Elm (http://elm-lang.org/)

if exists('b:did_ftplugin')
  finish
endif

let b:did_ftplugin = 1

" Commands
command -buffer -nargs=? -complete=file ElmMake call elm#Make(<f-args>)
command -buffer ElmMakeMain call elm#Make("Main.elm")
command -buffer -nargs=? -complete=file ElmTest call elm#Test(<f-args>)
command -buffer ElmRepl call elm#Repl()

" Mappings
nnoremap <silent> <Plug>(elm-make) :<C-u>call elm#Make()<CR>
nnoremap <silent> <Plug>(elm-make-main) :<C-u>call elm#Make("Main.elm")<CR>
nnoremap <silent> <Plug>(elm-test) :<C-u>call elm#Test()<CR>
nnoremap <silent> <Plug>(elm-repl) :<C-u>call elm#Repl()<CR>
