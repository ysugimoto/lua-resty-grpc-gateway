package.path = package.path .. ";./?.lua"
package.path = package.path .. ";./tests/?.lua"

local lu = require("luaunit")
local util = require("grpc-gateway.util")
local mock = require("fixtures.ngx_mock")
local proto = require("grpc-gateway.proto")

TestUtil = {}
function TestUtil:testFileExistsShouldTrue()
  local exists = util.file_exists("./fixtures/helloworld.proto")
  lu.assertTrue(exists)
end
function TestUtil:testFileExistsShouldFalse()
  local exists = util.file_exists("./fixtures/notfound.proto")
  lu.assertFalse(exists)
end

function TestUtil:testFindMethodShouldNotNil()
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local m = util.find_method(p, "helloworld.Greeter", "SayHello")
  lu.assertNotNil(m)
end
function TestUtil:testFindMethodShouldNil()
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local m = util.find_method(p, "helloworld.Greeter", "SayGoodBye")
  lu.assertNil(m)
end

function TestUtil:testMapMessageWithQueryString()
  ngx = mock("GET", { name = "foo", age = "100", bar = { grades = {1,2,3}} })
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local values = util.populate_default_values()
  local params = util.map_message("helloworld.HelloRequest", values)
  lu.assertEquals(params.name, "foo")
  lu.assertEquals(params.age, 100)
  lu.assertNil(params.jobs)
end

function TestUtil:testMapMessageWithGETDefaultValue()
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local params = util.map_message("helloworld.HelloRequest", {
    name = "foobar",
    jobs = { "jobA", "jobB" },
    bar = { grades = {1,2,3}}
  })
  lu.assertEquals(params.name, "foobar")
  lu.assertEquals(2, #params.jobs)
end

function TestUtil:testMapMessageWithPostFields()
  ngx = mock("POST", {}, { name = "foo", age = "100", bar = {{grades = {1,2,3}},{grades={4,5,6}}} })
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local values = util.populate_default_values()
  local params = util.map_message("helloworld.HelloRequest", values)
  lu.assertEquals(params.name, "foo")
  lu.assertEquals(params.age, 100)
  lu.assertNil(params.jobs)
  lu.assertEquals(params.bar, {{grades={1, 2, 3}}, {grades={4, 5, 6}}})
end

function TestUtil:testMapMessageWithPOSTDefaultValue()
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local params = util.map_message("helloworld.HelloRequest", {
    name = "foobar",
    jobs = { "jobA", "jobB" },
    bar = {{grades = {1,2,3}}}
  })
  lu.assertEquals(params.name, "foobar")
  lu.assertEquals(2, #params.jobs)
  lu.assertEquals(1, #params.bar)
end

function TestUtil:testMapMessageWithMissingValue()
  ngx = mock("POST", {}, { name = "foo", age = "100" })
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local values = util.populate_default_values()
  local params = util.map_message("helloworld.HelloRequest", values)
  lu.assertEquals(params.name, "foo")
  lu.assertEquals(params.age, 100)
  lu.assertEquals(params.bar, {})
  lu.assertEquals(params.locations, {})
end

function TestUtil:testMapMessageWithDuplicateFieldKey()
  ngx = mock("POST", {}, { name = "foo", age = "100", locations = {{name ="test"}} })
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local values = util.populate_default_values()
  local params = util.map_message("helloworld.HelloRequest", values)
  lu.assertEquals(params.name, "foo")
  lu.assertEquals(params.age, 100)
  lu.assertEquals(params.bar, {})
  lu.assertEquals(params.locations, {{name = "test"}})
end

function TestUtil:testMapMessageWithEnumString()
  ngx = mock("POST",{},{ name = "foo", age = "100", locations = {{name ="test"}},color = "GREEN" })
  local p, err = proto.new("./fixtures/enum.proto")
  lu.assertNil(err)
  local values = util.populate_default_values()
  local params = util.map_message("enum.HelloRequest", values)
  lu.assertEquals(params.name, "foo")
  lu.assertEquals(params.color,1)
end

function TestUtil:testMapMessageWithEnumIntQuery()
  ngx = mock("GET",{ name = "foo", age = "100", locations = {{name ="test"}},color = 2 })
  local p, err = proto.new("./fixtures/enum.proto")
  lu.assertNil(err)
  local values = util.populate_default_values()
  local params = util.map_message("enum.HelloRequest", values)
  lu.assertEquals(params.name, "foo")
  lu.assertEquals(params.color,"BLUE")
end

function TestUtil:testMapMessageWithEnumStringQuery()
  ngx = mock("GET",{ name = "foo", age = "100", locations = {{name ="test"}},color = "GREEN" })
  local p, err = proto.new("./fixtures/enum.proto")
  lu.assertNil(err)
  local values = util.populate_default_values()
  local params = util.map_message("enum.HelloRequest", values)
  lu.assertEquals(params.name, "foo")
  lu.assertEquals(params.color,1)
end

function TestUtil:testMapMessageWithEnumInt()
  ngx = mock("POST",{},{ name = "foo", age = "100", locations = {{name ="test"}},color = 2 })
  local p, err = proto.new("./fixtures/enum.proto")
  lu.assertNil(err)
  local values = util.populate_default_values()
  local params = util.map_message("enum.HelloRequest", values)
  lu.assertEquals(params.name, "foo")
  lu.assertEquals(params.color,"BLUE")
end

os.exit(lu.LuaUnit.run())
