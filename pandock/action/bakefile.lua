--- Create a bake file for a release.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local bakefile    = require 'pandock.bakefile'

--- Bakefile action
local action = {}

action.run = function (app, args)
  local pandoc_version = args[1]
  local config = app.config
  local release = config.release[pandoc_version]
  assert(release, 'No release found for ' .. tostring(pandoc_version))
  local bake_json = bakefile.generate_bake_json(release, config.variants)

  print(bake_json)
end

return action





