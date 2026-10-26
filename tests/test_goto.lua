local eq = require("mini.test").expect.equality
local goto_nvim = require("goto_nvim")
local helpers = require("tests.helpers")

describe("goto_nvim", function()
   local root

   before_each(function()
      vim.cmd("silent! %bwipeout!")
      vim.cmd("only")
      goto_nvim.setup()
      root = helpers.make_tree(helpers.repo)
      vim.cmd.edit(root .. "/Source/file1.cpp")
   end)

   local function current()
      return vim.fn.expand("%:p")
   end

   it("switches in the current window", function()
      goto_nvim.goto_file()
      eq(root .. "/Include/file1.h", current())
      eq(1, #vim.api.nvim_tabpage_list_wins(0))
   end)

   it("goes to the test with :GotoTest", function()
      vim.cmd("GotoTest")
      eq(root .. "/UnitTest/Testfile1.cpp", current())
   end)

   it("opens in a split on the right", function()
      vim.cmd("GotoSwitchSplitRight")
      eq(root .. "/Include/file1.h", current())
      eq(2, #vim.api.nvim_tabpage_list_wins(0))
      vim.cmd("wincmd h")
      eq(root .. "/Source/file1.cpp", current())
   end)

   it("opens in a split on the left", function()
      vim.cmd("GotoSwitchSplitLeft")
      eq(root .. "/Include/file1.h", current())
      vim.cmd("wincmd l")
      eq(root .. "/Source/file1.cpp", current())
   end)

   it("opens in the existing window to the right", function()
      vim.cmd("rightbelow vsplit")
      vim.cmd("wincmd h")
      vim.cmd("GotoSwitchRight")
      eq(root .. "/Include/file1.h", current())
      vim.cmd("wincmd h")
      eq(root .. "/Source/file1.cpp", current())
      eq(2, #vim.api.nvim_tabpage_list_wins(0))
   end)

   it("does not split when nothing is found", function()
      vim.cmd.edit(root .. "/Include/lib1/lib1_file1.h")
      local before = current()
      goto_nvim.goto_file({ kind = "test", placement = "split_right" })
      eq(before, current())
      eq(1, #vim.api.nvim_tabpage_list_wins(0))
   end)

   it("uses configured directories", function()
      local custom = helpers.make_tree({ "inc/a.hpp", "lib/a.cpp" })
      goto_nvim.setup({ mapping = { header = { dirs = { "inc" } }, source = { dirs = { "lib" } } } })
      vim.cmd.edit(custom .. "/lib/a.cpp")
      goto_nvim.goto_file()
      eq(custom .. "/inc/a.hpp", current())
      -- unrelated defaults are kept
      eq({ "hpp", "h" }, require("goto_nvim").defaults.mapping.header.endings)
   end)
end)
