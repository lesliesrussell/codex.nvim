local U = {}

-- Ensure UI mutations run on the main loop (not fast events)
local function on_main(fn)
  if vim.in_fast_event() then
    vim.schedule(fn)
  else
    fn()
  end
end

local spinner_timer, spinner_ns, spinner_buf, spinner_win

function U.show_output(text, title)
  on_main(function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = "markdown"
    local lines = vim.split(text, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.6)
    local row = math.floor((vim.o.lines - height) / 2 - 1)
    local col = math.floor((vim.o.columns - width) / 2)
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      style = "minimal",
      border = "rounded",
      width = width,
      height = height,
      row = row,
      col = col,
      title = title or "Codex",
    })
    vim.keymap.set("n", "q", function()
      pcall(vim.api.nvim_win_close, win, true)
    end, { buffer = buf, nowait = true })
  end)
end

function U.insert_above_cursor(text)
  on_main(function()
    local row = unpack(vim.api.nvim_win_get_cursor(0))
    local lines = vim.split(text, "\n", { plain = true })
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
  end)
end

function U.echo_err(msg)
  on_main(function()
    vim.notify("[Codex] " .. msg, vim.log.levels.ERROR)
  end)
end
function U.echo_ok(msg)
  on_main(function()
    vim.notify("[Codex] " .. msg, vim.log.levels.INFO)
  end)
end

local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

function U.show_spinner(title)
  if spinner_timer then
    return
  end
  on_main(function()
    spinner_ns = vim.api.nvim_create_namespace("codex_spinner")
    spinner_buf = vim.api.nvim_get_current_buf()
  end)
  local i = 1
  spinner_timer = vim.uv.new_timer()
  spinner_timer:start(0, 80, function()
    vim.schedule(function()
      if not spinner_buf or not vim.api.nvim_buf_is_valid(spinner_buf) then
        return
      end
      local msg = string.format(" %s %s", frames[i], title or "working…")
      vim.api.nvim_buf_clear_namespace(spinner_buf, spinner_ns, 0, -1)
      vim.api.nvim_buf_set_extmark(spinner_buf, spinner_ns, 0, 0, {
        virt_text = { { msg, "Comment" } },
        virt_text_pos = "right_align",
      })
      i = (i % #frames) + 1
    end)
  end)
end

function U.close_spinner()
  if spinner_timer then
    spinner_timer:stop()
    spinner_timer:close()
    spinner_timer = nil
  end
  local buf, ns = spinner_buf, spinner_ns
  spinner_ns, spinner_buf = nil, nil
  on_main(function()
    if buf and vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
    end
  end)
end

return U
