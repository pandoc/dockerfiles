--- Fixes the examples on how to run this image by replacing
-- `pandoc/latex` with the correct name.

-- This is a bit of a hack, as we get the repo name from the input file.
local repo = 'pandoc/' .. pandoc.path.split_extension(
  pandoc.path.filename(PANDOC_STATE.input_files[1])
)

function CodeBlock (cb)
  cb.text = cb.text:gsub('pandoc/latex', repo)
  return cb
end

function Code (code)
  code.text = code.text:gsub('pandoc/latex', repo)
  return code
end
