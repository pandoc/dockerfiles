--- The actual app
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc = require 'pandoc'
local Logger = require 'pandock.type.Logger'
local config = require 'pandock.config'

local App = {}
App.__index = App

App.new = function (verbosity, config_filepath, commands)
  local app = {}
  app.logger = Logger(verbosity)
  app.config = config.get_config(config_filepath)
  app.commands = commands
  return setmetatable(app, App)
end

App.run_command = function (self, command_name, args)
  local command = self.commands[command_name]
  if command then
    command.run(self, args)
  else
    self.logger:error('Unknown command: "' .. command_name .. '"\n')
    self.logger:info('Supported commands are:\n')
    local commands_list = pandoc.List(pairs(self.commands))
    commands_list:sort()
    for name in commands_list:iter() do
      self.logger:info('\t' .. name .. '\n')
    end
    os.exit(1)
  end
end

local AppMT = {
  __call = function (self, ...)
    return self.new(...)
  end,
}

return setmetatable(App, AppMT)
