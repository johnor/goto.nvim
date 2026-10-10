local finder = require("goto_nvim.finder")
local defaults = require("goto_nvim").defaults.mapping
local helpers = require("tests.helpers")

describe("finder", function()
   local root

   before_each(function()
      root = helpers.make_tree(helpers.repo)
   end)

   it("iterates parents", function()
      assert.same({
         { dir = "/f1/f2/f3", sub = "" },
         { dir = "/f1/f2", sub = "" },
         { dir = "/f1", sub = "f3" },
         { dir = "/", sub = "f2/f3" },
      }, finder.iterate_parents("/f1/f2/f3/file.cpp"))
   end)

   it("finds a header in the same directory", function()
      local file = finder.counterpart(root .. "/Source/lib2/lib2_file1.cpp", defaults)
      assert.equals(root .. "/Source/lib2/lib2_file1.h", file)
   end)

   it("finds a header in another directory", function()
      assert.equals(root .. "/Include/lib1/lib1_file1.h", finder.counterpart(root .. "/Source/lib1/lib1_file1.cpp", defaults))
      assert.equals(root .. "/Include/lib1/lib1_file2.hpp", finder.counterpart(root .. "/Source/lib1/lib1_file2.cpp", defaults))
   end)

   it("finds the source from a header", function()
      assert.equals(root .. "/Source/file1.cpp", finder.counterpart(root .. "/Include/file1.h", defaults))
   end)

   it("finds the unit test with prefix", function()
      assert.equals(root .. "/UnitTest/lib2/Testlib2_file1.cpp", finder.counterpart(root .. "/Source/lib2/lib2_file1.cpp", defaults, "test"))
      assert.equals(root .. "/UnitTest/lib2/Testlib2_file1.cpp", finder.counterpart(root .. "/Source/lib2/lib2_file1.h", defaults, "test"))
      assert.equals(root .. "/UnitTest/Testfile1.cpp", finder.counterpart(root .. "/Include/file1.h", defaults, "test"))
   end)

   it("picks the test mapping for prefixed files", function()
      assert.equals("source", (finder.current_mapping(root .. "/Source/file1.cpp", defaults)))
      assert.equals("test", (finder.current_mapping(root .. "/UnitTest/Testfile1.cpp", defaults)))
      assert.equals("header", (finder.current_mapping(root .. "/Include/file1.h", defaults)))
   end)

   it("reports unknown file types and missing files", function()
      local file, err = finder.counterpart(root .. "/README.md", defaults)
      assert.is_nil(file)
      assert.equals("Could not find mapping for current file", err)

      file, err = finder.counterpart(root .. "/Source/lib1/lib1_file1.cpp", defaults, "test")
      assert.is_nil(file)
      assert.equals("Could not find a file to switch to", err)
   end)
end)
