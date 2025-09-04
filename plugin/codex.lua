if vim.g.loaded_codex_plugin then
	return
end
vim.g.loaded_codex_plugin = true

local codex = require("codex")

vim.api.nvim_create_user_command("CodexAsk", function(opts)
	local prompt = table.concat(opts.fargs, " ")
	if prompt == "" then
		vim.ui.input({ prompt = "Codex ask: " }, function(input)
			if input and input ~= "" then
				codex.ask(input)
			end
		end)
	else
		codex.ask(prompt)
	end
end, { nargs = "*", desc = "Ask Codex with optional prompt (uses selection as context if present)" })

vim.api.nvim_create_user_command("CodexEdit", function(opts)
	local instr = table.concat(opts.fargs, " ")
	if instr == "" then
		vim.ui.input({ prompt = "Codex edit instruction: " }, function(input)
			if input and input ~= "" then
				codex.edit(input)
			end
		end)
	else
		codex.edit(instr)
	end
end, { nargs = "*", range = true, desc = "Rewrite visual selection per instruction" })

vim.api.nvim_create_user_command("CodexDoc", function()
	require("codex").doc()
end, { desc = "Generate docstring/comments for the thing under cursor (or selection)" })

-- Sensible defaults (override in your config)
vim.keymap.set({ "n", "v" }, "<leader>ca", ":CodexAsk<cr>", { desc = "Codex Ask" })
vim.keymap.set("v", "<leader>ce", ":CodexEdit<cr>", { desc = "Codex Edit (selection)" })
vim.keymap.set("n", "<leader>cd", ":CodexDoc<cr>", { desc = "Codex Doc" })
