-- Hacky way to test if we are in the static image, as the assertion is
-- expected to fail lpeg was compiled into pandoc.
local isstatic = os.getenv 'HOME' == '/'

if PANDOC_VERSION < '2.16.2' then
  -- don't do this test on static before 2.16.2
  if isstatic then
    os.exit(0)
  end
  lpeg = require 'lpeg'
else
  if lpeg and lpeg == require 'lpeg' then
    io.stderr:write '[NOTICE] lpeg not loaded from system lib\n'
  end
end
if lpeg.type(lpeg.P 'Hello') ~= 'pattern' then
  io.stderr:write('[ERROR] LPEG not working as expected\n')
  os.exit(1)
end
