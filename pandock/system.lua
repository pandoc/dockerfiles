--- Compatibility layer for older pandoc.system versions
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local io       = require 'io'
local pandoc   = require 'pandoc'
local system   = require 'pandoc.system'

local M = {}

for key, value in pairs(system) do
  M[key] = value
end

--- Returns the contents of a file.
M.read_file = system.read_file or function (filepath)
  local fh = io.open(filepath, 'rb')
  if fh then
    local content = fh:read('a')
    fh:close()
    return content
  else
    error('Could not open filepath ' .. filepath .. ' for reading.')
  end
end

--- Returns the contents of a file.
M.write_file = system.write_file or function (filepath, contents)
  local fh = io.open(filepath, 'wb')
  if fh then
    fh:write(contents)
    fh:close()
  else
    error('Could not open filepath ' .. filepath .. ' for writing.')
  end
end

--- Copies a file.
M.copy = system.copy or function (src, tgt)
  return pandoc.pipe('cp', {src, tgt}, '')
end

return M
