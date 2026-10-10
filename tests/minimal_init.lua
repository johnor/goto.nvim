local plenary = vim.env.PLENARY_DIR or ".deps/plenary.nvim"

vim.opt.rtp:prepend(".")
vim.opt.rtp:prepend(plenary)
vim.cmd("runtime plugin/plenary.vim")
vim.cmd("runtime plugin/goto.lua")
vim.o.swapfile = false
