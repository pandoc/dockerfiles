--- Handle options and parameters for Typst images
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local function addon_context (typst, release)
  local version = release.addon.typst.typst
  return {
    version = version,
    hashes = typst.hashes[version],
  }
end

return {
  addon_context = addon_context,
}
