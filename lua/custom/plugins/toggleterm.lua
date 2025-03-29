-- Function to check clipboard with retries
local function getRelativeFilepath(retries, delay)
	local relative_filepath
	for i = 1, retries do
		relative_filepath = vim.fn.getreg("+")
		if relative_filepath ~= "" then
			return relative_filepath -- Return filepath if clipboard is not empty
		end
		vim.loop.sleep(delay) -- Wait before retrying
	end
	return nil -- Return nil if clipboard is still empty after retries
end

-- Function to handle editing from Lazygit
function LazygitEdit(original_buffer)
	local current_bufnr = vim.fn.bufnr("%")
	local channel_id = vim.fn.getbufvar(current_bufnr, "terminal_job_id")

	if not channel_id then
		vim.notify("No terminal job ID found.", vim.log.levels.ERROR)
		return
	end

	vim.fn.chansend(channel_id, "\15") -- \15 is <c-o>
	vim.cmd("close") -- Close Lazygit

	local relative_filepath = getRelativeFilepath(5, 50)
	if not relative_filepath then
		vim.notify("Clipboard is empty or invalid.", vim.log.levels.ERROR)
		return
	end

	local winid = vim.fn.bufwinid(original_buffer)

	if winid == -1 then
		vim.notify("Could not find the original window.", vim.log.levels.ERROR)
		return
	end

	vim.fn.win_gotoid(winid)
	vim.cmd("e " .. relative_filepath)
end

return {
	"akinsho/toggleterm.nvim",
	config = function()
		-- for keybinds
		local opts = { noremap = true, silent = true }

		require("toggleterm").setup({
			size = function(term)
				-- Horizontal termials:
				if term.direction == "horizontal" then
					local min_lines = 7
					local max_lines = 24
					local window_height = vim.api.nvim_win_get_height(0)
					-- local buffer_height = vim.api.nvim_buf_line_count(0)
					-- local window_height = vim.api.winheight('%')
					local desired_percent = 0.3
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
					return 10 + (vim.o.columns * 0.30)
					-- elseif term.direction == "float" then
					--return 0.9 * vim.api.nvim_win_get_height(0)
				end
			end,
			open_mapping = [[<c-\>]],
			hide_numbers = true,
			shade_filetypes = {},
			autochdir = false,
			shade_terminals = true, -- add a shading to the terminal
			shading_factor = "-15",

			start_in_insert = true,
			insert_mappings = true,
			terminal_mapings = true,

			persist_size = true,
			-- hidden = true,
			persist_mode = false,
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
			highlights = {
				FloatBorder = {
					guifg = "MediumPurple3",
				},
			},
			on_open = function(term)
				-- WORKS! jump out of terminal with double ctrl-k (up) or double ctrl-h (left)
				vim.api.nvim_set_keymap("t", "<c-k><c-k>", "<c-[><c-[><c-w><c-k>", { silent = true }) -- to jump out
				vim.api.nvim_set_keymap("t", "<c-h><c-h>", "<c-[><c-[><c-w><c-h>", { silent = true })
			end,
		})

		-- set up special float terminal for LazyGit
		local Terminal = require("toggleterm.terminal").Terminal

		local lazygit = Terminal:new({
			count = 0, -- make lazygit use number 0 terminal (10)
			cmd = "lazygit",
			dir = "git_dir",
			hidden = true, -- should make it "hidden" from normal open commands....
			persist_size = true,
			persist_mode = false,
			direction = "float",
			float_opts = {
				-- 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
				border = "curved",
			},
			on_open = function(term) -- for lazy git only!
				vim.cmd("startinsert!")
				-- doesn't seem to be needed:
				-- vim.api.nvim_buf_set_keymap(term.bufnr, "n", "qq", "<cmd>close<CR>", opts)
				-- vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<Esc><Esc>", "<cmd>close<CR>", opts)
				-- vim.api.nvim_buf_set_keymap(term.bufnr, "n", "<leader>g", "<cmd>close<CR>", opts)
				--
				-- vim.api.nvim_buf_set_keymap(term.bufnr, "i", "qq", "<cmd>close<CR>", opts)
				-- vim.api.nvim_buf_set_keymap(term.bufnr, "i", "<Esc><Esc>", "<cmd>close<CR>", opts)
				-- vim.api.nvim_buf_set_keymap(term.bufnr, "i", "<leader>g", "<cmd>close<CR>", opts)

				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "qq", "<cmd>close<CR>", opts)
				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc><Esc>", "<cmd>close<CR>", opts)
				vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<leader>g", "<cmd>close<CR>", opts)
			end,
			on_close = function(term) ---@diagnostic disable-line unused-local
				vim.cmd("startinsert!")
			end,
		})

		-- set up lazygit toggle
		-- set up keymap to allow opening selected file as buffer from lazygit via <C-e>
		-- https://github.com/kdheepak/lazygit.nvim/issues/22#issuecomment-1815426074
		function _lazygit_toggle() ---@diagnostic disable-line
			-- get current buffer to pass in as original_buffer (??)
			local current_buffer = vim.api.nvim_get_current_buf()

			-- toggle lazygit, save the term
			-- so we can set our keymap for inside lazygit (that term buffer)
			local term = lazygit:toggle()

			-- new keymap to open selected file as buffer
			vim.api.nvim_buf_set_keymap(
				term.bufnr,
				"t",
				"<c-e>",
				string.format([[<Cmd>lua LazygitEdit(%d)<CR>]], current_buffer),
				opts
			)
		end
		vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", opts) -- to open
		--

		vim.cmd([[

			" For commands used in terminal mode, I removed commands which start with <leader> because they interfere with typing
			"==================================="
			" (#-)ctrl-\ => open last/default terminal #n
			" ctrl-\ => toggle all open terminals (close all, re-open all)
			"==================================="
			autocmd TermEnter term://*toggleterm#*
			\ tnoremap <silent><c-\> <Cmd>exe v:count1 . "ToggleTerm direction=horizontal"<CR>

			nnoremap <silent><c-\> <Cmd>exe v:count1 . "ToggleTerm direction=horizontal"<CR>

			tnoremap <silent><c-\> <Cmd>exe v:count1 . "ToggleTerm"<CR>
			tnoremap <silent>qq <Cmd>exe v:count1 . "ToggleTerm"<CR>


			"==================================="
			" v<c-\> to open vertical
			"==================================="
			autocmd TermEnter term://*toggleterm#*
			\ tnoremap <silent>v<c-\> <Cmd>exe v:count1 . "ToggleTerm direction=vertical"<CR>

			" these should be for closing??
			nnoremap <silent>v<c-\> <Cmd>exe v:count1 . "ToggleTerm direction=vertical"<CR>


			"==================================="
			" v<c-\> to open vertical
			"==================================="
			autocmd TermEnter term://*toggleterm#*
			\ tnoremap <silent>f<c-\> <Cmd>exe v:count1 . "ToggleTerm direction=float"<CR>

			" these should be for closing??
			nnoremap <silent>f<c-\> <Cmd>exe v:count1 . "ToggleTerm direction=float"<CR>

		]])
		--
		-- inoremap <silent><c-/> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>
	end,
}
