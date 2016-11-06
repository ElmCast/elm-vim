if !executable('ctags')
    finish
elseif globpath(&rtp, 'plugin/tagbar.vim') == ""
    finish
endif

if !exists("g:elm_ctags_config")
	let g:elm_ctags_config = expand('<sfile>:p:h:h') . '/elm/ctags/elm.cnf'
endif

if !exists("g:elm_ctags_target_dirs")
	let g:elm_ctags_target_dirs = './elm-stuff ./src'
endif

if !exists("g:elm_ctags_exe")
	let g:elm_ctags_exe = 'ctags-exuberant'
endif

function! GenerateElmTags()
    exec system(g:elm_ctags_exe . ' -R --fields=+l --options=' . g:elm_ctags_config . ' ' . g:elm_ctags_target_dirs)
endfunction
command! ElmGenerateTags call GenerateElmTags()

let g:Plugin_install_dir = expand('<sfile>:p:h:h')
function! s:SetTagbar()
    if !exists("g:tagbar_type_elm")
        let g:tagbar_type_elm = {
                    \ 'ctagstype' : 'elm',
                    \ 'deffile' : g:elm_ctags_config,
                    \ 'kinds'     : [
                    \ 'm:module',
                    \ 'i:imports',
                    \ 't:types',
                    \ 'C:constructors',
                    \ 'c:constants',
                    \ 'f:functions',
                    \ 'p:ports'
                    \ ]
                    \ }
    endif
endfunction

call s:SetTagbar()
