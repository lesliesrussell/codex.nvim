local C = {}

C.current = {
	provider = "openai", -- "openai" or "custom"
	base_url = "https://api.openai.com",
	model = "gpt-4o-mini",
	temperature = 0.2,
	max_tokens = 1200,
	api_key_env = "OPENAI_API_KEY",
	system_prompt = "You are Codex, a terse, expert coding assistant. Prefer minimal diffs and runnable code.",
	http = {
		timeout_ms = 60000,
		extra_headers = {}, -- e.g. {["HTTP-Referer"]="...", ["X-Title"]="..."}
	},
	context = {
		include_git_diff = true,
		include_filename = true,
		max_context_chars = 8000,
	},
}

function C.setup(opts)
	if not opts then
		return
	end
	for k, v in pairs(opts) do
		if type(v) == "table" and type(C.current[k]) == "table" then
			for kk, vv in pairs(v) do
				C.current[k][kk] = vv
			end
		else
			C.current[k] = v
		end
	end
end

return C
