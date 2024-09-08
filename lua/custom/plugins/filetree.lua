-- -- unless migrating, remove deprecated commands from v1.x
-- vim.cmd [[ let g:neo_tree_remove_legacy_commands = 1 ]]

-- return {
--   'nvim-neo-tree/neo-tree.nvim',
--   version = '*',
--   dependencies = {
--     'nvim-lua/plenary.nvim',
--     'nvim-tree/nvim-web-devicons', -- not required but recommended
--     'MunifTanjim/nui.nvim',
--     '3rd/image.nvim',
--   },
--   config = function()
--     require('neo-tree').setup {
--       window = {
--         ['P'] = { 'toggle_preview', config = { use_float = false, use_image_nvim = true } },
--       },
--     }
--   end,
-- }

return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOps
	opts = {},
	-- Optional Dependencies:
	-- dependencies = { { "echasnovski/mini.icons", opts = {} } },
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
	config = function()
		require("oil").setup({
			view_options = {
				show_hidden = true,
			},
		})
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
	end,
}
