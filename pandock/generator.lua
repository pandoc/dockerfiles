--- Dockerfile generator
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local io       = require 'io'
local pandoc   = require 'pandoc'
local path     = require 'pandoc.path'
local system   = require 'pandoc.system'
local template = require 'pandoc.template'
local Logger   = require 'pandock.logger'

--- Dockerfile generator
local generator = {
  log = Logger()
}

generator.log.verbosity = 4

--- Returns the contents of a file.
local function read_file (filepath)
  local fh = io.open(filepath, 'rb')
  if fh then
    local content = fh:read('a')
    fh:close()
    return content
  else
    error('Could not open filepath ' .. filepath .. ' for reading.')
  end
end

--- Returns the contents of a file.
local function write_file (filepath, contents)
  local fh = io.open(filepath, 'wb')
  if fh then
    fh:write(contents)
    fh:close()
  else
    error('Could not open filepath ' .. filepath .. ' for writing.')
  end
end

--- Returns the correct template for the given options.
local function get_template(options, addon)
  local template_path = addon
    and path.join{options.stack, addon, 'Dockerfile.tmpl'}
    or  path.join{options.stack, 'Dockerfile.tmpl'}
  if options.pandoc_version == 'main' then
    template_path = path.join{'edge', template_path}
  end
  return read_file(template_path)
end

--- Stringify a template context by turning it into YAML.
local function context_to_yaml(context)
  local opts = {
    template = '$titleblock$'
  }
  return pandoc.write(pandoc.Pandoc({}, context), 'commonmark_x', opts)
end

--- Returns the Dockerfile contents for the given options.
generator.generate_dockerfile = function (opts, addon)
  local tmpl = get_template(opts, addon)
  local context = opts:to_context()
  context.cabal_constraints = (require 'pandock.cabal')(opts)
  generator.log:info(
    'Generating template with context:\n' .. context_to_yaml(context)
  )
  return template.apply(tmpl, context):render()
end

--- Writes a Dockerfile for a release.
--
-- The default (minimal&core) Dockerfile is built unless `addon` is
-- specified.
generator.write_dockerfile = function(opts, addon)
  generator.log:warn(
    'Generating Dockerfile for pandoc/%s:%s-%s',
    addon or 'core',
    opts.pandoc_version,
    opts.stack
  )
  local target_dir = path.join{opts.pandoc_version, opts.stack, addon}
  local df = generator.generate_dockerfile(opts, addon)
  local df_path = path.join{target_dir, 'Dockerfile'}
  generator.log:debug('Ensuring that target directory %s exists…', target_dir)
  system.make_directory(target_dir, true)
  generator.log:info('Writing file %s…', df_path)
  write_file(df_path, df)
end

--- Writes all Dockerfiles for a release
generator.write_dockerfiles = function(opts)
  -- the main Dockerfile
  generator.write_dockerfile(opts)
  if opts.stack ~= 'static' then
    -- Addon Dockerfiles
    for addon in pairs(opts.addon) do
      generator.write_dockerfile(opts, addon)
    end
  end
end

return generator
