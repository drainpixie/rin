local M = {}

M.config = {
	filetypes = { "ori" },
	auto_sort = true,
	sort_by_length = true,
	chevron = "› ",
	max_summary_length = 40,
	fold_level = 0,
	enabled = true,
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	if M.config.enabled then
		M.init()
	end
end

function _G.OriFoldExpr(lnum)
	local line = vim.fn.getline(lnum)
	if line:match("^#") then
		local hashes = line:match("^(#+)")
		return ">" .. #hashes
	end
	if line:match("^<!%-%-.*vim:") then
		return ">1"
	end
	return "="
end

function _G.OriFoldText()
	local folded_lines = (function()
		local count = 0
		for lnum = vim.v.foldstart, vim.v.foldend do
			if vim.fn.getline(lnum):match("%S") then
				count = count + 1
			end
		end
		return count
	end)()

	folded_lines = folded_lines - 1

	local first_line = vim.fn.getline(vim.v.foldstart)
	local label, summary

	if first_line:match("^#") then
		label = first_line:gsub("^#+%s*", "")

		local items = {}
		for lnum = vim.v.foldstart + 1, vim.v.foldend do
			local l = vim.fn.getline(lnum)
			if l:match("%S") and not l:match("^#") then
				local cleaned = l:gsub("^%s*[-*%d%.]+%s*", ""):gsub("^%s*", "")
				if cleaned ~= "" then
					table.insert(items, cleaned)
				end
			end
		end

		summary = table.concat(items, ", ")
		if #summary > M.config.max_summary_length then
			summary = summary:sub(1, M.config.max_summary_length - 3) .. "..."
		end

		if summary ~= "" then
			label = label .. " — " .. summary
		end
	elseif first_line:match("^<!%-%-.*vim:") then
		label = "Modeline"
		folded_lines = folded_lines + 1
	else
		label = "[Folded]"
	end

	local text = M.config.chevron .. label
	local linestr = folded_lines .. " items"

	local win_width = vim.api.nvim_win_get_width(0)
	local pad = win_width - vim.fn.strdisplaywidth(text) - #linestr
	if pad < 1 then
		pad = 1
	end

	return text .. string.rep(" ", pad) .. linestr
end

local function is_header(line)
	return line:match("^#")
end

local function is_modeline(line)
	return line:match("^%s*<!%-%-+%s*vim:")
end

local function autosort_markdown_sections(bufnr)
	if not M.config.auto_sort then
		return
	end

	local total = vim.api.nvim_buf_line_count(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, total, false)

	local i = 1
	while i <= #lines do
		local line = lines[i]
		if is_header(line) then
			local start_idx = i + 1
			local end_idx = start_idx

			while end_idx <= #lines do
				local l = lines[end_idx]
				if is_header(l) or is_modeline(l) then
					break
				end
				end_idx = end_idx + 1
			end

			local body = {}
			for j = start_idx, end_idx - 1 do
				if lines[j]:match("%S") then
					table.insert(body, lines[j])
				end
			end

			if #body > 1 then
				if M.config.sort_by_length then
					table.sort(body, function(a, b)
						return #a < #b
					end)
				else
					table.sort(body)
				end

				local k = 1
				for j = start_idx, end_idx - 1 do
					if lines[j]:match("%S") then
						lines[j] = body[k]
						k = k + 1
					end
				end
			end

			i = end_idx
		else
			i = i + 1
		end
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

local function apply_folding_settings(bufnr)
	vim.api.nvim_buf_call(bufnr, function()
		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "v:lua.OriFoldExpr(v:lnum)"
		vim.opt_local.foldtext = "v:lua.OriFoldText()"
		vim.opt_local.foldenable = true
		vim.opt_local.foldlevel = M.config.fold_level
		vim.opt_local.foldminlines = 1
	end)
end

function M.init()
	local group = vim.api.nvim_create_augroup("OriFold", { clear = true })

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = M.config.filetypes,
		callback = function(args)
			apply_folding_settings(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		pattern = { "*.ori" },
		callback = function(args)
			autosort_markdown_sections(args.buf)
		end,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			vim.api.nvim_set_hl(0, "Folded", { link = "Normal" })
		end,
	})

	vim.api.nvim_set_hl(0, "Folded", { link = "Normal" })
	vim.opt.fillchars:append({ eob = " " })

	local buftype = vim.api.nvim_buf_get_option(0, "filetype")
	if vim.tbl_contains(M.config.filetypes, buftype) then
		apply_folding_settings(0)
	end
end

vim.api.nvim_create_user_command("OriFoldToggle", function()
	M.config.enabled = not M.config.enabled
	if M.config.enabled then
		M.init()
		print("Ori folding enabled")
	else
		vim.opt_local.foldmethod = "manual"
		print("Ori folding disabled")
	end
end, {})

vim.api.nvim_create_user_command("OriFoldSort", function()
	autosort_markdown_sections(vim.api.nvim_get_current_buf())
	print("Ori sections sorted")
end, {})

vim.defer_fn(function()
	if not M._setup_called then
		M.setup()
	end
end, 0)

return M
