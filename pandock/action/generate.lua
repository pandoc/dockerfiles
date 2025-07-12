--- Generate all files for a release.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc      = require 'pandoc'
local List        = require 'pandoc.List'
local path        = require 'pandoc.path'
local bakefile    = require 'pandock.bakefile'
local dockerfile  = require 'pandock.dockerfile'
local context     = require 'pandock.context'
local system      = require 'pandock.system'
local yaml        = require 'pandock.yaml'
local BuildTarget = require 'pandock.type.BuildTarget'

--- generate action
local action = {}

action.run = function (app, args)
  local pandoc_version = assert(args[1], 'Pandoc version required')
  local config = app.config
  local release = config.release[pandoc_version]
  assert(release, 'No release found for ' .. tostring(pandoc_version))

  local buildtargets = BuildTarget.targets_for_release(release, config.variants)

  local bakefile_path = path.join{pandoc_version, 'docker-bake.json'}
  local bake_config = bakefile.for_build_targets(buildtargets)
  app.logger:debug('Ensure that directory exists: %s', pandoc_version)
  system.make_directory(pandoc_version, true)
  app.logger:info('Writing bake config to %s.', bakefile_path)
  system.write_file(bakefile_path, bake_config)

  for bt in buildtargets:iter() do
    local spec = bt:to_dockerfile_spec()
    local addon = nil
    if spec.addon then
      addon = spec.addon and config.addon[spec.addon]
      addon.name = spec.addon
    end

    local target_filepath = spec:target_filepath()
    local target_dir = path.directory(target_filepath)
    app.logger:debug('Ensure that directory exists: %s', target_dir)
    system.make_directory(target_dir, true)
    system.write_file(
      target_filepath,
      dockerfile.generate(release, spec.stack, addon)
    )
  end
end

return action





