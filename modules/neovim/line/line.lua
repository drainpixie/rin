local ok, navic = pcall(require, "nvim-navic")

vim.api.nvim_set_hl(0, "Normal", { bg = "#ffffff", fg = "#000000" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#000000", bg = "#ffffff" })

local tabline_section = nil
if ok then
	tabline_section = {
		lualine_a = {
			{
				function()
					return navic.get_location()
				end,
				cond = function()
					return navic.is_available()
				end,
			},
		},
	}
end

require("lualine").setup({
	options = {
		theme = {
			normal = {
				a = { bg = "#FFFFFF" },
				b = { bg = "#FFFFFF" },
				c = { bg = "#FFFFFF" },
				x = { bg = "#FFFFFF", fg = "#424242", gui = "bold" },
				y = { bg = "#FFFFFF" },
				z = { bg = "#FFFFFF" },
			},
			insert = {
				x = { bg = "#FFFFFF", fg = "#345C7D", gui = "bold" },
				y = { bg = "#FFFFFF" },
				z = { bg = "#FFFFFF" },
			},
			visual = {
				x = { bg = "#FFFFFF", fg = "#9E7B1C", gui = "bold" },
				y = { bg = "#FFFFFF" },
				z = { bg = "#FFFFFF" },
			},
			replace = {
				x = { bg = "#FFFFFF", fg = "#6A4C7C", gui = "bold" },
				y = { bg = "#FFFFFF" },
				z = { bg = "#FFFFFF" },
			},
			command = {
				x = { bg = "#FFFFFF", fg = "#993333", gui = "bold" },
				y = { bg = "#FFFFFF" },
				z = { bg = "#FFFFFF" },
			},
			inactive = {
				x = { bg = "#FFFFFF", fg = "#555555", gui = "bold" },
				y = { bg = "#FFFFFF" },
				z = { bg = "#FFFFFF" },
			},
		},
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		icons_enabled = true,
		globalstatus = true,
	},
	sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {
			{
				"mode",
				fmt = function(x)
					return x:sub(1, 1):lower()
				end,
			},
		},
		lualine_y = {
			{
				"filetype",
				cond = function()
					local hide = { TelescopePrompt = true, oil_preview = true, toggleterm = true }
					return not hide[vim.bo.filetype]
				end,
			},
			{
				"lsp",
				fmt = function()
					local clients = vim.lsp.get_clients({ bufnr = 0 })
					for _, client in pairs(clients) do
						if client.name ~= "copilot" then
							return "  " .. client.name
						end
					end
					return "  off"
				end,
				color = { bg = "#FFFFFF" },
			},
		},
		lualine_z = { { "branch", icon = "" } },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	tabline = tabline_section,
	extensions = { "oil" },
})
