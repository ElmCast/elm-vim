if !executable('ctags')
    finish
elseif globpath(&runtimepath, 'plugin/tagbar.vim') ==? ''
    finish
endif

function! s:SetTagbar()
    if !exists('g:tagbar_type_elm')
        let g:tagbar_type_elm = {
                    \ 'ctagstype' : 'elm',
                    \ 'kinds'     : [
                    \ 'c:constants',
                    \ 'f:functions',
                    \ 'p:ports'
                    \ ]
                    \ }
    endif
endfunction

call s:SetTagbar()
