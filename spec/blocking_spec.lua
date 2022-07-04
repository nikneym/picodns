local dns = require "picodns"

describe("Blocking DNS query", function()
  it("with predefined servers", function()
    local resolver = dns.newResolver()
    local data, err = resolver:query("lua.org")
    assert.truthy(data)
    assert.is_nil(err)

    for _, answer in ipairs(data) do
      assert.equal(answer.type, 'A')
      assert.equal(answer.name, "lua.org")
      assert.equal(answer.content, "88.99.213.221")
    end
  end)

  it("with a custom server", function()
    local resolver = dns.newResolver({ "208.67.222.222" })
    local data, err = resolver:query("lua.org")

    for _, answer in ipairs(data) do
      assert.equal(answer.type, 'A')
      assert.equal(answer.name, "lua.org")
      assert.equal(answer.content, "88.99.213.221")
    end
  end)

  describe("when no server is given", function()
    it("should timeout and fail", function()
      local resolver = dns.newResolver({ })
      local data, err = resolver:query("lua.org")
      assert.is_nil(data)
      assert.equal(err, "DNS Server didn't respond")
    end)
  end)

  describe("when no address is given", function()
    it("should directly fail", function()
      local resolver = dns.newResolver()
      local data, err = resolver:query()
      assert.is_nil(data)
      assert.equal(err, "Address is not provided")
    end)
  end)
end)