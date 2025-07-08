--- Create Docker bake files
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc   = require 'pandoc'
local List     = require 'pandoc.List'
local json     = require 'pandoc.json'
local path     = require 'pandoc.path'
local system   = require 'pandock.system'
local tag      = require 'pandock.tag'

--- The "tag" module.
local M = {}

local image_titles = {
  ['minimal'] = 'pandoc (minimal)',
  ['core']    = 'pandoc',
  ['latex']   = 'pandoc with LaTeX',
  ['extra']   = 'pandoc with LaTeX and extras',
  ['typst']   = 'pandoc with Typst',
}

local function image_description (imgtype)
  --- The image type / repository name
  local inputfile = 'docs/short-descriptions.md'
  local contents = system.read_file(inputfile)
  local doc = pandoc.read(contents)
  assert(doc.meta[imgtype], "No description found for image type " .. imgtype)
  return pandoc.utils.stringify(doc.meta[imgtype])
end

M.image_labels = function (release, image_type)
  local description = image_description(image_type)
  return {
    ['org.opencontainers.image.authors'] = 'Albert Krewinkel <albert+pandoc@tarleb.com>',
    ['org.opencontainers.image.description'] = description,
    ['org.opencontainers.image.licenses'] = 'GPL-2.0',
    ['org.opencontainers.image.source'] = 'https://github.com/pandoc/dockerfiles',
    ['org.opencontainers.image.title'] = image_titles[image_type] or 'pandoc',
    ['org.opencontainers.image.url'] = 'https://github.com/pandoc/dockerfiles',
    ['org.opencontainers.image.vendor'] = 'The pandoc Docker team',
    ['org.opencontainers.image.version'] = release.pandoc_version,

  }
end

M.generate_bake_file = function(release)
  local bake_config = {
    group = {
      default = {
        targets = List{'core'}
      }
    }
  }
  bake_config.target = {}
  for stack in pairs(release.base_images) do
    for _, imgtype in ipairs{'minimal', 'core'} do
      local target = stack .. '-' .. imgtype
      bake_config.target[target] = {
        dockerfile = path.join{release.pandoc_version, stack, 'Dockerfile'},
        labels = M.image_labels(release, imgtype),
        tags = tag.generate_tags_for_image(imgtype, stack, release),
        target = imgtype,
      }
    end
    for addon in pairs(release.addon) do
      local target = stack .. '-' .. addon
      bake_config.target[target] = {
        dockerfile = path.join{
          release.pandoc_version, stack, addon, 'Dockerfile'
        },
        labels = M.image_labels(release, addon),
        tags = tag.generate_tags_for_image(addon, stack, release)
      }
    end
  end

  return json.encode(bake_config)
end

return M
