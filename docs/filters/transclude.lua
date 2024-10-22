function CodeBlock (cb)
  -- ignore code blocks which are not of class "include".
  if not cb.classes:includes 'include' then
    return nil
  end

  local blocks = pandoc.Blocks{}
  for filename in cb.text:gmatch '[^\n]+' do
    -- open file
    local fh = io.open(filename)
    blocks:extend(
      pandoc.read(fh:read 'a', 'markdown', PANDOC_READER_OPTIONS).blocks
    )
    fh:close()
  end
  return blocks
end
