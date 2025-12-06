--- Handle options and parameters for Core images
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local function addon_context (core, release)
  local crossref_version = release.addon.core['pandoc-crossref']
  return {
    ['pandoc-crossref'] = {
      version = crossref_version,
      hashes = core.hashes['pandoc-crossref'][crossref_version],
    }
  }
end

return {
  addon_context = addon_context,
}
