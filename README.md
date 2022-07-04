picodns
===========
picodns is a simple interface to interact with DNS providers in a concurrent way. It's loosely based on [OpenResty](https://github.com/openresty/lua-resty-dns)'s DNS resolver and uses a bit modified [LuaResolver](https://github.com/zeitgeist87/LuaResolver)'s parser for now.

Why?
===========
I'm aware that both of the modules mentioned earlier do the same thing for you but [in order to achieve non-blocking `connect` calls on luasocket](https://github.com/lunarmodules/luasocket/issues/382), DNS resolving had to be done concurrently. Unfortunately, LuaResolver does not support non-blocking and lua-resty-dns requires cosocket API of ngx_lua, so the options didn't satisfy me.

How-to
===========
```lua
local dns = require "picodns"

-- custom DNS endpoints can be used
-- normally it uses cloudflare, google and quad9
local resolver = dns.newResolver({ "1.1.1.1" })

-- blocking DNS query
local data, err = resolver:query("lua.org")
if err then
  error(err)
end

-- when called inside a coroutine,
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
```

Installation
===========
```
git clone git@github.com:nikneym/picodns.git
```
in your project directory and include it like
```lua
package.path = "picodns/?.lua;" .. package.path
local dns = require "picodns"
```
You only need picodns.lua and parser.lua though!

Documentation
===========
Will be added to GitHub wiki page. `How-to` section mostly explains it though.

Tests
===========
You need [busted](http://olivinelabs.com/busted) in order to run the tests.

License
===========
GNU General Public License v3.0, check out [license](https://github.com/nikneym/picodns/blob/main/LICENSE).