local socket = require "socket"
local parser = require "parser"
local bit = require "bit"
local co_yield  = coroutine.yield
local co_is_yieldable = coroutine.isyieldable
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol
local char = string.char
local floor = math.floor
local remove = table.remove
local gettime = socket.gettime
local udp4 = socket.udp4

local dns = { version = "0.1.0" }
dns.__index = dns
dns.servers = {
  "1.1.1.1",
  "8.8.8.8",
  "9.9.9.9"
}

function dns.newResolver(servers)
  return setmetatable({
    cache   = { },
    servers = servers or dns.servers
  }, dns)
end

local function rand()
  return math.random(65535)
end

local function encode_name(str)
  return char(#str) .. str
end

local function build_query_string(self, domain, record, id)
  local b1 = rshift(id, 8)
  local b2 = band(id, 0xff)

  -- create as less garbage as possible
  local q = char(b1, b2, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0) ..
            domain:gsub("([^.]+)%.?", encode_name) ..
            char(0, rshift(record, 8), band(record, 0xff), 0, 1)
  return q
end

function dns:query(domain)
  if not domain then
    return nil, "Address is not provided"
  end

  if self.cache[domain] then
    for k, answer in ipairs(self.cache[domain]) do
      if floor(gettime() - answer.start_time) >= answer.ttl then
        remove(self.cache[domain], k)
      end
    end

    if #self.cache[domain] > 0 then
      return self.cache[domain]
    end
  end

  local handle = udp4()
  handle:settimeout(0)

  local id = rand()
  local query = build_query_string(self, domain, 1, id)

  for _, server in ipairs(self.servers) do
    local _, err = handle:sendto(query, server, 53)
    if err then
      return nil, err
    end
  end

  local data, start_time = nil, gettime()
  repeat
    data = handle:receive()
    if co_is_yieldable() then
      co_yield()
    end

    local t = floor(gettime() - start_time)
    if t >= 5 then
      return nil, "DNS Server didn't respond"
    end
  until data
  handle:close()

  local parsed, err = parser.new(data):parse()
  if err then
    return nil, err
  end

  self.cache[domain] = parsed.answers
  return parsed.answers, nil
end

return dns