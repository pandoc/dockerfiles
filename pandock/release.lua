--- pandoc releases and their parameters
--
-- Copyright  : © Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc   = require 'pandoc'
local utils    = require 'pandoc.utils'
local Options  = require 'pandock.options'

--- Release parameters.
local Release = {}

Release.__index = Release
setmetatable(Release, Release)

--- Create a new Release object from a pandoc metadata entry.
Release.new = function (version, parameters)
  local release = {}
  release.pandoc_version = tostring(version)
  release.version_tags = parameters['version-tags']:map(utils.stringify)
  release.base_images = {}
  for key, value in pairs(parameters['base-images']) do
    release.base_images[key] = utils.stringify(value)
  end
  release.addons = {}
  for key, value in pairs(parameters['addons']) do
    release.addons[key] = utils.stringify(value)
  end
  return setmetatable(release, Release)
end

Release.to_options_list = function (self)
  local options_list = pandoc.List()
  for stack, base_image_version in pairs(self.base_images) do
    options_list:insert(
      Options.new {
        stack = stack,
        base_image_version = base_image_version,
        pandoc_version = self.pandoc_version,
      }
    )
  end
  return options_list
end

return Release
