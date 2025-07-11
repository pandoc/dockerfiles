--- Write a single Dockerfile
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local template = require 'pandoc.template'
local yaml     = require 'pandock.yaml'

local context        = require 'pandock.context'
local DockerfileSpec = require 'pandock.type.DockerfileSpec'

--- dockerfile action
local action = {}

--- Returns the Dockerfile contents for the given options.
local generate_dockerfile = function (spec, ctx)
  local tmpl = spec:get_template()
  return template.apply(tmpl, ctx):render()
end

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
  local ctx     = context.create_context(spec, release, addon)

  app.logger:debug('Generating Dockerfile with context:')
  app.logger:debug(yaml.encode(ctx))
  local output  = generate_dockerfile(spec, ctx)
  print(output)
end

return action
