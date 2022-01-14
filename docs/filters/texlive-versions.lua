function CodeBlock (cb)
  if not cb.classes:includes 'texlive-versions' then
    return nil
  end

  -- get simple table from file
  local fh = io.open 'versions.md'
  local versions = pandoc.utils.to_simple_table(
    -- make things more presentable by adding commas
    pandoc.read(fh:read 'a').blocks[1]:walk{
      Space = function (_) return {pandoc.Str ',', pandoc.Space()} end
    }
  )
  -- remove alpine and ubuntu columns
  for _, k in ipairs{'aligns', 'widths', 'headers'} do
    versions[k]:remove(4) -- ubuntu
    versions[k]:remove(3) -- alpine
  end
  for _, row in ipairs(versions.rows) do
    row:remove(4) -- ubuntu
    row:remove(3) -- alpine
  end

  return pandoc.utils.from_simple_table(versions)
end
