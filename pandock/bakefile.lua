--- Create Docker bake files
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc      = require 'pandoc'
local List        = require 'pandoc.List'
local json        = require 'pandoc.json'
local path        = require 'pandoc.path'
local BuildTarget = require 'pandock.type.BuildTarget'

--- Bakefile module
local bakefile = {}

local function make_bake_target (build_target)
  -- Get the path to the dockerfile, relative to the bake file.
  local dockerfile_path = build_target:dockerfile_filepath()
  local dockerfile_path_components = List(path.split(dockerfile_path))
  dockerfile_path_components:remove(1)
  local dockerfile_relative_path = path.join(dockerfile_path_components)
  return {
    dockerfile = dockerfile_relative_path,
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

bakefile.for_build_targets = function (build_targets)
  local bake_config = bakefile.generate_bake_config(build_targets)
  return json.encode(bake_config)

end

bakefile.generate_bake_json = function (release, variants)
  local build_targets = BuildTarget.targets_for_release(release, variants)
  return bakefile.for_build_targets(build_targets)
end

return bakefile
