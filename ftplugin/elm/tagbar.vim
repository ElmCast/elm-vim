if !executable('ctags')
    finish
elseif globpath(&rtp, 'plugin/tagbar.vim') == ""
    finish
endif

function! s:SetTagbar()
    if !exists("g:tagbar_type_elm")
        let g:tagbar_type_elm = {
                    \ 'ctagstype' : 'elm',
                    \ 'kinds'     : [
                    \ 'c:contants',
                    \ 'f:functions',
                    \ 'p:ports'
                    \ ]
                    \ }
    endif
endfunction

call s:SetTagbar()
