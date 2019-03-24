local lpeg = require 'lpeg'
if lpeg.type(lpeg.P 'Hello') ~= 'pattern' then
  io.stderr:write('[ERROR] LPEG not working as expected\n')
  os.exit(1)
end
