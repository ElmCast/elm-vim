if exists('g:loaded_elm')
  finish
endif

let g:loaded_elm = 1

" Default settings
if !exists('g:elm_format_binary')
    let g:elm_format_binary = 'elm-format'
endif


" Mappings
nnoremap <silent> <Plug>(elm-make) :<C-u>call elm#Make()<CR>
nnoremap <silent> <Plug>(elm-make-main) :<C-u>call elm#Make("Main.elm")<CR>
nnoremap <silent> <Plug>(elm-test) :<C-u>call elm#Test()<CR>
nnoremap <silent> <Plug>(elm-repl) :<C-u>call elm#Repl()<CR>
nnoremap <silent> <Plug>(elm-error-detail) :<C-u>call elm#ErrorDetail()<CR>
nnoremap <silent> <Plug>(elm-show-docs) :<C-u>call elm#ShowDocs()<CR>
nnoremap <silent> <Plug>(elm-browse-docs) :<C-u>call elm#BrowseDocs()<CR>
