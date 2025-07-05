#!/usr/bin/env pandoc-lua

local arg = arg

local io        = require 'io'

local pandoc    = require 'pandoc'
local system    = require 'pandoc.system'

local cli       = require 'pandock.cli'
local Logger    = require 'pandock.logger'
local Release   = require 'pandock.release'
local generator = require 'pandock.generator'

local log = Logger()

--- Print usage instructions to stderr, then exit with code 1.
local function show_usage_and_die ()
  io.stderr:write(cli.usage:format(arg[0]))
  os.exit(1)
end

--- Parse command line arguments
local function parse_args (args)
  local ok, opts = pcall(cli.parse_args, args)
  if not ok then
    io.stderr:write(tostring(opts) .. '\n')
    show_usage_and_die()
  end

  return opts
end

--- Retrieve a list of releases from the given file.
-- The list is sorted by release version in descending order.
local function get_releases (filename)
  local contents = system.read_file(filename)
  local doc = pandoc.read(contents, 'commonmark_x')
  local releases = pandoc.List()
  for key, value in pairs(doc.meta) do
    releases:insert(Release.new(key, value))
  end
  return releases
end

------------------------------------------------------------------------

local cli_opts = parse_args(arg)

log.verbosity = cli_opts.verbosity

generator.log = log

if cli_opts.verbosity >= 1 then
  io.stderr:write("Options:\n")
  local options_rows = pandoc.List()
  for key, value in pairs(cli_opts) do
    options_rows:insert({pandoc.Blocks(key), pandoc.Blocks(tostring(value))})
  end
  local align = {pandoc.AlignDefault, pandoc.AlignDefault}
  local options_table = pandoc.utils.from_simple_table(
    pandoc.SimpleTable({}, align, {0, 0}, {{}, {}}, options_rows)
  )
  io.stderr:write(pandoc.write(pandoc.Pandoc({options_table}), 'plain'))
  io.stderr:write('\n')
end

local releases = get_releases('releases.yaml')
local opts_list = pandoc.List()
if cli_opts.pandoc_version then
  for _, release in ipairs(releases) do
    if release.pandoc_version == cli_opts.pandoc_version then
      opts_list = release:to_options_list()
    end
  end
  if not next(opts_list) then
    error('Release not found: ' .. tostring(cli_opts.pandoc_version))
  end
end
opts_list:map(generator.write_dockerfile)
