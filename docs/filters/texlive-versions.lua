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
  if not cb.classes:includes 'texlive-versions' then
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

  local rows = pandoc.List()
  for release_number in release_numbers:iter() do
    local release = config.release[release_number]
    local tags = tag_strings(release['version-tags'])
    local row = {
      pandoc.Blocks(release_number),
      pandoc.Blocks{tags},
      pandoc.Blocks(release.addon.latex.texlive)
    }
    rows:insert(row)
  end
  return pandoc.utils.from_simple_table(
    pandoc.SimpleTable(
      'TeXLive version that are shipped in the images.',
      {pandoc.AlignDefault, pandoc.AlignDefault, pandoc.AlignDefault},
      {0, 0, 0},
      {{'pandoc version'}, {'tags'}, {'TeXLive version'}},
      rows
    )
  )
end
