--- Query releases, image types, etc.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc      = require 'pandoc'
local List        = require 'pandoc.List'

local Version     = pandoc.types.Version

local list_action = {}

list_action.run = function (app, args)
  local name = assert(args[1], 'Variant name required')
  local variant = app.config.variants:find_if(
    function (v) return v.name == name end
  )
  assert(variant, 'No variant with name ' .. name)
  print('short_description=' .. variant['description'])
end

return list_action
