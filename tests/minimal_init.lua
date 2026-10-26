local mini_test = vim.env.MINI_TEST_DIR or ".deps/mini.test"

vim.opt.rtp:prepend(".")
vim.opt.rtp:prepend(mini_test)
require("mini.test").setup()
vim.cmd("runtime plugin/goto.lua")
vim.o.swapfile = false
