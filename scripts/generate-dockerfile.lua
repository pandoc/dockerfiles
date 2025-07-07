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
  for key, value in pairs(doc.meta.releases) do
    releases:insert(Release.new(key, value, doc.meta))
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

