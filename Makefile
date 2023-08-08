.PHONY: test

tests/luaunit.lua:
	wget -q https://raw.githubusercontent.com/bluebird75/luaunit/master/luaunit.lua -o $@

test: tests/luaunit.lua
	LUAUNIT=1 lua tests/test.lua
