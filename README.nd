# codex.nvim

Terse, fast Neovim interface to Codex-style chat/edit/doc flows.

## Install (lazy.nvim)

```lua
{ "yourname/codex.nvim",
  config = function()
    require("codex").setup({
      base_url = "https://api.openai.com",
      model = "gpt-4o-mini",
      api_key_env = "OPENAI_API_KEY",
      http = { timeout_ms = 90000 },
      context = { include_git_diff = true, include_filename = true, max_context_chars = 12000 },
    })
  end
}
