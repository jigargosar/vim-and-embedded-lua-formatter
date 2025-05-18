if exists('g:loaded_vim_lua_format')
    finish
endif
let g:loaded_vim_lua_format = 1

" Format Vimscript blocks
function! s:FormatVimscript()
    let l:view = winsaveview()
    let l:orig = join(getline(1, '$'), "\n")
    let l:inside_lua = v:false
    let l:linecount = line('$')

    for i in range(1, l:linecount)
        let l:line = getline(i)
        if l:line =~? '^lua << EOF'
            let l:inside_lua = v:true
        elseif l:inside_lua && l:line =~? '^EOF'
            let l:inside_lua = v:false
        endif

        if !l:inside_lua
            execute i . 'normal! =='
        endif
    endfor

    let l:new = join(getline(1, '$'), "\n")
    if l:new == l:orig
        set nomodified
    endif

    call winrestview(l:view)
endfunction

command! FormatVimscript call s:FormatVimscript()

" Format Lua blocks using StyLua
function! s:FormatLuaBlocks()
    let l:view = winsaveview()
    let l:inside_lua_block = v:false
    let l:lua_code = []
    let l:lines = getline(1, '$')
    let l:formatted_lines = []

    for l:lnum in range(len(l:lines))
        let l:line = l:lines[l:lnum]
        if l:line =~? '^lua << EOF'
            let l:inside_lua_block = v:true
            call add(l:formatted_lines, l:line)
            continue
        elseif l:inside_lua_block && l:line =~? '^EOF'
            let l:formatted_code = system("stylua -", join(l:lua_code, "\n"))
            if v:shell_error
                echomsg "StyLua formatting failed!"
                return
            endif
            call extend(l:formatted_lines, split(l:formatted_code, "\n"))
            call add(l:formatted_lines, l:line)
            let l:inside_lua_block = v:false
            let l:lua_code = []
            continue
        endif

        if l:inside_lua_block
            call add(l:lua_code, l:line)
        else
            call add(l:formatted_lines, l:line)
        endif
    endfor

    call setline(1, l:formatted_lines)
    call winrestview(l:view)
endfunction

command! FormatLuaBlocks call s:FormatLuaBlocks()

" Format both Lua and Vimscript blocks
function! s:FormatBoth()
    call s:FormatLuaBlocks()
    call s:FormatVimscript()
endfunction

command! FormatBoth call s:FormatBoth()
