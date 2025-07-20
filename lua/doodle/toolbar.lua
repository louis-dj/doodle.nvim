local M = {
  buf = nil,
  win = nil,
  ns = nil,
  toolbar_line = "",
}

function M.toggle_toolbar()
  if M.buf and M.win then
    M.close()
  else
    M.create()
  end
end

function M.create()
  local width = vim.api.nvim_win_get_width(0)
  local toolbar_text = "[n] neutral [d] black [r] red [g] green [b] blue [c] clear [q] quit"
  local padding = math.floor((width - #toolbar_text) / 2)
  local toolbar_line = string.rep(" ", padding) .. toolbar_text
  M.toolbar_line = toolbar_line

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 1, 2, false, { toolbar_line })

  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    width = width,
    height = 3,
    row = vim.api.nvim_win_get_height(0) - 1,
    col = 0,
    style = 'minimal',
    border = 'none',
    focusable = false,
    zindex = 100,
  })

  vim.api.nvim_set_option_value('winhighlight', 'Normal:NormalFloat', {
    win = win
  })

  M.ns = vim.api.nvim_create_namespace("doodle_toolbar")
  vim.api.nvim_set_hl(0, "bold", { fg = "#FFFFFF", bold = true })

  M.buf = buf
  M.win = win
end

function M.close()
  vim.api.nvim_win_close(M.win, true)
  vim.api.nvim_buf_delete(M.buf, { force = true })
  M.buf = nil
  M.win = nil
end

function M.update_toolbar(active_color)
  vim.api.nvim_buf_clear_namespace(M.buf, M.ns, 0, -1)
  local index = M.toolbar_line:find(active_color) - 4
  vim.api.nvim_buf_add_highlight(M.buf, M.ns, "bold", 1, index - 1, index + 2)
  vim.api.nvim_buf_add_highlight(M.buf, M.ns, active_color, 1, index, index + 1)
end

return M
