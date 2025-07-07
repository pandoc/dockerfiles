--- Command line interface for the pandock util.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local io        = require 'io'

local pandoc    = require 'pandoc'
local system    = require 'pandoc.system'

local Logger    = require 'pandock.logger'
local Release   = require 'pandock.release'
local generator = require 'pandock.generator'

--- Command line interface
local cli = {}

--- Usage instructions for the CLI.
cli.usage = table.concat {
  'Usage: %s [OPTIONS] <command> <pandoc_version>\n',
  '',
  'Options:\n',
  '\t-b: version tag of the base image\n',
  '\t-q: reduce verbosity, be more quiet; can be given multiple times\n',
  '\t-v: increase verbosity; can be given multiple times\n',
}

--- Parse command line arguments
cli.parse_args = function (args)
  local opts = {
    verbosity = 1
  }
  local positional_args = pandoc.List()

  local i = 1
  while i <= #args do
    if args[i] == '-b' then
      opts.base_image_version = args[i + 1]
      i = i + 2
    elseif args[i] == '-v' then
      opts.verbosity = opts.verbosity + 1
      i = i + 1
    elseif args[i] == '-q' then
      opts.verbosity = opts.verbosity - 1
      i = i + 1
    elseif args[i]:match '^%-' then
      error('Unknown option: ' .. tostring(args[i]))
    else
      positional_args:insert(args[i])
      i = i + 1
    end
  end

  local command = positional_args[1]
  opts.pandoc_version = positional_args[2]
  opts.stack = positional_args[3]

  if not opts.pandoc_version then
    error('Expected at least 1 positional argument')
  end

  return command, opts
end

--- Print usage instructions to stderr, then exit with code 1.
cli.show_usage_and_die = function (progname)
  io.stderr:write(cli.usage:format(progname))
  os.exit(1)
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

cli.write_dockerfiles_for_version = function (pandoc_version, releases)
  assert(pandoc_version, "pandoc version must be given")
  local opts_list = pandoc.List()
  for _, release in ipairs(releases) do
    if release.pandoc_version == pandoc_version then
      opts_list = release:to_options_list()
    end
  end
  if not next(opts_list) then
    error('Release not found: ' .. tostring(pandoc_version))
  end
  opts_list:map(generator.write_dockerfiles)
end

cli.run = function (args)
  local ok, command, cli_opts = pcall(cli.parse_args, args)

  -- Set the logger
  generator.log = Logger(cli_opts.verbosity)

  if not ok then
    io.stderr:write(tostring(cli_opts) .. '\n')
    cli.show_usage_and_die(args[0])
  end
  local releases = get_releases('releases.yaml')
  if command == 'generate' then
    cli.write_dockerfiles_for_version(cli_opts.pandoc_version, releases)
  end
end

return cli
