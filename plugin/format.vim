" plugin/format.vim

" Prevent multiple loading
if exists('g:loaded_vim_and_embedded_lua_formatter')
  finish
endif
let g:loaded_vim_and_embedded_lua_formatter = 1

" ====================================
" Script-local Formatting Functions
" ====================================

" Function: Format Vimscript blocks (excludes embedded Lua blocks)
function! s:FormatVimscript() abort
  " Save the current view (cursor position, window scroll, etc.)
  let l:view = winsaveview()
  let l:orig = join(getline(1, '$'), "\n")
  let l:inside_lua = v:false
  let l:linecount = line('$')

  for i in range(1, l:linecount)
    let l:line = getline(i)
    " Detect start of a Lua block.
    if l:line =~? '^lua << EOF'
      let l:inside_lua = v:true
    " Detect end of a Lua block.
    elseif l:inside_lua && l:line =~? '^EOF'
      let l:inside_lua = v:false
    endif

    " Only indent lines that are not within a Lua block.
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

" Function: Format Lua blocks using StyLua
function! s:FormatLuaBlocks() abort
  " Save the current view (cursor position, etc.)
  let l:view = winsaveview()
  let l:inside_lua_block = v:false
  let l:lua_code = []
  let l:lines = getline(1, '$')
  let l:formatted_lines = []

  for l:lnum in range(len(l:lines))
    let l:line = l:lines[l:lnum]
    " Detect Lua block start.
    if l:line =~? '^lua << EOF'
      let l:inside_lua_block = v:true
      call add(l:formatted_lines, l:line)
      continue
    " Detect Lua block end.
    elseif l:inside_lua_block && l:line =~? '^EOF'
      let l:formatted_code = system("stylua -", join(l:lua_code, "\n"))
      if v:shell_error
        echomsg "StyLua formatting failed!"
        return
      endif
      " Append the formatted code.
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

" Function: Format both Lua and Vimscript blocks
function! s:FormatBoth() abort
  call s:FormatLuaBlocks()
  call s:FormatVimscript()
endfunction

" ====================================
" Setup for Vim files: Buffer local mappings and commands
" ====================================
function! s:SetupVimFormatter() abort
  " Create buffer-local <Plug> mappings, available only in Vimscript buffers.
  nnoremap <buffer> <silent> <Plug>(vim_and_embedded_lua_formatter_format_both) :call <SID>FormatBoth()<CR>
  nnoremap <buffer> <silent> <Plug>(vim_and_embedded_lua_formatter_format_lua)  :call <SID>FormatLuaBlocks()<CR>
  nnoremap <buffer> <silent> <Plug>(vim_and_embedded_lua_formatter_format_vim)  :call <SID>FormatVimscript()<CR>

  " Explicit commands are exposed by default.
  " Users can opt out by setting:
  "     let g:vim_and_embedded_lua_formatter_expose_commands = 0
  if !exists("g:vim_and_embedded_lua_formatter_expose_commands")
    let g:vim_and_embedded_lua_formatter_expose_commands = 1
  endif

  if g:vim_and_embedded_lua_formatter_expose_commands
    command! -buffer VimLuaFormatBoth call <SID>FormatBoth()
    command! -buffer VimLuaFormatLua call <SID>FormatLuaBlocks()
    command! -buffer VimLuaFormatVim call <SID>FormatVimscript()
  endif
endfunction

" Auto-load mappings and commands only for Vimscript files.
augroup vim_and_embedded_lua_formatter
  autocmd!
  autocmd FileType vim call s:SetupVimFormatter()
augroup END

" ====================================
" Global Formatting Function for Conform.nvim
" ====================================
" This global Vim function is intended for users to register directly within Conform's
" settings. For instance, in your lua init.lua you can set:
"    formatters_by_ft = { vim = { vim.vim_and_embedded_lua_formatter_format } }
" It calls the explicit Vim command that runs all of our formatting logic.
function! VimAndEmbeddedLuaFormatter_Format() abort
  if &filetype !=# 'vim'
    return 0
  endif
  " Call the formatter command (explicit commands are created by default).
  VimLuaFormatBoth
  return 1
endfunction
