# Repository Guidelines

## Project Structure & Module Organization
- `lua/codex/`: Core modules — `init.lua` (public API), `config.lua` (user options), `http.lua` (API calls via curl), `ui.lua` (popups/spinner), `prompt.lua` (prompt building), `health.lua` (checkhealth).
- `plugin/codex.lua`: User commands and default keymaps (`:CodexAsk`, `:CodexEdit`, `:CodexDoc`).
- `doc/codex.txt`: Help doc (`:h codex`).
- `README.md`: Install and minimal setup.

## Build, Test, and Development Commands
- Run locally (from repo root): `nvim --clean +'set rtp+=.'` — loads this plugin from the working tree.
- Load plugin manually: `:runtime plugin/codex.lua` (if RTP not set).
- Health check: `:checkhealth codex` — verifies `curl`, API key env, and config.
- Quick smoke test: `:CodexAsk what can you do?` or visually select code and `:CodexEdit extract function`.

## Coding Style & Naming Conventions
- Language: Lua (Neovim 0.9+ APIs). Prefer small, focused modules under `codex/*`.
- Indentation: tabs (match existing files). Keep lines reasonably short; no trailing whitespace.
- Naming: snake_case locals; module paths `require('codex.<name>')`. Public functions live in `lua/codex/init.lua`.
- Formatting/linting: optional `stylua`/`luacheck` welcome; do not introduce tool-specific configs without discussion.

## Testing Guidelines
- No automated test suite yet. Validate changes by:
  - `:checkhealth codex` to confirm environment.
  - Exercising commands (`:CodexAsk`, `:CodexEdit` with a visual selection, `:CodexDoc`).
  - For network-free work, focus on UI/prompt/config paths; avoid hardcoding real API keys.
- If adding tests, propose approach first (e.g., busted + minimal mocks for `vim.system`).

## Commit & Pull Request Guidelines
- Commits: concise, imperative subject. Conventional Commits are preferred (e.g., `feat: add CodexDoc`, `fix: handle empty response`).
- PRs must include: summary of intent, rationale, before/after behavior, screenshots/gifs for UI where relevant, and any config changes.
- Link related issues and note breaking changes clearly.

## Security & Configuration Tips
- Never commit API keys. The plugin reads from `$OPENAI_API_KEY` (or `config.api_key_env`).
- Keep `http.extra_headers` minimal and avoid logging sensitive data.
- Default model/URL live in `config.lua`; prefer exposing options over hardcoding.
