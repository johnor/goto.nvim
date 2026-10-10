plenary := ".deps/plenary.nvim"

default: test

deps:
    [ -d {{plenary}} ] || git clone --depth 1 https://github.com/nvim-lua/plenary.nvim {{plenary}}

test: deps
    nvim --headless -u tests/minimal_init.lua \
        -c "PlenaryBustedDirectory tests {minimal_init = 'tests/minimal_init.lua', sequential = true}"

clean:
    rm -rf .deps
