#!/usr/bin/env pandoc-lua

local arg = arg

local io       = require 'io'

local pandoc   = require 'pandoc'
local path     = require 'pandoc.path'
local system   = require 'pandoc.system'
local template = require 'pandoc.template'

local Logger   = require 'pandock.logger'
local Options  = require 'pandock.options'

local usage = table.concat {
  'Usage: %s [OPTIONS] <build_stack> <pandoc_version>\n',
  '',
  'Options:\n',
  '\t-b: version tag of the base image\n',
  '\t-s: set the stack\n',
  '\t-v: increase verbosity; can be given multiple times\n',
}

local log = Logger()

--- Print usage instructions to stderr, then exit with code 1.
local function show_usage_and_die ()
  io.stderr:write(usage:format(arg[0]))
  os.exit(1)
end

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

--- Parse command line arguments
local function parse_args (args)
  local ok, opts = pcall(Options.from_args, args)
  if not ok then
    io.stderr:write(tostring(opts) .. '\n')
    show_usage_and_die()
  end

  return opts
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
local function get_dockerfile(opts)
  local tmpl = get_template(opts)
  return template.apply(tmpl, opts:to_context()):render()
end

--- Writes the Dockerfile
local function write_dockerfile(opts)
  local target_dir = path.join{opts.pandoc_version, opts.stack}
  local df = get_dockerfile(opts)
  local df_path = path.join{target_dir, 'Dockerfile'}
  log:debug('Ensuring that target directory %s exists…', target_dir)
  system.make_directory(target_dir, true)
  log:debug('Writing file %s…', df_path)
  write_file(df_path, df)
end

------------------------------------------------------------------------

local opts = parse_args(arg):check()

log.verbosity = opts.verbosity

if opts.verbosity >= 1 then
  io.stderr:write("Options:\n")
  local options_rows = pandoc.List()
  for key, value in pairs(opts) do
    options_rows:insert({pandoc.Blocks(key), pandoc.Blocks(tostring(value))})
  end
  local align = {pandoc.AlignDefault, pandoc.AlignDefault}
  local options_table = pandoc.utils.from_simple_table(
    pandoc.SimpleTable({}, align, {0, 0}, {{}, {}}, options_rows)
  )
  io.stderr:write(pandoc.write(pandoc.Pandoc({options_table}), 'plain'))
  io.stderr:write('\n')
end

write_dockerfile(opts)
