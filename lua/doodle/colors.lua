local toolbar = require("doodle.toolbar")

local M = {
  color = 'neutral',
  ns = nil,
  -- row => {
  --  {col_start=0, col_end=1, color=hl_group}
  --  {col_start=2, col_end=3, color=hl_group}
  -- }
  current_colors = {}
}

function M.register()
  M.ns = vim.api.nvim_create_namespace("doodle_pen")
  vim.api.nvim_set_hl(0, "red", { fg = "#FF5555" })
  vim.api.nvim_set_hl(0, "green", { fg = "#55FF55" })
  vim.api.nvim_set_hl(0, "blue", { fg = "#5555FF" })
  vim.api.nvim_set_hl(0, "black", { fg = "#000000" })
end

function M.update_color(new_color)
  M.color = new_color
  toolbar.update_toolbar(new_color)
end

function M.get_pen_color()
  return M.color
end

function M.draw(buf, row, col_start, col_end, byteWidth, replaceWidth)
  -- Add new color to memory
  if not M.current_colors[row] then
    M.current_colors[row] = {}
  end
  local new_entry = {
    col_start = col_start,
    col_end = col_end,
    color = M.color,
  }

  M.current_colors[row] = remove_matching_entry(M.current_colors[row], new_entry)
  table.insert(M.current_colors[row], new_entry)

  -- Sort colors in M.current_colors[row] desc
  table.sort(M.current_colors[row], function(a, b)
    return a.col_start > b.col_start
  end)

  -- Re apply all colors in row
  for _, current_entry in ipairs(M.current_colors[row]) do
    -- account for position shift if pen is multibyte
    if current_entry.col_start > col_start then
      current_entry.col_start = current_entry.col_start + byteWidth - replaceWidth
      current_entry.col_end = current_entry.col_end + byteWidth - replaceWidth
    end

    vim.api.nvim_buf_add_highlight(buf, M.ns, current_entry.color, row, current_entry.col_start, current_entry.col_end)
  end
end

function print_row_colors(tbl)
  for _, new_entry in ipairs(tbl) do
    print(new_entry.col_start .. ',' .. new_entry.col_end .. ',' .. new_entry.color)
  end
end

function remove_matching_entry(tbl, new_entry)
  for i, current_entry in ipairs(tbl) do
    if current_entry.col_start == new_entry.col_start and current_entry.col_end == new_entry.col_end then
      table.remove(tbl, i)
      break
    end
  end
  return tbl
end

function M.get_color(row, col)
  if not M.current_colors[row] then
    M.current_colors[row] = {}
  end
  for i, current_entry in ipairs(M.current_colors[row]) do
    if current_entry.col_start == col then
      return current_entry.color
    end
  end
end

return M
