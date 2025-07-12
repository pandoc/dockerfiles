--- Handle options and parameters for Typst images
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local List   = require 'pandoc.List'
local system = require 'pandock.system'

local function addon_context (extra, release)
  return release.addon.extra
end

return {
  addon_context = addon_context,
}
