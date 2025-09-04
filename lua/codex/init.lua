local M = {}
local cfg = require("codex.config")
local http = require("codex.http")
local ui = require("codex.ui")
local pr = require("codex.prompt")

function M.setup(opts)
	cfg.setup(opts or {})
end

-- Utility: grab visual selection if any (lines, text)
local function get_selection_or_nil()
	local m = vim.fn.mode()
	if m ~= "v" and m ~= "V" and m ~= "\22" then
		return nil
	end
	local _, ls, cs, _ = unpack(vim.fn.getpos("'<"))
	local _, le, ce, _ = unpack(vim.fn.getpos("'>"))
	if ls > le or (ls == le and cs > ce) then
		ls, le, cs, ce = le, ls, ce, cs
	end
	local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
	if #lines == 0 then
		return nil
	end
	lines[#lines] = string.sub(lines[#lines], 1, ce)
	lines[1] = string.sub(lines[1], cs)
	return table.concat(lines, "\n"), { ls = ls, le = le }
end

local function build_messages(user_prompt, context_text)
	local sys = cfg.current.system_prompt
	local messages = {}
	if sys and sys ~= "" then
		table.insert(messages, { role = "system", content = sys })
	end
	if context_text and context_text ~= "" then
		table.insert(messages, { role = "user", content = pr.context_prefix() .. context_text })
	end
	table.insert(messages, { role = "user", content = user_prompt })
	return messages
end

function M.ask(user_prompt)
	local sel = get_selection_or_nil()
	local ctx_text = sel and select(1, sel) or pr.auto_context() -- git diff + filetype hints
	local messages = build_messages(pr.ask(user_prompt), ctx_text)

	ui.show_spinner("Codex: thinking…")
	http.chat(messages, function(err, text)
		ui.close_spinner()
		if err then
			return ui.echo_err(err)
		end
		ui.show_output(text, "Codex Answer")
	end)
end

function M.edit(instruction)
	local sel_text, span = get_selection_or_nil()
	if not sel_text then
		return ui.echo_err("CodexEdit requires a visual selection.")
	end
	local prompt = pr.edit(instruction, vim.bo.filetype, sel_text)
	local messages = build_messages(prompt, nil)

	ui.show_spinner("Codex: editing…")
	http.chat(messages, function(err, text)
		ui.close_spinner()
		if err then
			return ui.echo_err(err)
		end
		local replacement = pr.extract_code_block(text) or text
		local lines = vim.split(replacement, "\n", { plain = true })
		vim.api.nvim_buf_set_lines(0, span.ls - 1, span.le, false, lines)
		ui.echo_ok("Applied Codex edit.")
	end)
end

function M.doc()
	local sel_text = get_selection_or_nil()
	local snippet = sel_text and select(1, sel_text) or pr.grab_symbol_block()
	local prompt = pr.doc(vim.bo.filetype, snippet)
	local messages = build_messages(prompt, nil)

	ui.show_spinner("Codex: documenting…")
	http.chat(messages, function(err, text)
		ui.close_spinner()
		if err then
			return ui.echo_err(err)
		end
		ui.insert_above_cursor(text)
		ui.echo_ok("Inserted documentation.")
	end)
end

return M
