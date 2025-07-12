--- Build target
--
-- Object that uniquely defines a docker build target.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local List           = require 'pandoc.List'
local DockerfileSpec = require 'pandock.type.DockerfileSpec'
local configutils    = require 'pandock.configutils'

local BuildTarget = configutils.make_config_class{
  name = 'BuildTarget',
  valid_keys = {
    'pandoc-version',
    'stack',
    'variant',
    'version-tags'
  },
  methods = {
    to_dockerfile_spec = function (self)
      return DockerfileSpec{
        pandoc_version = self.pandoc_version,
        stack = self.stack,
        addon = self.variant:is_addon()
          and self.variant.name
          or nil
      }
    end,

    dockerfile_filepath = function (self)
      return self:to_dockerfile_spec():target_filepath()
    end,

    target = function (self)
      return not self.variant:is_addon()
        and self.variant.name
        or nil
    end,

    tags = function (self, extra_registries)
      extra_registries = extra_registries or List{'ghcr.io'}
      local tag_format_full = 'pandoc/%s:%s-%s'
      local tag_format_short = 'pandoc/%s:%s'

      local tags = List()
      local short_tags = self.stack == self.variant['default-stack']

      -- Generate all (repo-independent) tags
      for version in List(self.version_tags):iter() do
        tags:insert(
          tag_format_full:format(self.variant.name, version, self.stack)
        )
        if short_tags then
          tags:insert(
            tag_format_short:format(self.variant.name, version)
          )
        end
      end

      -- Add prefixes:
      for reg in List(extra_registries or {}):iter() do
        tags:extend(tags:map(function (tag) return reg .. '/' .. tag end))
      end

      return tags
    end,

    title = function (self)
      return self.variant.title
        or error('no title for ' .. self.variant.name)
    end,

    labels = function (self)
      local authors = 'Albert Krewinkel <albert+pandoc@tarleb.com>'
      local url = 'https://github.com/pandoc/dockerfiles'
      return {
        ['org.opencontainers.image.authors']     = authors,
        ['org.opencontainers.image.description'] = self.variant.description,
        ['org.opencontainers.image.licenses']    = 'GPL-2.0-or-later',
        ['org.opencontainers.image.source']      = url,
        ['org.opencontainers.image.title']       = self:title(),
        ['org.opencontainers.image.url']         = url,
        ['org.opencontainers.image.vendor']      = 'The pandoc Docker team',
        ['org.opencontainers.image.version']     = self.pandoc_version,
      }
    end,
  }
}

--- Generate all build targets for the given release
BuildTarget.targets_for_release = function (release, variants)
  local targets = List()
  for variant in variants:iter() do
    local base_images = List(pairs(release.base_image))
    -- sort to get a fixed, reproducible order
    base_images:sort()
    local supports_variant = function (base_image)
      return base_image ~= 'static' or not variant:is_addon()
    end
    targets:extend(
      base_images:filter(supports_variant):map(
        function (stack)
          return BuildTarget.new {
            pandoc_version = release.pandoc_version,
            stack = stack,
            variant = variant,
            version_tags = release.version_tags,
          }
        end
      )
    )
  end
  return targets
end

return BuildTarget
