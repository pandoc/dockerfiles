--- The actual app
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local Logger = require 'pandock.type.Logger'
local config = require 'pandock.config'

local App = {}

App.new = function (verbosity, config_filepath)
  local app = {}
  app.logger = Logger(verbosity)
  app.config = config.get_config(config_filepath)
  return app
end

return App
