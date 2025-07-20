local canvas = require("doodle.canvas")

local M = {
  init_cursor = true
}

function M.register(buf)
  -- enter visual mode
  vim.api.nvim_feedkeys("v", "n", false)

  -- force visual persistence
  vim.api.nvim_create_autocmd("ModeChanged", {
    buffer = buf,
    callback = function()
      local mode = vim.api.nvim_get_mode().mode
      if mode ~= 'v' then
        vim.api.nvim_feedkeys("v", "n", false)
      end
    end,
  })

  -- fixes for above
  vim.api.nvim_set_keymap('v', 's', '', { noremap = true, silent = true })

  -- main draw listener
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = buf,
    callback = M.on_cursor_move,
  })

  -- toolbar listeners
  vim.api.nvim_buf_set_keymap(buf, 'v', 'c',
    [[:<C-u>lua require("doodle.canvas").reset_canvas()<CR>]], {
      noremap = true,
      silent = true,
    })

  vim.api.nvim_buf_set_keymap(buf, 'v', 'n',
    [[:<C-u>lua require("doodle.colors").update_color('neutral')<CR>]], {
      noremap = true,
      silent = true,
    })

  vim.api.nvim_buf_set_keymap(buf, 'v', 'd',
    [[:<C-u>lua require("doodle.colors").update_color('black')<CR>]], {
      noremap = true,
      silent = true,
    })

  vim.api.nvim_buf_set_keymap(buf, 'v', 'r',
    [[:<C-u>lua require("doodle.colors").update_color('red')<CR>]], {
      noremap = true,
      silent = true,
    })

  vim.api.nvim_buf_set_keymap(buf, 'v', 'g',
    [[:<C-u>lua require("doodle.colors").update_color('green')<CR>]], {
      noremap = true,
      silent = true,
    })

  vim.api.nvim_buf_set_keymap(buf, 'v', 'b',
    [[:<C-u>lua require("doodle.colors").update_color('blue')<CR>]], {
      noremap = true,
      silent = true,
    })

  vim.api.nvim_buf_set_keymap(buf, 'v', 'q',
    [[:<C-u>lua require("doodle.init").toggle()<CR>]], {
      noremap = true,
      silent = true,
    })
end

function M.on_cursor_move()
  if M.init_cursor then
    M.init_cursor = false
    return
  end

  -- Get the current cursor position (rows are 1 indexed, we want it 0 indexed) & (cols are 0 indexed, we want it 1 indexed)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor_pos[1] - 1, cursor_pos[2] + 1

  -- Draw a pen character
  canvas.draw(row, col)
end

return M
