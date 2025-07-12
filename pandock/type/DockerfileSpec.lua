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
local system      = require 'pandock.system'

local join = path.join

local DockerfileSpec = configutils.make_config_class{
  name = 'DockerfileSpec',
  valid_keys = {'pandoc_version', 'stack', 'addon'},
  methods = {
    source_directory = function (self)
      if self.addon then
        return join{self.stack, self.addon}
      else
        return self.stack
      end
    end,
    target_filepath = function (self)
      if self.addon then
        return join{self.pandoc_version, self.stack, self.addon, 'Dockerfile'}
      else
        return join{self.pandoc_version, self.stack, 'Dockerfile'}
      end
    end,
    template_filepath = function (self)
      return join{self:source_directory(), 'Dockerfile.tmpl'}
    end,
    get_template = function (self)
      return system.read_file(self:template_filepath())
    end
  }
}

return DockerfileSpec





