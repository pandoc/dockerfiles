--- Generate cabal options
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local List   = require 'pandoc.List'
local path   = require 'pandoc.path'
local system = require 'pandock.system'

--- The cabal module
local cabal = {}

local function get_freeze_file_contents(pandoc_version, stack)
  local freeze_file_path = path.join{
    stack,
    'freeze',
    string.format('pandoc-%s.project.freeze', pandoc_version)
  }
  return system.read_file(freeze_file_path)
end

local function get_constraints(opts)
  local constr = 'constraints: '
  local constr_pattern = '\n' .. string.rep(' ', #constr) .. '([^\n,]*)'

  -- replace the initial 'constraints: ' to make the list of constraints
  -- more uniform
  local freeze_file_contents = get_freeze_file_contents(
    opts.pandoc_version,
    opts.stack
  ):gsub(constr, string.rep(' ', #constr))

  local constraints = List{}
  for constraint in freeze_file_contents:gmatch(constr_pattern) do
    constraints:insert(constraint)
  end
  return constraints
end

cabal.get_cabal_options = function (opts)
  return {
    constraints = get_constraints(opts)
  }
end

return cabal
