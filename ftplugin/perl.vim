" Author: Steven Humphrey <https://github.com/shumphrey/>

if exists('g:perl_utils')
    finish
endif
let g:perl_utils = 1

" MAPPINGS
if !exists('g:no_perl_maps')
    nnoremap <buffer> <silent> cpp :<C-U>exe perl#change_package_from_filename()<CR>
    nnoremap <buffer> <silent> cpf :<C-U>exe perl#change_filename_from_package()<CR>
    nnoremap <buffer> <silent> gmc :<C-U>exe perl#open_in_metacpan('')<CR>
endif


" Open module/word under cursor in metacpan.org
command! -bang Metacpan :exe perl#open_in_metacpan(<bang>0)
