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
```

## API Key

- Set `OPENAI_API_KEY` in your shell environment (or change `api_key_env`):
  - Temporary: `OPENAI_API_KEY=sk-... nvim` (single run)
  - Persistent (zsh): add `export OPENAI_API_KEY=sk-...` to `~/.zshrc`, then `source ~/.zshrc`
- Verify inside Neovim: `:checkhealth codex` (should report the key is found)
- If launching Neovim from a GUI, ensure the GUI inherits your shell env or set the variable in the GUI’s env.
