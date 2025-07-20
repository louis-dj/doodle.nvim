local canvas = require("doodle.canvas")
local toolbar = require("doodle.toolbar")
local colors = require("doodle.colors")
local listen = require("doodle.listen")

local M = {
  buf = nil,
}

function M.setup(opts)
  vim.api.nvim_set_keymap('n', opts.remap, ':lua require("doodle").toggle()<CR>',
    { noremap = true, silent = true })
end

function M.toggle()
  M.buf = canvas.toggle_canvas();
  toolbar.toggle_toolbar();

  if M.buf == nil then
    return
  end

  colors.register();
  listen.register(M.buf);
end

return M
