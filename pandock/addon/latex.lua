--- Handle options and parameters for LaTeX images
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local List   = require 'pandoc.List'
local system = require 'pandock.system'

local latex_packages_filepath = 'common/latex/packages.txt'
local texlive_profile_filepath = 'common/latex/texlive.profile'

local function get_packages (filepath)
  local contents = system.read_file(filepath)
  local packages = List()
  for line in contents:gmatch('[^\n]+') do
    packages:insert((line:gsub('%s*%#.*', '')))
  end
  packages:sort()
  return packages:filter(function (pkg)
      return #pkg > 0
  end)
end

local function addon_context (args)
  -- for key, value in pairs(type(args) == 'table' and args.addon or {}) do
  --   io.stderr:write(tostring(key) .. '\t' .. tostring(value) .. '\n')
  -- end
  local version = "2025"
  local default_version = "2025"
  return {
    ['packages']        = get_packages(latex_packages_filepath),
    ['texlive'] = {
      ['is-current'] = version == default_version, -- FIXME!
      ['profile'] = system.read_file(texlive_profile_filepath),
      ['version'] = version,
    }
  }
end

return {
  addon_context = addon_context,
}
