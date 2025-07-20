local colors = require("doodle.colors")

local M = {
  buf = nil,
  win = nil,
  pen = '█',
  mode = 'draw',
  -- pen = '00',
  -- pen = '0',
}

function M.toggle_fill_mode()
  if M.mode == 'fill' then
    M.mode = 'draw'
  else
    M.mode = 'fill'
  end
end

function M.toggle_canvas()
  if M.buf and M.win then
    M.close()
    return M.buf
  else
    M.create()
    return M.buf
  end
end

function M.create()
  local buf = vim.api.nvim_create_buf(true, false)
  local width = vim.api.nvim_win_get_width(0)
  local height = vim.api.nvim_win_get_height(0)

  local lines = {}
  for _ = 1, height do
    table.insert(lines, string.rep(" ", width))
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = 0,
    col = 0,
    style = "minimal",
    border = 'none',
    zindex = 10,
  })

  vim.api.nvim_set_option_value('winhighlight', 'Normal:Normal,Visual:None', {
    win = win
  })

  M.buf = buf
  M.win = win
end

function M.close()
  vim.api.nvim_win_close(M.win, true)
  vim.api.nvim_buf_delete(M.buf, { force = true })
  M.buf = nil
  M.win = nil
end

function M.handle_event(row, col)
  if M.mode == 'draw' then
    M.draw(row, col)
  elseif M.mode == 'fill' then
    M.fill(row, col)
  else
  end
end

function M.draw(row, col)
  if vim.api.nvim_get_current_buf() ~= M.buf then
    return
  end

  if M.check_bounds(row, col) then
    return
  end

  local visualWidth = vim.fn.strwidth(M.pen)
  local byteWidth = vim.fn.strlen(M.pen)

  local line = vim.api.nvim_buf_get_lines(M.buf, row, row + 1, false)[1]
  local placeholder = string.rep('~', byteWidth)
  local encoded_line = line:gsub(M.pen, placeholder)
  local replaceWidth = (encoded_line:sub(col, col) == '~') and byteWidth or visualWidth
  local new_encoded_line = encoded_line:sub(1, col - 1) .. placeholder .. encoded_line:sub(col + replaceWidth)

  local new_placeholder_count = select(2, string.gsub(new_encoded_line, "~", ""))
  if (new_placeholder_count % byteWidth ~= 0) then
    return
  end

  local new_line = new_encoded_line:gsub(placeholder, M.pen)
  vim.api.nvim_buf_set_lines(M.buf, row, row + 1, false, { new_line })

  -- ext marks are 0 indexed
  colors.draw(M.buf, row, col - 1, col - 1 + byteWidth, byteWidth, replaceWidth)
end

function M.reset_canvas()
  local lines = {}
  local width = vim.api.nvim_win_get_width(0)
  local height = vim.api.nvim_win_get_height(0)
  for _ = 1, height do
    table.insert(lines, string.rep(" ", width))
  end
  vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
end

function M.check_bounds(row, col)
  local width = vim.api.nvim_win_get_width(0)
  local height = vim.api.nvim_win_get_height(0)
  if row < 0 or row >= height then
    return true
  end
  local col = M.toVisualCol(row, col)
  if col > width or col <= 0 then
    return true
  end
  return false
end

function M.toVisualCol(row, byteCol)
  -- Get raw str
  local line = vim.api.nvim_buf_get_lines(M.buf, row, row + 1, false)[1]
  -- Get substr til byte col
  local line_to_left = line:sub(1, byteCol - 1)
  -- Return visual length of this
  return vim.fn.strwidth(line_to_left) + 1
end

function M.toByteCol(row, visualCol)
  -- Get raw str
  local line_arr = vim.api.nvim_buf_get_lines(M.buf, row, row + 1, false)
  if #line_arr == 0 then
    return
  end
  local line = line_arr[1]
  if line == nil then
    return
  end

  -- repl pen with ~
  local visual_line = line:gsub(M.pen, '~')
  -- substr til vis col
  local visual_substr = visual_line:sub(1, visualCol)
  -- repl ~ with pen
  local line_to_left = visual_substr:gsub('~', M.pen)
  -- take len to get byte col
  return vim.fn.strlen(line_to_left)
end

return M
