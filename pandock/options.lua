--- Options for the creation of pandoc Dockerfiles
--
-- Copyright  : © Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc   = require 'pandoc'

--- Default Dockerfile-generation options.
local default_options = {
  stack = 'ubuntu',
  base_image_version = 'noble',
  pandoc_version = 'edge',
  verbosity = 0,
}

--- Dockerfile options.
local Options = {}
Options.defaults = default_options
Options.new = function (opts)
  local obj = setmetatable({}, Options)
  for key, value in pairs(opts or {}) do
    obj[key] = value
  end
  return obj
end
Options.__index = function (t, key)
  local mt = getmetatable(t)
  return rawget(mt.defaults, key) or rawget(mt, key)
end
Options.__newindex = function (t, key, value)
  if getmetatable(t).defaults[key] then
    rawset(t, key, value)
  else
    error('Unknown option "' .. tostring(key) .. '"')
  end
end
Options.__pairs = function (t)
  local next_default = function (defs, index)
    local key, def = next(defs, index)
    local actual = rawget(t, key)
    if actual ~= nil then
      return key, actual
    else
      return key, def
    end
  end
  return next_default, getmetatable(t).defaults, nil
end

--- Convert the options to a pandoc template context.
Options.to_context = function (self)
  local context = {}
  for key, value in pairs(self) do
    context[key] = value
  end
  return context
end

--- Validate the options sanity
Options.check = function(self)
  assert(
    self.pandoc_version == 'main' or
    pcall(pandoc.types.Version, self.pandoc_version),
    'Invalid pandoc version "' .. tostring(self.pandoc_version) .. '"'
  )
  return self
end

return Options
