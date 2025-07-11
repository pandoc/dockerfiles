--- Image variant, i.e., the type of image (minimal, core, ...)
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local path = require 'pandoc.path'
local configutils = require 'pandock.configutils'

local Variant = configutils.make_config_class{
  name = 'Variant',
  valid_keys = {'name', 'title', 'description', 'default-stack'},
  methods = {
    is_addon = function (self)
      return self.name == 'minimal' or self.name == 'core'
    end
  }
}

return Variant





