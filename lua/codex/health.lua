local cfg = require("codex.config")

local M = {}

local H = vim.health or {}
local start = H.start or vim.health.report_start
local ok = H.ok or vim.health.report_ok
local warn = H.warn or vim.health.report_warn
local errorf = H.error or vim.health.report_error
local info = H.info or vim.health.report_info

function M.check()
	start("codex.nvim")

	if cfg.current.api_key_env and vim.env[cfg.current.api_key_env] and vim.env[cfg.current.api_key_env] ~= "" then
		ok(("API key found in $%s"):format(cfg.current.api_key_env))
	else
		warn(("Missing API key in $%s"):format(cfg.current.api_key_env or "OPENAI_API_KEY"))
	end

	-- curl presence
	local res = vim.system({ "curl", "--version" }, { text = true }):wait()
	if res.code == 0 then
		ok("curl is available")
	else
		errorf("curl not found in PATH")
	end

	info(("base_url: %s"):format(cfg.current.base_url or "?"))
	info(("model: %s"):format(cfg.current.model or "?"))
end

return M
