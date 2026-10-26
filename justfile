mini_test := ".deps/mini.test"

default: test

deps:
    [ -d {{mini_test}} ] || git clone --depth 1 https://github.com/echasnovski/mini.test {{mini_test}}

test: deps
    nvim --headless -u tests/minimal_init.lua -c "lua MiniTest.run({ execute = { reporter = require(\"tests.reporter\").verbose() } })"

clean:
    rm -rf .deps
