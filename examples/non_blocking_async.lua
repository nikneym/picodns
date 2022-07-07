-- Asynchronously non-blocking example
local dns = require "picodns"

local resolver = dns.newResolver()

local addresses = {
  "lua.org",
  "luajit.org",
  "crystal-lang.org",
  "rust-lang.org",
  "love2d.org",
}

local queries = { }

for k, address in ipairs(addresses) do
  queries[k] = coroutine.create(function()
    local answers, err = resolver:query(address)
    assert(err == nil)

    print("resolved " .. address)
    for _, answer in ipairs(answers) do
      print(answer)
    end
  end)
end

while #queries > 0 do
  for k, query in ipairs(queries) do
    local status = coroutine.resume(query)
    if not status then
      table.remove(queries, k)
    end
  end
end