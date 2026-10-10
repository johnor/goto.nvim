local M = {}

--- Create the given files (relative to a fresh temp dir) and return the dir.
---@param files string[]
---@return string
function M.make_tree(files)
   local root = vim.fn.resolve(vim.fn.tempname())
   for _, file in ipairs(files) do
      local path = root .. "/" .. file
      vim.fn.mkdir(vim.fs.dirname(path), "p")
      vim.fn.writefile({}, path)
   end
   return root
end

M.repo = {
   "Include/lib1/lib1_file1.h",
   "Source/lib1/lib1_file1.cpp",
   "Include/lib1/lib1_file2.hpp",
   "Source/lib1/lib1_file2.cpp",
   "Include/file1.h",
   "Source/file1.cpp",
   "Source/lib2/lib2_file1.h",
   "Source/lib2/lib2_file1.cpp",
   "UnitTest/lib2/Testlib2_file1.cpp",
   "UnitTest/Testfile1.cpp",
}

return M
