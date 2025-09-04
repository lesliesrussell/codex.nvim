local cfg = require("codex.config")

local H = {}

local function env(k)
	return vim.env[k]
end

local function build_curl_args(url, payload)
	local headers = {
		"Content-Type: application/json",
		("Authorization: Bearer %s"):format(env(cfg.current.api_key_env) or ""),
	}
	for k, v in pairs(cfg.current.http.extra_headers or {}) do
		table.insert(headers, ("%s: %s"):format(k, v))
	end
	local args = { "curl", "-sS", "-X", "POST", url }
	for _, h in ipairs(headers) do
		table.insert(args, "-H")
		table.insert(args, h)
	end
	table.insert(args, "--max-time")
	table.insert(args, tostring(math.ceil((cfg.current.http.timeout_ms or 60000) / 1000)))
	local json = vim.json.encode(payload)
	table.insert(args, "-d")
	table.insert(args, json)
	return args
end

local function decode_once(s)
	local ok, obj = pcall(vim.json.decode, s)
	if ok and obj then
		return obj
	end
	return nil, "HTTP/JSON decode failed"
end

function H.chat(messages, cb)
	-- Preflight: require an API key before attempting the request
	local key_env = cfg.current.api_key_env or "OPENAI_API_KEY"
	local key_val = env(key_env)
	if not key_val or key_val == "" then
		return cb(("Missing API key in $%s. Set it (e.g., export %s=...) or configure require('codex').setup({ api_key_env = '...' }). Then run :checkhealth codex."):format(key_env, key_env))
	end
	local url = (cfg.current.base_url:gsub("/+$", "")) .. "/v1/chat/completions"
	local payload = {
		model = cfg.current.model,
		messages = messages,
		temperature = cfg.current.temperature,
		max_tokens = cfg.current.max_tokens,
		stream = false,
	}
	local args = build_curl_args(url, payload)

	vim.system(args, { text = true }, function(res)
		if res.code ~= 0 then
			return cb(("curl exit %d: %s"):format(res.code, res.stderr or res.stdout or "?"))
		end
		local obj, derr = decode_once(res.stdout)
		if not obj then
			return cb(derr or "No JSON")
		end

		if obj.error then
			return cb(("%s (%s)"):format(obj.error.message or "API error", obj.error.type or ""))
		end
		local choice = obj.choices and obj.choices[1]
		local text = choice and choice.message and choice.message.content or ""
		if text == "" then
			return cb("Empty response from provider")
		end
		cb(nil, text)
	end)
end

return H
