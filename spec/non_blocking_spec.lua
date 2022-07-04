local dns = require "picodns"

describe("when called in a coroutine", function()
  it("the query never blocks, it should return immediately", function()
    local resolver = dns.newResolver()

    local co = coroutine.create(function()
      local data, err = resolver:query("lua.org")
    end)

    local status, data = coroutine.resume(co)
    assert.truthy(status)
    assert.is_nil(data)
  end)

  it("should be waited to finish", function()
    local resolver = dns.newResolver()

    local co = coroutine.create(function()
      local data, err = resolver:query("lua.org")
      for _, answer in ipairs(data) do
        assert.equal(answer.type, 'A')
        assert.equal(answer.name, "lua.org")
        assert.equal(answer.content, "88.99.213.221")
      end
    end)

    local status, data
    repeat
      status, data = coroutine.resume(co)
    until not status

    assert.falsy(status)
    assert.equal(data, "cannot resume dead coroutine")
  end)

  it("multiple queries can be run concurrently", function()
    math.randomseed(os.time() * os.clock())
    local resolver = dns.newResolver()
    local events = { }
    local addresses = {
      "luajit.org",
      "love2d.org",
      "lua.org",
      "python.org",
      "rust-lang.org",
      "crystal-lang.org",
      "ziglang.org",
      "nim-lang.org",
      "odin-lang.org"
    }

    local function coroutine_cb()
      local data, err = resolver:query(addresses[math.random(#addresses)])
      assert.is_nil(err)
      assert.truthy(data)
      for _, answer in ipairs(data) do
        assert.truthy(answer)
      end
    end

    for i = 1, 50 do
      table.insert(events, coroutine.create(coroutine_cb))
    end

    while true do
      local len = #events
      if len == 0 then
        break
      end

      for k, event in ipairs(events) do
        local status, data = coroutine.resume(event)
        if not status then
          table.remove(events, k)
        end
      end
    end
  end)
end)