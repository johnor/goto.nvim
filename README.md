# goto.nvim

Jump between a header, its source file and its unit test, based on directory
layout. Lua port of [neogoto](https://github.com/johnor/neogoto).

From the current file the plugin searches the file's own directory and every
parent directory for the configured directories (`include`, `src`, `test`, ...).
Sub directories are preserved, so `src/lib/a.cpp` finds `include/lib/a.h`.

## Install (lazy.nvim)

```lua
{ "johnor/goto.nvim", opts = {} }
```

## Commands

| Command                | Action                                          |
|------------------------|-------------------------------------------------|
| `:GotoHeader`          | go to the header                                |
| `:GotoSource`          | go to the source file                           |
| `:GotoTest`            | go to the unit test                             |
| `:GotoSwitch`          | header <-> source, test -> source               |
| `:GotoSwitchLeft`      | `:GotoSwitch`, opening in the window to the left  |
| `:GotoSwitchRight`     | `:GotoSwitch`, opening in the window to the right |
| `:GotoSwitchSplitLeft` | `:GotoSwitch`, opening in a new split to the left  |
| `:GotoSwitchSplitRight`| `:GotoSwitch`, opening in a new split to the right |

From Lua: `require("goto_nvim").goto_file({ kind = "test", placement = "split_right" })`.
`kind` is a mapping name (default: the `switch` target of the current file) and
`placement` is one of `left`, `right`, `split_left`, `split_right`.

## Configuration

These are the defaults.

```lua
require("goto_nvim").setup({
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
})
```

Lists replace the default list, they are not merged.
Only the keys you give are overridden, e.g. `mapping = { test = { dirs = { "tests" } } }`.

## Tests

Needs [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
(`PLENARY_DIR` overrides the default lazy.nvim location).

    just test
