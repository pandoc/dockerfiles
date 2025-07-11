--- Dockerfile generator options
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local configutils = require 'pandock.configutils'

local GeneratorOptions = configutils.make_config_class{
  name = 'Release',
  valid_keys = {
    'image_spec',
    'context',
  },
}

return GeneratorOptions





