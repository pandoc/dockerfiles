--- pandoc releases and their parameters
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc   = require 'pandoc'
local utils    = require 'pandoc.utils'
local Options  = require 'pandock.dockerfile.options'

--- Release parameters.
local Release = {}

Release.__index = Release
setmetatable(Release, Release)

--- Remove Inlines and Blocks from a meta tree.
local function stringify_meta (tree)
  local ty = pandoc.utils.type(tree)
  if ty == 'table' or ty == 'Meta' or ty == 'List' then
    local new = setmetatable({}, getmetatable(tree))
    for key, value in pairs(tree) do
      new[key] = stringify_meta(value)
    end
    return new
  elseif ty == 'string' or ty == 'boolean' then
    return tree
  elseif ty == 'Inlines' or ty == 'Blocks' then
    return utils.stringify(tree)
  else
    error('stringify_meta does not know how to handle ' .. ty)
  end
end

local function addon_context (addon, args, parameters)
  local context = {}
  -- Do some special handling for addons
  if addon == 'typst' then
    -- Hashes of the Typst archives
    context.hashes = (parameters['typst-hashes'] or {})[args.typst]
  end
  return context
end

--- Create a new Release object from a pandoc metadata entry.
Release.new = function (version, release_args, extra_parameters)
  -- Ensure that we have a full copy with strings instead of Inlines,
  -- Blocks.
  release_args = stringify_meta(release_args)
  extra_parameters = stringify_meta(extra_parameters or {})

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
