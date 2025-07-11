--- Create a bake file for a release.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc      = require 'pandoc'
local List        = require 'pandoc.List'
local json        = require 'pandoc.json'
local BuildTarget = require 'pandock.type.BuildTarget'

local Version     = pandoc.types.Version

--- Bakefile action
local action = {}

local function build_targets_for_release (variants, release)
  local targets = List()
  for variant in variants:iter() do
    local base_images = List(pairs(release.base_image))
    -- sort to get a fixed, reproducible order
    base_images:sort()
    targets:extend(
      base_images:map(
        function (stack)
          return BuildTarget.new {
            pandoc_version = release.pandoc_version,
            stack = stack,
            variant = variant,
            version_tags = release.version_tags,
          }
        end
      )
    )
  end
  return targets
end

local function make_bake_target (build_target)
  return {
    dockerfile = build_target:dockerfile_filepath(),
    labels = build_target:labels(),
    tags = build_target:tags(),
    target = build_target:target(),
  }
end

local function generate_bake_config (build_targets)
  return {
    group = {
      default = {
        targets = List{'core'},
      }
    },
    target = build_targets:map(make_bake_target),
  }
end

action.run = function (app, args)
  local pandoc_version = args[1]
  local config = app.config
  local release = config.release[pandoc_version]
  assert(release, 'No release found for ' .. tostring(pandoc_version))
  local build_targets = build_targets_for_release(config.variants, release)

  local bake_config = generate_bake_config(build_targets)

  print(json.encode(pandoc.Meta(bake_config)))
end

return action





