-- fixes occasional black rows due to unrecognized file extension
local setupOptions = {
	override_by_extension = {
		["log"] = {
			--icon = "",
			icon = "",
			color = "#72A0C1",
			name = "Log",
		},
		["txt"] = {
			--icon = "",
			icon = "",
			color = "#F0F8FF",
			name = "Text",
		},

		["xml"] = {
			--icon = "",
			icon = "",
			color = "#FFA500",
			name = "XML",
		},

		["docx"] = {
			icon = "",
			color = "#ddddff",
			name = "DocX",
		},
		["xlsx"] = {
			icon = "",
			color = "#ffff44",
			name = "ExcelSpreadshet",
		},

		["sol"] = {
			--icon = "",
			icon = "",
			color = "#9988aa",
			name = "Solidity",
		},
		["cjs"] = {
			icon = "",
			color = "#CEC02F",
		},
		["svg"] = {
			--icon = "",
			icon = " ",
			color = "#4444FF",
			name = "SVG",
		},
		["prisma"] = {
			icon = "",
			color = "#aaaaaa",
			name = "Prisma",
		},
		["ino"] = {
			icon = " ",
			color = "#22B8A0",
			name = "Arduino",
		},
	},
}

return {
	"nvim-tree/nvim-web-devicons",
	---@module "web-devicons"
	config = function()
		require("nvim-web-devicons").setup(setupOptions)
	end,
}
