--- Create Docker bake files
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc   = require 'pandoc'
local List     = require 'pandoc.List'
local json     = require 'pandoc.json'
local path     = require 'pandoc.path'
local tag      = require 'pandock.tag'

--- The "tag" module.
local M = {}

M.generate_bake_file = function(release)
  local bake_config = {
    group = {
      default = {
        targets = List{'minimal', 'core'}
      }
    }
  }
  bake_config.target = {}
  for stack in pairs(release.base_images) do
    for _, imgtype in ipairs{'minimal', 'core'} do
      bake_config.target[stack .. '-' .. imgtype] = {
        dockerfile = path.join{release.pandoc_version, stack, 'Dockerfile'},
        tags = tag.generate_tags_for_image(imgtype, stack, release)
      }
    end
    for addon in pairs(release.addon) do
      bake_config.target[stack .. '-' .. addon] = {
        dockerfile = path.join{
          release.pandoc_version, stack, addon, 'Dockerfile'
        },
        tags = tag.generate_tags_for_image(addon, stack, release)
      }
    end
  end

  return json.encode(bake_config)
end

return M
