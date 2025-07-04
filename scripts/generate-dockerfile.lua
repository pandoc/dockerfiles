#!/usr/bin/env pandoc-lua

local arg = arg

local io       = require 'io'

local pandoc   = require 'pandoc'
local path     = require 'pandoc.path'
local system   = require 'pandoc.system'
local template = require 'pandoc.template'

local usage = table.concat {
  'Usage: %s [OPTIONS] <build_stack> <pandoc_version>\n',
  '',
  'Options:\n',
  '\t-b: version tag of the base image\n',
  '\t-s: set the stack\n',
  '\t-v: increase verbosity; can be given multiple times\n',
}

--- Default Dockerfile-generation options.
local default_options = {
  stack = 'ubuntu',
  base_image_version = 'nobel',
  pandoc_version = 'edge',
  verbosity = 0,
}

--- Dockerfile options.
local Options = {}
Options.defaults = default_options
Options.new = function ()
  return setmetatable({}, Options)
end
Options.__index = function (t, key)
  local mt = getmetatable(t)
  return rawget(mt.defaults, key) or rawget(mt, key)
end
Options.__newindex = function (t, key, value)
  if getmetatable(t).defaults[key] then
    rawset(t, key, value)
  else
    error('Unknown option "' .. tostring(key) .. '"')
  end
end
Options.__pairs = function (t)
  local next_default = function (defs, index)
    local key, def = next(defs, index)
    local actual = rawget(t, key)
    if actual ~= nil then
      return key, actual
    else
      return key, def
    end
  end
  return next_default, getmetatable(t).defaults, nil
end
Options.to_context = function (self)
  local context = {}
  for key, value in pairs(self) do
    context[key] = value
  end
  return context
end
--- Validate the options sanity
Options.check = function(self)
  assert(
    self.pandoc_version == 'main' or
    pcall(pandoc.types.Version, self.pandoc_version),
    'Invalid pandoc version "' .. tostring(self.pandoc_version) .. '"'
  )
  return self
end

--- Print usage instructions to stderr, then exit with code 1.
local function show_usage_and_die ()
  io.stderr:write(usage:format(arg[0]))
  os.exit(1)
end

local function debug(opts, message, ...)
  if opts.verbosity >= 1 then
    io.stderr:write(tostring(message):format(...))
    io.stderr:write('\n')
  end
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
  local opts = Options.new()
  local positional_args = pandoc.List()

  do
    local i = 1
    while i <= #args do
      if args[i] == '-b' then
        opts.base_image_version = args[i + 1]
        i = i + 2
      elseif args[i] == '-v' then
        opts.verbosity = opts.verbosity + 1
        i = i + 1
      elseif args[i]:match '^%-' then
        show_usage_and_die()
      else
        positional_args:insert(args[i])
        i = i + 1
      end
    end
  end

  if not #positional_args == 2 then
    show_usage_and_die()
  end
  opts.stack = positional_args[1]
  opts.pandoc_version = positional_args[2]

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

local function get_dockerfile(opts)
  local tmpl = get_template(opts)
  return template.apply(tmpl, opts:to_context()):render()
end

local function write_dockerfile(opts)
  local target_dir = path.join{opts.pandoc_version, opts.stack}
  local df = get_dockerfile(opts)
  local df_path = path.join{target_dir, 'Dockerfile'}
  debug(opts, 'Ensuring that target directory %s exists…', target_dir)
  system.make_directory(target_dir, true)
  debug(opts, 'Writing file %s…', df_path)
  write_file(df_path, df)
end

------------------------------------------------------------------------

local opts = parse_args(arg):check()

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
