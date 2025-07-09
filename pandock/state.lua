--- Global application state
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc    = require 'pandoc'
local system    = require 'pandock.system'
local Logger    = require 'pandock.logger'
local Release   = require 'pandock.release'
local yaml      = require 'pandock.yaml'

local M = {}

--- Retrieve a list of releases from the given file.
-- The list is sorted by release version in descending order.
local function get_releases (filename)
  local contents = system.read_file(filename)
  local releases_yaml = yaml.parse(contents)
  local releases = pandoc.List()
  for key, value in pairs(releases_yaml.releases) do
    releases:insert(Release.new(key, value, releases_yaml))
  end
  return releases
end

M.make_state = function (opts)
  return {
    releases = get_releases(opts.releases_filepath),
    log = Logger(opts.verbosity),
  }
end

return M
