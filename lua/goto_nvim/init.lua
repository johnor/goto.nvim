local finder = require("goto_nvim.finder")

local M = {}

---@class GotoMapping
---@field dirs string[] directories to search, besides the file's own directory
---@field endings string[] file extensions, without the dot
---@field prefix string|nil file name prefix, e.g. "Test"
---@field switch string|nil mapping to jump to from files of this kind

M.defaults = {
   mapping = {
      header = {
         dirs = { "Include", "include", "Impl", "impl" },
         endings = { "hpp", "h" },
         switch = "source",
      },
      source = {
         dirs = { "Source", "source", "src" },
         endings = { "cpp", "c" },
         switch = "header",
      },
      test = {
         dirs = { "UnitTest", "UnitTests", "test", "UnitTest/Source", "test/src", "UnitTests/Source" },
         endings = { "cpp", "c" },
         prefix = "Test",
         switch = "source",
      },
   },
}

local config = vim.deepcopy(M.defaults)

-- Where to open the file. Window commands run before the file is opened.
local placements = {
   left = "wincmd h",
   right = "wincmd l",
   split_left = "leftabove vsplit",
   split_right = "rightbelow vsplit",
}

---@param opts { mapping: table<string, GotoMapping> }|nil
function M.setup(opts)
   config = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

local function warn(msg)
   vim.notify("goto.nvim: " .. msg, vim.log.levels.WARN)
end

local function open(file, placement)
   if placement then
      vim.cmd(placements[placement])
   end
   if file ~= vim.fn.expand("%:p") then
      vim.cmd("normal! m`")
      vim.cmd.edit(vim.fn.fnameescape(file))
   end
end

--- Go to the counterpart of the current file.
---@param opts { kind: string|nil, placement: "left"|"right"|"split_left"|"split_right"|nil }|nil
---   kind: "header", "source", "test" or any configured mapping. Defaults to
---   the "switch" target of the current file's mapping.
function M.goto_file(opts)
   opts = opts or {}
   if opts.placement and not placements[opts.placement] then
      return warn(("Unknown placement: %s"):format(opts.placement))
   end
   local file, err = finder.counterpart(vim.fn.expand("%:p"), config.mapping, opts.kind)
   if not file then
      return warn(err)
   end
   open(file, opts.placement)
end

return M
