--- Command line interface for the pandock util.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc   = require 'pandoc'

--- Command line interface
local cli = {}

--- Usage instructions for the CLI.
cli.usage = table.concat {
  'Usage: %s [OPTIONS] <pandoc_version> [<build_stack>]\n',
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

  opts.pandoc_version = positional_args[1]
  opts.stack = positional_args[2]

  if not opts.pandoc_version then
    error('Expected at least 1 positional argument')
  end

  return opts
end

cli.run = function (args)
  local opts = cli.parse_args(args):check()
end

return cli
