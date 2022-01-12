local function tag_strings (row)
  return row[2][1].content
end
function CodeBlock (cb)
  if not cb.classes:includes 'supported-tags' then
    return nil
  end

  -- get simple table from file
  local fh = io.open 'versions.md'
  local versions = pandoc.utils.to_simple_table(
    pandoc.read(fh:read 'a').blocks[1]
  )

  local result = pandoc.List()
  for i, row in ipairs(versions.rows) do
    local tags = tag_strings(row)
    result:insert{pandoc.Plain(tags)}
  end
  return pandoc.BulletList(result)
end
