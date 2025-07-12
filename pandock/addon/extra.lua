--- Handle options and parameters for Typst images
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local List   = require 'pandoc.List'
local system = require 'pandock.system'

local extra_packages_filepath = 'common/extra/packages.txt'
local extra_python_requirements = 'common/extra/requirements.txt'

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

local function addon_context (extra, release)
  return {
    ['packages'] = get_packages(extra_packages_filepath),
    ['eisvogel'] = release.addon.extra.eisvogel,
    ['python']   = release.addon.extra.python
  }
end

return {
  addon_context = addon_context,
}
