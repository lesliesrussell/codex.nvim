local cfg = require("codex.config")

local P = {}

function P.context_prefix()
	return "Context (read-only; do not repeat verbatim):\n```\n"
end

function P.ask(user_prompt)
	return ("Answer succinctly. If code is needed, provide a single runnable snippet.\nUser: %s"):format(user_prompt)
end

function P.edit(instruction, filetype, code)
	return table.concat({
		"You are performing a rewrite of the following code. Apply the instruction precisely.",
		"Return ONLY a single fenced code block of the final code. No commentary.",
		("Filetype: %s"):format(filetype or "text"),
		"Instruction:",
		instruction,
		"Code to edit:",
		"```" .. (filetype or "") .. "\n" .. code .. "\n```",
	}, "\n")
end

function P.doc(filetype, snippet)
	local ft = filetype or "text"
	return table.concat({
		"Generate a concise, high-quality docstring (and inline comments if useful) for the snippet.",
		"Prefer the dominant documentation style for the language.",
		"Return plain text; no fenced blocks.",
		("Filetype: %s"):format(ft),
		"Snippet:",
		"```" .. ft .. "\n" .. (snippet or "") .. "\n```",
	}, "\n")
end

function P.extract_code_block(text)
	local start, ft, body = text:match("```([%w_%-%.]*)\n(.-)\n```")
	if body then
		return body
	end
	local b = text:match("```%s*\n(.-)\n```")
	return b
end

-- Lightweight auto-context: filename + staged diff (if any) + a few surrounding lines
function P.auto_context()
	local parts = {}
	if cfg.current.context.include_filename then
		local name = vim.api.nvim_buf_get_name(0)
		if name ~= "" then
			table.insert(parts, ("File: %s"):format(name))
		end
	end

	-- Surrounding lines around cursor
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local s = math.max(row - 20, 1)
	local e = math.min(row + 20, vim.api.nvim_buf_line_count(0))
	local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
	if #lines > 0 then
		table.insert(parts, ("Nearby lines [%d..%d]:\n%s"):format(s, e, table.concat(lines, "\n")))
	end

	if cfg.current.context.include_git_diff then
		local ok, diff = pcall(function()
			local res = vim.system({ "git", "diff", "--staged", "--", "." }, { text = true, cwd = vim.fn.getcwd() })
				:wait()
			if res.code == 0 and res.stdout and res.stdout ~= "" then
				return res.stdout
			end
			return nil
		end)
		if ok and diff then
			table.insert(parts, "Staged diff:\n" .. diff)
		end
	end

	local ctx = table.concat(parts, "\n\n")
	if #ctx > cfg.current.context.max_context_chars then
		ctx = string.sub(ctx, 1, cfg.current.context.max_context_chars)
	end
	return ctx
end

-- Very cheap symbol block: current line + a few above/below
function P.grab_symbol_block()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local s = math.max(row - 10, 1)
	local e = math.min(row + 30, vim.api.nvim_buf_line_count(0))
	local lines = vim.api.nvim_buf_get_lines(0, s - 1, e, false)
	return table.concat(lines, "\n")
end

return P
