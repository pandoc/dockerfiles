--- Command line interface for the pandock util.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local io        = require 'io'

local pandoc    = require 'pandoc'

local bakefile  = require 'pandock.bakefile'
local Logger    = require 'pandock.logger'
local generator = require 'pandock.generator'
local state     = require 'pandock.state'

--- Command line interface
local cli = {}

--- Usage instructions for the CLI.
cli.usage = table.concat {
  'Usage: %s [OPTIONS] <command> ...\n',
  '',
  'Options:\n',
  '\t-r: path to the releases file\n',
  '\t-q: reduce verbosity, be more quiet; can be given multiple times\n',
  '\t-v: increase verbosity; can be given multiple times\n',
}

--- Parse command line arguments
cli.parse_global_args = function (args)
  local global_opts = pandoc.List()

  -- it's a list, but we can still use it as a dictionary, too.
  global_opts.releases_filepath = 'releases.yaml'
  global_opts.verbosity = 1
  global_opts.command_options = pandoc.List()

  local command
  local command_opts = pandoc.List()

  local i = 1
  while i <= #args do
    if args[i] == '-r' then
      global_opts.releases_filepath = args[i + 1]
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


cli.write_dockerfiles_for_version = function (appstate, pandoc_version)
  assert(pandoc_version, "pandoc version must be given")
  local opts_list = pandoc.List()
  for _, release in ipairs(appstate.releases) do
    if release.pandoc_version == pandoc_version then
      opts_list = release:to_options_list()
    end
  end
  if not next(opts_list) then
    error('Release not found: ' .. tostring(pandoc_version))
  end
  opts_list:map(generator.write_dockerfiles)
end

cli.commands = {

  bakefile = function (appstate, command_args)
    local pandoc_version = assert(command_args[1], 'pandoc version required')
    local release = appstate.releases:find_if(function (release)
        return release.pandoc_version == pandoc_version
    end)
    print(bakefile.generate_bake_file(release))
  end,

  generate = function (appstate, command_args)
    local pandoc_version = command_args[1]
    cli.write_dockerfiles_for_version(appstate, pandoc_version)
  end,

  tags = function (appstate, command_args)
    local tagmod         = require 'pandock.tag'
    local pandoc_version = assert(command_args[1], 'pandoc version required')
    local stack          = assert(command_args[2], 'stack required')
    local image          = assert(command_args[3], 'image type required')
    local release        = appstate.releases:find_if(function (release)
        return release.pandoc_version == pandoc_version
    end)
    local tags = tagmod.generate_tags_for_image(image, stack, release)
    if command_args:find('-l') then
      print(table.concat(tags, ','))
    else
      for tag in tags:iter() do
        print(tag)
      end
    end
  end
}

cli.run = function (args)
  local ok, global_opts, command_name, command_args =
    pcall(cli.parse_global_args, args)

  -- Set the logger
  generator.log = Logger(global_opts.verbosity)

  if not ok then
    io.stderr:write(tostring(global_opts) .. '\n')
    cli.show_usage_and_die(args[0])
  end

  local appstate = state.make_state(global_opts)

  local command_runner = cli.commands[command_name]
  if command_runner then
    command_runner(appstate, command_args)
  else
    io.stderr:write('Unknown command: "' .. command_name .. '"\n')
    io.stderr:write('Supported commands are:\n')
    local commands_list = pandoc.List(pairs(cli.commands))
    commands_list:sort()
    for name in commands_list:iter() do
      io.stderr:write('\t' .. name .. '\n')
    end
    os.exit(1)
  end
end

return cli
