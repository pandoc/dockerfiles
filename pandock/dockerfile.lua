--- Generate a single Dockerfile
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local template = require 'pandoc.template'
local yaml     = require 'pandock.yaml'

local context        = require 'pandock.context'
local DockerfileSpec = require 'pandock.type.DockerfileSpec'

--- dockerfile action
local M = {}

--- Returns the Dockerfile contents for the given options.
local generate_dockerfile = function (spec, ctx)
  local tmpl = spec:get_template()
  return template.apply(tmpl, ctx):render()
end

--- Returns the Dockerfile contents for the given options.
M.generate = function (app, release, stack, addon)
  local spec = DockerfileSpec.new {
    pandoc_version = release.pandoc_version,
    stack = stack,
    addon = addon and addon.name,
  }

  local ctx     = context.create_context(spec, release, addon)

  app.logger:debug('Generating Dockerfile with context:')
  app.logger:debug(yaml.encode(ctx))
  return generate_dockerfile(spec, ctx)
end

return M
