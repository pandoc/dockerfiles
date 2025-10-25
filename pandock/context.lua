--- Generate the template context for an image
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc = require 'pandoc'
local Version = pandoc.types.Version

--- Template context module
local M = {}

--- Stringify a template context by turning it into YAML.
M.to_string = function (context)
  local opts = {
    template = '$titleblock$'
  }
  return pandoc.write(pandoc.Pandoc({}, context), 'commonmark_x', opts)
end

--- Create the template context
M.create_context = function (spec, release, addon)
  local context = {
    pandoc_version = spec.pandoc_version
  }

  -- Only the main image needs cabal info
  if not addon then
    local cabal = require 'pandock.cabal'
    context.cabal = cabal.get_cabal_options(spec)
    context.base_image_version = release.base_image[spec.stack]
    context.pandoc_commit = release.pandoc_commit
    -- The package `gmp-static` is new in Alpine 3.22
    context['needs-gmp-static'] = spec.stack == 'static'
      and Version(context.base_image_version) >= Version('3.22')
    -- Whether to compile on Ubuntu, or just use the binaries from Debian
    -- Starting with pandoc 3.8.*, pandoc-crossref became difficult to
    -- compile on Ubuntu, so the binaries are copied from Debian instead.
    local ok, pdv = pcall(Version, release.pandoc_commit)
    context.ubuntu = { compile = ok and pdv < '3.8' }
  else
    context[spec.addon] = addon
    local addon_module_name = 'pandock.addon.' .. tostring(spec.addon)
    local ok, addon_module = pcall(require, addon_module_name)
    if ok and addon_module then
      local addon_context = addon_module.addon_context(addon, release)
      for key, value in pairs(addon_context) do
        context[spec.addon][key] = value
      end
    end
  end
  return context
end

return M
