if PANDOC_VERSION < '2.16.2' then
  local lpeg = require 'lpeg'
else
  assert(lpeg and lpeg == require 'lpeg', 'lpeg not loaded from system lib')
end
if lpeg.type(lpeg.P 'Hello') ~= 'pattern' then
  io.stderr:write('[ERROR] LPEG not working as expected\n')
  os.exit(1)
end
