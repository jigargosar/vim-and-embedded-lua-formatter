Vim and Embedded Lua Formatter

Author: Jigar
License: MIT
Version: 1.0

This plugin provides formatting functions for Vimscript files while preserving embedded Lua blocks. Lua blocks are formatted using StyLua.

--------------------------------------------------------
Table of Contents
--------------------------------------------------------

1. Introduction
2. Installation
3. Commands & Mappings
4. Conform.nvim Integration
5. Configuration
6. Troubleshooting

--------------------------------------------------------
1. Introduction
--------------------------------------------------------

This plugin formats Vimscript files while preserving embedded Lua blocks. It ensures:

- Vimscript code is properly indented while skipping Lua blocks.
- Lua blocks are formatted using StyLua before being inserted back.
- Commands and mappings allow easy formatting on demand.

--------------------------------------------------------
2. Installation
--------------------------------------------------------

Use a plugin manager:

Plug 'jigargosar/vim-embedded-lua-formatter'

Or manually copy files into `~/.vim`.

--------------------------------------------------------
3. Commands & Mappings
--------------------------------------------------------

Commands:

- `:VimLuaFormatBoth` - Format both Vimscript and Lua blocks.
- `:VimLuaFormatVim` - Format only Vimscript blocks.
- `:VimLuaFormatLua` - Format only Lua blocks.

Mappings:

Buffer-local mappings are automatically set for Vimscript buffers:

- `<Plug>(vim_and_embedded_lua_formatter_format_both)`
- `<Plug>(vim_and_embedded_lua_formatter_format_vim)`
- `<Plug>(vim_and_embedded_lua_formatter_format_lua)`

--------------------------------------------------------
4. Conform.nvim Integration
--------------------------------------------------------

This plugin integrates with Conform.nvim for formatting Vimscript files. Example configuration:

require("conform").setup({
formatters = {
vimscript_formatter = {
format = function(bufnr)
return vim.fn.VimAndEmbeddedLuaFormatter_Format() == 1
end,
},
},
formatters_by_ft = {
vim = { "vimscript_formatter", lsp_format = "fallback" },
},
})

--------------------------------------------------------
5. Configuration
--------------------------------------------------------

Users can configure whether explicit commands are exposed:

let g:vim_and_embedded_lua_formatter_expose_commands = 0

--------------------------------------------------------
6. Troubleshooting
--------------------------------------------------------

- StyLua Formatting Fails: Ensure `stylua` is installed and available in `$PATH`.
- Indentation Issues: Check if the filetype is correctly detected.

--------------------------------------------------------

Enjoy Vim and Lua formatting!
