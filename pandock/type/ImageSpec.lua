--- Build target
--
-- Object that uniquely defines a docker build target.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local List           = require 'pandoc.List'
local path           = require 'pandoc.path'
local DockerfileSpec = require 'pandock.DockerfileSpec'
local configutils    = require 'pandock.configutils'
local tag            = require 'pandock.tag'

local default_stack_for_image = {
  minimal = 'static',
  core    = 'alpine',
  latex   = 'alpine',
  extra   = 'alpine',
  typst   = 'alpine',
}


local BuildTarget = configutils.make_config_class{
  name = 'BuildTarget',
  valid_keys = {
    'pandoc_version',
    'stack',
    'short_tags',
    'variant',
    'version_tags'
  },
  methods = {

    dockerfile_filepath = function (self)
      return DockerfileSpec{
        pandoc_version = self.pandoc_version,
        stack = self.stack,
        addon = (self.variant ~= 'core' and self.variant ~= 'minimal')
          and self.variant
          or nil
      }:target_filepath()
    end,

    target = function (self)
      if self.variant == 'core' or self.variant == 'minimal' then
        return self.variant
      else
        return nil
      end
    end,

    tags = function (self, short_tags, extra_registries)
      local tag_format_full = 'pandoc/%s:%s-%s'
      local tag_format_short = 'pandoc/%s:%s'

      local tags = List()

      -- Generate all (repo-independent) tags
      for version in List(self.version_tags):iter() do
        tags:insert(
          tag_format_full:format(self.variant, version, self.stack)
        )
        if short_tags then
          tags:insert(
            tag_format_short:format(self.variant, version)
          )
        end
      end

      -- Add prefixes:
      for reg in List(extra_registries):iter() do
        for i = 1, #tags do
          tags:insert(reg .. '/' .. tag[i])
        end
      end

      return tags
    end
  }
}

return BuildTarget
