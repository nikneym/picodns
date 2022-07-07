-- Synchronously non-blocking example
local dns = require "picodns"

local resolver = dns.newResolver()

local function query(host)
  local answers, err = resolver:query(host)
  assert(err == nil)

  print("resolved " .. host)
  for _, answer in ipairs(answers) do
    print(answer)
  end
end

local queries = coroutine.create(function()
  query("lua.org")
  query("luajit.org")
  query("crystal-lang.org")
  query("rust-lang.org")
  query("love2d.org")
end)

repeat
  local status = coroutine.resume(queries)
until not status