--- pandoc releases and their parameters
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc   = require 'pandoc'
local utils    = require 'pandoc.utils'
local Options  = require 'pandock.dockerfile.options'
local yaml     = require 'pandock.yaml'

--- Release parameters.
local Release = {}

Release.__index = Release
setmetatable(Release, Release)

local function addon_context (addon, args, parameters)
  local context = {}
  -- Do some special handling for addons
  if addon == 'typst' then
    -- Hashes of the Typst archives
    context.hashes = (parameters['typst-hashes'] or {})[args.typst]
  elseif addon == 'latex' then
    local latex = require 'pandock.addon.latex'
    return latex.addon_context(args)
  end
  return context
end

--- Create a new Release object from a pandoc metadata entry.
Release.new = function (version, release_args, extra_parameters)
  local release = {
    pandoc_version = pandoc.utils.stringify(version),
    version_tags   = release_args['version-tags'],
    base_images    = release_args['base-image'],
    addon          = release_args['addon'],
    tags           = release_args['tags'],
  }
  for addon, addon_args in pairs(release.addon) do
    local context = addon_context(addon, addon_args, extra_parameters)
    for key, value in pairs(context) do
      release.addon[addon][key] = value
    end
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
        addon = self.addon,
      }
    )
  end
  return options_list
end

return Release
