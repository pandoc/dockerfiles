--- Write a single Dockerfile
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local template = require 'pandoc.template'
local yaml     = require 'pandock.yaml'

local context        = require 'pandock.context'
local dockerfile     = require 'pandock.dockerfile'
local DockerfileSpec = require 'pandock.type.DockerfileSpec'

--- dockerfile action
local action = {}

action.run = function (app, args)
  local pandoc_version = assert(args[1], 'pandoc version required')
  local stack          = assert(args[2], 'stack required')
  local addon_name     = args[3] -- addon is optional

  local spec = DockerfileSpec.new {
    pandoc_version = pandoc_version,
    stack = stack,
    addon = addon_name,
  }

  local config = app.config
  local release = assert(
    config.release[spec.pandoc_version],
    'No release found for ' .. tostring(spec.pandoc_version)
  )
  local addon   = spec.addon and config.addon[spec.addon]
  if addon then
    addon.name = spec.addon
  end

  local output  = dockerfile.generate(app, release, spec.stack, addon)
  print(output)
end

return action
