local dns = require "picodns"

-- custom DNS endpoints can be used
-- normally it uses cloudflare, google and quad9
local resolver = dns.newResolver({ "1.1.1.1" })

-- blocking DNS query
local data, err = resolver:query("lua.org")
if err then
  error(err)
end

-- when called in a coroutine,
-- it becomes a non-blocking call
local co = coroutine.create(function()
  local answers, err = resolver:query("luajit.org")
  if err then
    error(err)
  end

  for _, answer in ipairs(answers) do
    print(string.format("%s => %s", answer.name, answer.content))
  end
end)

-- so you have to wait 'till it's done,
-- good thing is you can do your other fancy stuff in this loop concurrently!
repeat
  local status = coroutine.resume(co)
  print "do other work here!"
until not status