local ok, cmp = pcall(require, "cmp")

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, fg = "#993333" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, fg = "#9E7B1C" })

if ok then
	cmp.setup.cmdline({ "/", "?" }, {
		sources = {
			{ name = "buffer" },
		},
	})

	cmp.setup.filetype("gitcommit", {
		sources = cmp.config.sources({
			{ name = "cmp_git" },
		}, {
			{ name = "buffer" },
		}),
	})

	cmp.setup.cmdline(":", {
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{ name = "cmdline" },
		}),
	})

	require("copilot").setup()
end
