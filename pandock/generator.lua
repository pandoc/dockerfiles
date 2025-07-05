--- Dockerfile generator
--
-- Copyright  : © Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local io       = require 'io'
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
local function get_template(options)
  local template_path = path.join{
    options.stack,
    'Dockerfile.tmpl'
  }
  if options.pandoc_version == 'main' then
    template_path = path.join{'edge', template_path}
  end
  return read_file(template_path)
end

--- Returns the Dockerfile contents for the given options.
generator.generate_dockerfile = function (opts)
  local tmpl = get_template(opts)
  local context = opts:to_context()
  context.cabal_constraints = (require 'pandock.cabal')(opts)
  return template.apply(tmpl, context):render()
end

--- Writes the Dockerfile
generator.write_dockerfile = function(opts)
  local target_dir = path.join{opts.pandoc_version, opts.stack}
  local df = generator.generate_dockerfile(opts)
  local df_path = path.join{target_dir, 'Dockerfile'}
  generator.log:debug('Ensuring that target directory %s exists…', target_dir)
  system.make_directory(target_dir, true)
  generator.log:info('Writing file %s…', df_path)
  write_file(df_path, df)
end

return generator
