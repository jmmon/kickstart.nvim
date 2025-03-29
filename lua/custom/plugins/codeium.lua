vim.g.codeium_no_map_tab = 1 -- disable default bindings
vim.g.codeium_tab_fallback = "\t" -- default \t -- not sure what this does exactly. "The fallback key when there is no suggestion display in `codeium#Accept()`."

vim.g.codeium_filetypes = {
	markdown = false,
}

return {
	"Exafunction/codeium.vim",
	config = function()
		vim.keymap.set("i", "<C-g>", function()
			return vim.fn["codeium#Accept"]()
		end, { expr = true })
	end,
}
