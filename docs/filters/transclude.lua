function CodeBlock (cb)
  -- ignore code blocks which are not of class "include".
  if not cb.classes:includes 'include' then
    return nil
  end

  -- open file
  local fh = io.open(cb.text:match '[^\n]+')

  return pandoc.read(fh:read 'a', FORMAT, PANDOC_READER_OPTIONS).blocks
end
