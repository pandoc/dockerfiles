--- Release config
--
-- Defines and configures the images for a pandoc release.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local configutils = require 'pandock.configutils'

local Release = configutils.make_config_class{
  name = 'Release',
  valid_keys = {
    'pandoc-version',
    'base-image',
    'version-tags',
    'addon',
  },
}

return Release





