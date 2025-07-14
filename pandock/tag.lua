--- Create docker image tags
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc   = require 'pandoc'
local List     = require 'pandoc.List'

--- The "tag" module.
local tag = {}

local default_stack_for_image = {
  minimal = 'static',
  core    = 'alpine',
  latex   = 'alpine',
  extra   = 'alpine',
  typst   = 'alpine',
}

local default_tagging_options = {
  image_name = 'minimal',
  stack = 'static',
  version_tags = {'edge'},
  extra_registries = List{'ghcr.io'},
  short_tags = true,
}

local tag_format_full = 'pandoc/%s:%s-%s'
local tag_format_short = 'pandoc/%s:%s'

--- Default Dockerfile-generation options.
tag.generate_tags = function (tags_opts)
  local tags = List()

  -- Generate all (repo-independent) tags
  for version in List(tags_opts.version_tags):iter() do
    tags:insert(
      tag_format_full:format(tags_opts.image_name, version, tags_opts.stack)
    )
    if tags_opts.short_tags then
      tags:insert(
        tag_format_short:format(tags_opts.image_name, version)
      )
    end
  end

  -- Add prefixes:
  for reg in List(tags_opts.extra_registries):iter() do
    for i = 1, #tags do
      tags:insert(reg .. '/' .. tag[i])
    end
  end

  return tags
end

tag.generate_tags_for_image = function (name, stack, release)
  return tag.generate_tags {
    image_name   = name,
    stack        = stack,
    version_tags = release.version_tags,
    short_tags   = default_stack_for_image[name] == stack,
  }
end


return tag
