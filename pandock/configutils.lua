--- Support for objects with a restricted set of valid keys.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local M = {}

M.make_config_class = function (properties)
  local name = properties.name or 'Unknown ConfigObject'
  local methods = properties.methods or {}
  local valid_keys = {}
  for _, key in ipairs(properties.valid_keys) do
    valid_keys[key] = true
  end

  local object_mt = {
    __name = name,
    __index = function (t, key)
      local method = methods[key]
      if method then
        return method
      elseif valid_keys[key] then
        return rawget(t, key)
      else
        local fixedkey = key:gsub('%_', '-')
        if valid_keys[fixedkey] then
          return rawget(t, fixedkey)
        end
        error('Invalid key: "' .. tostring(key) .. '"')
      end
    end,
    __newindex = function (t, key, value)
      if valid_keys[key] then
        rawset(t, key, value)
      else
        local fixedkey = key:gsub('%_', '-')
        if valid_keys[fixedkey] then
          return rawset(t, key, value)
        end
        error('Invalid key: "' .. tostring(key) .. '"')
      end
    end,
    __pairs = function (t)
      local next_val = function (keys, index)
        local key = next(keys, index)
        local value = rawget(t, key)
        return value
      end
      return next_val, valid_keys, nil
    end
  }

  local class_mt = {
    new = function (config)
      local confobj = setmetatable({}, object_mt)
      -- make a shallow copy while checking key validity
      for key, value in pairs(config) do
        confobj[key] = value
      end
      return confobj
    end,
    __name = name .. ' class',
    __call = function (t, ...)
      return getmetatable(t).new(...)
    end
  }
  class_mt.__index = class_mt

  return setmetatable({}, class_mt)
end

return M
