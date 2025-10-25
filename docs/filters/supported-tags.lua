local io     = require 'io'
local pandoc = require 'pandoc'
local utils  = require 'pandoc.utils'
local stringify = utils.stringify

local function tag_strings (tags)
  local result = pandoc.List{}

  for i = 1, #tags do
    result:insert(pandoc.Code(stringify(tags[i])))
    if i < #tags then
      result:extend{pandoc.Str ',', pandoc.Space()}
    end
  end
  return result
end
function CodeBlock (cb)
  if not cb.classes:includes 'supported-tags' then
    return nil
  end

  -- get YAML as metadata from file
  local fh = io.open 'config.yaml'
  local config = pandoc.read(fh:read 'a').meta

  local release_numbers = pandoc.List{}
  for version in pairs(config.release) do
    release_numbers:insert(version)
  end
  release_numbers:sort(function (a, b)
      if a == 'main' then
        return true
      elseif b == 'main' then
        return false
      end
      local _, av = pcall(pandoc.types.Version, a)
      local _, bv = pcall(pandoc.types.Version, b)
      return av > bv
  end)

  local result = pandoc.List()
  for release_number in release_numbers:iter() do
    local release = config.release[release_number]
    local tags = tag_strings(release['version-tags'])
    result:insert{pandoc.Plain(tags)}
  end
  return pandoc.BulletList(result)
end
