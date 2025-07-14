--- Query releases, image types, etc.
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc      = require 'pandoc'
local List        = require 'pandoc.List'

local Version     = pandoc.types.Version

local list_action = {}

local function releases_to_table (releases)
  local header = {
    'version',
    'tags',
    'Alpine',
    'Ubuntu',
    'TeXLive',
    'Typst',
  }
  local rows = List{}
  for _, release in pairs(releases) do
    local row = {
      release.pandoc_version,
      table.concat(release.version_tags or {}, ' '),
      release.base_image.alpine,
      release.base_image.ubuntu,
      release.addon.latex.texlive,
      (release.addon.typst or {}).typst,
    }
    rows:insert(row)
  end
  rows:sort(function (a, b)
      if a[1] == 'main' then
        return true
      elseif b[1] == 'main' then
        return false
      end
      return Version(a[1]) > Version(b[1])
  end)
  local smpltbl = pandoc.SimpleTable(
    pandoc.Inlines{},
    List.map(header, function () return 'AlignDefault' end),
    List.map(header, function () return 0 end),
    header,
    rows
  )
  return pandoc.utils.from_simple_table(smpltbl)
end

list_action.run = function (app, args)
  local releases = app.config.release
  local things_to_list = args[1]
  if things_to_list == 'releases' then
    local doc = pandoc.Pandoc({releases_to_table(releases)})
    print(pandoc.write(doc, 'markdown'))
  else
    error("Don't know how to list " .. tostring(things_to_list))
  end
end

return list_action
