--- Parse the config file
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local Variant = require 'pandock.type.Variant'
local Release = require 'pandock.type.Release'
local system  = require 'pandock.system'
local yaml    = require 'pandock.yaml'

local M = {
  config_filepath = 'config.yaml'
}

local function get_release_map (rawconfig)
  local releases = {}
  for commit, spec in pairs(rawconfig.release) do
    local version = commit == 'main' and 'edge' or commit
    local release = Release.new(spec)
    release['pandoc-version'] = version
    release['pandoc-commit'] = commit
    releases[version] = release
  end
  return releases
end

M.get_config = function (filepath)
  filepath = filepath or M.config_filepath
  local rawconfig = yaml.decode(system.read_file(filepath))

  return {
    release  = get_release_map(rawconfig),
    addon    = rawconfig.addon,
    variants = rawconfig.variants:map(Variant.new)
  }
end

return M
