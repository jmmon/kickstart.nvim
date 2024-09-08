return {
	"akinsho/toggleterm.nvim",
	config = function()
		require("toggleterm").setup({
			size = function(term)
				-- Horizontal termials:
				if term.direction == "horizontal" then
					local min_lines = 6
					local max_lines = 20
					local window_height = vim.api.nvim_win_get_height(0)
					-- local buffer_height = vim.api.nvim_buf_line_count(0)
					-- local window_height = vim.api.winheight('%')
					local desired_percent = 0.2
					local percent = desired_percent * 2 -- for some reason we have to multiply by 2
					return math.min(
						max_lines,
						math.max(
							min_lines,
							(window_height * percent)
							-- (buffer_height * percent)
						)
					)
					-- Vertical termials:
				elseif term.direction == "vertical" then
					return 15 + (vim.o.columns * 0.30)
				end
			end,
			open_mapping = [[<c-\>]],
			hide_numbers = true,
			shade_filetypes = {},
			autochdir = false,
			shade_terminals = false, -- add a shading to the terminal
			--shading_factor = '-15',
			start_in_insert = true,
			insert_mappings = true,
			terminal_mapings = true,
			persist_size = true,
			persist_mode = true,
			direction = "horizontal", -- | "vertical" | "float"
			close_on_exit = false, -- when process exists, close terminal
			shell = vim.o.shell,
			auto_scroll = true,
			float_opts = {
				-- only relevant if direction is set to "float"
				border = "curved",
				winblend = 3,
				-- width = <value>, height = <value>,
			},
			winbar = {
				enabled = false,
				name_formatter = function(term) -- term : Terminal
					return term.name
				end,
			},
		})

		-- for keybinds
		local opts = { noremap = true, silent = true }
		-- set up special float terminal for LazyGit
		local Terminal = require("toggleterm.terminal").Terminal

		local lazygit = Terminal:new({
			cmd = "lazygit",
			dir = "git_dir",
			hidden = true,
			direction = "float",
			float_opts = {
				border = "double",
			},
			on_open = function(term)
				vim.cmd("startinsert!")
				vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", opts) -- for lazy git only!
			end,
			on_close = function(term)
				vim.cmd("startinsert!")
			end,
		})

		--set up lazygit toggle
		function _lazygit_toggle()
			lazygit:toggle()
		end
		vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", opts)

		-- (#-)ctrl-\ => open last/default terminal #n
		-- ctrl-\ => toggle all open terminals (close all, re-open all)
		vim.cmd([[
			autocmd TermEnter term://*toggleterm#*
			\ tnoremap <silent><c-\> <Cmd>exe v:count1 . "ToggleTerm"<CR>

			nnoremap <silent><c-\> <Cmd>exe v:count1 . "ToggleTerm"<CR>
			tnoremap <silent><c-\> <Cmd>exe v:count1 . "ToggleTerm"<CR>
			tnoremap <silent>qq <Cmd>exe v:count1 . "ToggleTerm"<CR>
		]])
		--
		-- inoremap <silent><c-/> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>

		-- (#-)<leader>b => open horizontal terminal #n
		-- (I think:) when in terminal, set normal and terminal mappings to <leader>b for closing the terminal
		vim.cmd([[
			autocmd TermEnter term://*toggleterm#*
			\ tnoremap <silent><leader>b <Cmd>exe v:count1 . "ToggleTerm direction=horizontal"<CR>

			nnoremap <silent><leader>b <Cmd>exe v:count1 . "ToggleTerm direction=horizontal"<CR>
			" For commands used in terminal mode, I removed commands which start with <leader> because they interfere with typing
			tnoremap <silent><c-\> <Cmd>exe v:count1 . "ToggleTerm direction=horizontal"<CR>
			tnoremap <silent>qq <Cmd>exe v:count1 . "ToggleTerm direction=horizontal"<CR>
		]])

		-- (#-)<leader>v => open vertical terminal #n
		vim.cmd([[
			autocmd TermEnter term://*toggleterm#*
			\ tnoremap <silent><leader>v <Cmd>exe v:count1 . "ToggleTerm direction=vertical"<CR>

			" these should be for closing??
			nnoremap <silent><leader>v <Cmd>exe v:count1 . "ToggleTerm direction=vertical"<CR>
			" For commands used in terminal mode, I removed commands which start with <leader> because they interfere with typing
			tnoremap <silent><c-\> <Cmd>exe v:count1 . "ToggleTerm direction=vertical"<CR>
			tnoremap <silent>qq <Cmd>exe v:count1 . "ToggleTerm direction=vertical"<CR>
		]])

		-- (#-)<leader>f => open float terminal #n
		vim.cmd([[
			autocmd TermEnter term://*toggleterm#*
			\ tnoremap <silent><leader>f <Cmd>exe v:count1 . "ToggleTerm direction=float"<CR>

			nnoremap <silent><leader>f <Cmd>exe v:count1 . "ToggleTerm direction=float"<CR>
			" For commands used in terminal mode, I removed commands which start with <leader> because they interfere with typing
			tnoremap <silent><c-\> <Cmd>exe v:count1 . "ToggleTerm direction=float"<CR>
			tnoremap <silent>qq <Cmd>exe v:count1 . "ToggleTerm direction=float"<CR>
		]])
	end,
}
