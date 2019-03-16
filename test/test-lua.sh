#!/bin/sh

# Install LPEG
apk --no-cache add lua5.3-lpeg

# Load and use LPEG, a system-installed C-based Lua module.
cat > /tmp/lpeg-test.lua <<EOF
local lpeg = require 'lpeg'
if lpeg.type(lpeg.P 'Hello') ~= 'pattern' then
  io.stderr:write('[ERROR] LPEG not working as expected\n')
  os.exit(1)
end
EOF

echo 'hi' | pandoc --lua-filter=/tmp/lpeg-test.lua -t json -o /dev/null
