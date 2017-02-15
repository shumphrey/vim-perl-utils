" Author: Steven Humphrey <https://github.com/shumphrey/>


" MAPPINGS
if !exists('g:no_perl_maps')
    nnoremap <buffer> <silent> cpp :<C-U>exe perl#change_package_from_filename()<CR>
    nnoremap <buffer> <silent> cpf :<C-U>exec perl#change_filename_from_package()<CR>
endif


if exists('g:perl_utils')
    finish
endif
let g:perl_utils = 1

" utilities

function! s:debug(str) abort
    echohl Error
    echo a:str
    echohl None
endfunction

function! s:get_lib_dir() abort
    " We already know the project dir
    if exists('b:project_lib_dir')
        return b:project_lib_dir
    endif
    " We're in a git work tree set by fugitive
    if exists('b:git_dir')
        let dir = substitute(b:git_dir, '.git', 'lib', '')
    endif

    " TODO: calculate based on PERL5LIB?

    if isdirectory(dir)
        let b:project_lib_dir = dir
        return dir
    endif

    return ''
endfunction

function! perl#get_package_from_file() abort
    let lib_dir = s:get_lib_dir()
    if match(expand('%:p'), lib_dir) < 0
        return ''
    endif

    let rel = substitute(substitute(expand('%:p'), lib_dir, '', ''), '^/', '', '')
    return substitute(substitute(rel, '/', '::', 'g'), '.pm$', '', '')
endfunction

function! perl#get_package_from_buffer() abort
    let lnum = 1
    while lnum <= line('$')
        let line = getline(lnum)
        if line =~ "package\\s\\+[a-zA-Z0-9]"
            let package = substitute(line, '.*package ', '', '')
            return substitute(package, "[^a-zA-Z0-9:]\\+", '', 'g')
        endif
        let lnum = lnum + 1
    endwhile

    return ''
endfunction

" Set the package from the filename
function! perl#change_package_from_filename() abort
    let package = perl#get_package_from_file()
    if strlen(package) < 1
        echom "Cannot find appropriate package line"
        return
    endif

    let current_package = perl#get_package_from_buffer()
    if strlen(current_package) < 1
        echohl Error | echo "Could not work out package from file name" | echohl None
        return
    endif

    if package == current_package
        echom "No change in package name"
        return
    endif

    echom current_package . ' -> ' . package

    execute('%s/' . current_package . '/' . package . '/g')  
endfunction

" Move the file based on package name
function! perl#change_filename_from_package() abort
    throw "file from package"
endfunction