--- Create Docker bake files
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc      = require 'pandoc'
local List        = require 'pandoc.List'
local json        = require 'pandoc.json'
local BuildTarget = require 'pandock.type.BuildTarget'

--- Bakefile module
local bakefile = {}

local function make_bake_target (build_target)
  return {
    dockerfile = build_target:dockerfile_filepath(),
    labels = build_target:labels(),
    tags = build_target:tags(),
    target = build_target:target(),
  }
end

bakefile.generate_bake_config = function (build_targets)
  local target = {}
  for bt in build_targets:iter() do
    local name = bt.stack .. '-' .. bt.variant.name
    target[name] = make_bake_target(bt)
  end

  return {
    group = {
      default = {
        targets = List{'core'},
      }
    },
    target = target
  }
end

bakefile.generate_bake_json = function (release, variants)
  local build_targets = BuildTarget.targets_for_release(release, variants)
  local bake_config = bakefile.generate_bake_config(build_targets)
  return json.encode(bake_config)
end

return bakefile
