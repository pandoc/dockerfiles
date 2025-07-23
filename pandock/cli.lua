--- Command line interface for the pandock util.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local io        = require 'io'

local pandoc    = require "pandoc"
local App       = require "pandock.type.App"

--- Command line interface
local cli = {}

--- Usage instructions for the CLI.
cli.usage = table.concat {
  'Usage: %s [OPTIONS] <command> ...\n',
  '',
  'Options:\n',
  '\t-c: path to the config file\n',
  '\t-q: reduce verbosity, be more quiet; can be given multiple times\n',
  '\t-v: increase verbosity; can be given multiple times\n',
}

--- Parse command line arguments
cli.parse_global_args = function (args)
  local global_opts = pandoc.List()

  -- it's a list, but we can still use it as a dictionary, too.
  global_opts.config_filepath = 'config.yaml'
  global_opts.verbosity = 1
  global_opts.command_options = pandoc.List()

  local command
  local command_opts = pandoc.List()

  local i = 1
  while i <= #args do
    if args[i] == '-c' then
      global_opts.config_filepath = args[i + 1]
      i = i + 2
    elseif args[i] == '-q' then
      global_opts.verbosity = global_opts.verbosity - 1
      i = i + 1
    elseif args[i] == '-v' then
      global_opts.verbosity = global_opts.verbosity + 1
      i = i + 1
    elseif args[i]:match '^%-' then
      error('Unknown option: ' .. tostring(args[i]))
    else
      command = args[i]
      for j = i+1, #args do
        command_opts:insert(args[j])
      end
      break
    end
  end

  if not command then
    error('No command given')
  end

  return global_opts, command, command_opts
end

--- Print usage instructions to stderr, then exit with code 1.
cli.show_usage_and_die = function (progname)
  io.stderr:write(cli.usage:format(progname))
  os.exit(1)
end

cli.commands = {
  bakefile   = require "pandock.action.bakefile",
  dockerfile = require "pandock.action.dockerfile",
  generate   = require "pandock.action.generate",
  list       = require "pandock.action.list",
  ['short-description'] = require "pandock.action.short-description",
}

cli.run = function (args)
  local ok, global_opts, command_name, command_args =
    pcall(cli.parse_global_args, args)

  if not ok then
    io.stderr:write(tostring(global_opts) .. '\n')
    cli.show_usage_and_die(args[0])
  end

  -- Setup the app that runs things
  local app = App(global_opts.verbosity, "config.yaml", cli.commands)

  app:run_command(command_name, command_args)
end

return cli
