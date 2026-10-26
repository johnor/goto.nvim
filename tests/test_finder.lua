local eq = require("mini.test").expect.equality
local finder = require("goto_nvim.finder")
local defaults = require("goto_nvim").defaults.mapping
local helpers = require("tests.helpers")

describe("finder", function()
   local root

   before_each(function()
      root = helpers.make_tree(helpers.repo)
   end)

   it("iterates parents", function()
      eq({
         { dir = "/f1/f2/f3", sub = "" },
         { dir = "/f1/f2", sub = "" },
         { dir = "/f1", sub = "f3" },
         { dir = "/", sub = "f2/f3" },
      }, finder.iterate_parents("/f1/f2/f3/file.cpp"))
   end)

   it("finds a header in the same directory", function()
      local file = finder.counterpart(root .. "/Source/lib2/lib2_file1.cpp", defaults)
      eq(root .. "/Source/lib2/lib2_file1.h", file)
   end)

   it("finds a header in another directory", function()
      eq(root .. "/Include/lib1/lib1_file1.h", finder.counterpart(root .. "/Source/lib1/lib1_file1.cpp", defaults))
      eq(root .. "/Include/lib1/lib1_file2.hpp", finder.counterpart(root .. "/Source/lib1/lib1_file2.cpp", defaults))
   end)

   it("finds the source from a header", function()
      eq(root .. "/Source/file1.cpp", finder.counterpart(root .. "/Include/file1.h", defaults))
   end)

   it("finds the unit test with prefix", function()
      eq(
         root .. "/UnitTest/lib2/Testlib2_file1.cpp",
         finder.counterpart(root .. "/Source/lib2/lib2_file1.cpp", defaults, "test")
      )
      eq(
         root .. "/UnitTest/lib2/Testlib2_file1.cpp",
         finder.counterpart(root .. "/Source/lib2/lib2_file1.h", defaults, "test")
      )
      eq(root .. "/UnitTest/Testfile1.cpp", finder.counterpart(root .. "/Include/file1.h", defaults, "test"))
   end)

   it("picks the test mapping for prefixed files", function()
      eq("source", (finder.current_mapping(root .. "/Source/file1.cpp", defaults)))
      eq("test", (finder.current_mapping(root .. "/UnitTest/Testfile1.cpp", defaults)))
      eq("header", (finder.current_mapping(root .. "/Include/file1.h", defaults)))
   end)

   it("reports unknown file types and missing files", function()
      local file, err = finder.counterpart(root .. "/README.md", defaults)
      eq(file, nil)
      eq("Could not find mapping for current file", err)

      file, err = finder.counterpart(root .. "/Source/lib1/lib1_file1.cpp", defaults, "test")
      eq(file, nil)
      eq("Could not find a file to switch to", err)
   end)
end)
