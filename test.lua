package.path = package.path .. ";./?.lua"

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
  ngx = mock("GET", { name = "foo", age = "100" })
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local params = util.map_message("helloworld.HelloRequest", {})
  lu.assertEquals(params.name, "foo")
  lu.assertEquals(params.age, 100)
  lu.assertNil(params.jobs)
end
function TestUtil:testMapMessageWithGETDefaultValue()
  ngx = mock("GET")
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local params = util.map_message("helloworld.HelloRequest", {
    name = "foobar",
    jobs = { "jobA", "jobB" }
  })
  lu.assertEquals(params.name, "foobar")
  lu.assertEquals(2, #params.jobs)
end
function TestUtil:testMapMessageWithPostFields()
  ngx = mock("POST", {}, { name = "foo", age = "100" })
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local params = util.map_message("helloworld.HelloRequest", {})
  lu.assertEquals(params.name, "foo")
  lu.assertEquals(params.age, 100)
  lu.assertNil(params.jobs)
end
function TestUtil:testMapMessageWithPOSTDefaultValue()
  ngx = mock("POST")
  local p, err = proto.new("./fixtures/helloworld.proto")
  lu.assertNil(err)
  local params = util.map_message("helloworld.HelloRequest", {
    name = "foobar",
    jobs = { "jobA", "jobB" }
  })
  lu.assertEquals(params.name, "foobar")
  lu.assertEquals(2, #params.jobs)
end


os.exit(lu.LuaUnit.run())
