if vim.g.loaded_goto_nvim then
   return
end
vim.g.loaded_goto_nvim = true

local function define(name, opts)
   vim.api.nvim_create_user_command(name, function()
      require("goto_nvim").goto_file(opts)
   end, { desc = "goto.nvim: " .. name })
end

define("GotoHeader", { kind = "header" })
define("GotoSource", { kind = "source" })
define("GotoTest", { kind = "test" })
define("GotoSwitch", {})
define("GotoSwitchLeft", { placement = "left" })
define("GotoSwitchRight", { placement = "right" })
define("GotoSwitchSplitLeft", { placement = "split_left" })
define("GotoSwitchSplitRight", { placement = "split_right" })
