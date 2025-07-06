--- Simple logger
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local io       = require 'io'

local make_logger_function = function (min_verbosity)
  return function (self, ...)
    if self.verbosity >= min_verbosity then
      self:write(...)
    end
  end
end

--- A simple logger.
local Logger = {
  verbosity = 0,
  file = io.stderr,
}

Logger.__index = Logger

--- Log a debug message.
Logger.debug = make_logger_function(3)

--- Log an info message.
Logger.info  = make_logger_function(2)

--- Log a warning message.
Logger.warn  = make_logger_function(1)

--- Write log entry.
Logger.write = function (self, message, ...)
  self.file:write(tostring(message):format(...))
  self.file:write('\n')
end

--- Create a new logger
Logger.__call = function (self, verbosity)
  return setmetatable(
    {verbosity = (verbosity or self.verbosity)},
    self
  )
end

return setmetatable(Logger, Logger)
