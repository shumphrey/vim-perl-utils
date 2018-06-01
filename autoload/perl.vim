if exists('g:autoloaded_perl_utils')
    finish
endif
let g:autoloaded_perl_utils = 1

" utilities

function! s:debug(str) abort
    echohl Error | echo a:str | echohl None
endfunction

function! s:get_lib_dir(file) abort
    " We already know the project dir
    if exists('b:project_lib_dir')
        return b:project_lib_dir
    endif

    " loop through the perl5lib to see if this matches a path
    let paths = split($PERL5LIB, ':')
    for path in paths
        if match(a:file, '^' . path) > -1
            return path
        endif
    endfor

    " Guess from file, find first occurrence of /lib/ or lib/ (word boundary)
    let idx = matchend(a:file, "[\</]lib/")
    if idx > -1
        return strpart(a:file, 0, idx)
    endif

    " We're in a git work tree set by fugitive
    if exists('b:git_dir')
        return substitute(b:git_dir, '.git', 'lib', '')
    endif

    return ''
endfunction


function! perl#get_package_from_file() abort
    let file = expand('%:p')
    let lib_dir = s:get_lib_dir(file)
    if match(file, lib_dir) < 0
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
            return substitute(package, "[^a-zA-Z0-9:_]\\+", '', 'g')
        endif
        let lnum = lnum + 1
    endwhile

    return ''
endfunction

" Set the package from the filename
function! perl#change_package_from_filename() abort
    let package = perl#get_package_from_file()
    if strlen(package) < 1
        echohl Error | echo "Could not work out package from file name" | echohl None
        return
    endif

    let current_package = perl#get_package_from_buffer()
    if strlen(current_package) < 1
        echohl Error | echo "Cannot find appropriate package line" | echohl None
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

function! perl#open_in_metacpan(bang) abort
    " TODO: url might need some escaping
    let url = 'https://metacpan.org/pod/' . expand('<cword>')

    if a:bang
        if has('clipboard')
            let @+ = url
        endif
        echomsg url
    elseif exists(':Browse') == 2
        echomsg url|Browse url
    else
        if !exists('g:loaded_netrw')
            runtime! autoload/netrw.vim
        endif
        if exists('*netrw#BrowseX')
            echomsg url|call netrw#BrowseX(url, 0)
        else
            echomsg url|call netrw#NetrwBrowseX(url, 0)
        endif
    endif
    return 1
endfunction
