if PANDOC_VERSION < '2.16.2' then
  local lpeg = require 'lpeg'
else
  -- Hacky way to test if we are in the static image, as the assertion is
  -- expected to fail lpeg was compiled into pandoc.
  if os.getenv('HOME') ~= '/' then
    assert(lpeg and lpeg == require 'lpeg', 'lpeg not loaded from system lib')
  end
end
if lpeg.type(lpeg.P 'Hello') ~= 'pattern' then
  io.stderr:write('[ERROR] LPEG not working as expected\n')
  os.exit(1)
end
