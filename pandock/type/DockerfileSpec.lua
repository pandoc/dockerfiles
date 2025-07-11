--- Dockerfile Specifier
--
-- Object that uniquely defines a pandoc Docker image type. This
-- includes the pandoc version, the underlying operating system, and the
-- set of extra features.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local path        = require 'pandoc.path'
local configutils = require 'pandock.configutils'

local join = path.join

local DockerfileSpec = configutils.make_config_class{
  name = 'DockerfileSpec',
  valid_keys = {'pandoc_version', 'stack', 'addon'},
  methods = {
    target_filepath = function (self)
      if self.addon then
        return join{self.pandoc_version, self.stack, self.addon, 'Dockerfile'}
      else
        return join{self.pandoc_version, self.stack, 'Dockerfile'}
      end
    end,
    template_filepath = function (self)
      if self.addon then
        return join{self.stack, self.addon, 'Dockerfile.tmpl'}
      else
        return join{self.stack, 'Dockerfile.tmpl'}
      end
    end,
  }
}

return DockerfileSpec





