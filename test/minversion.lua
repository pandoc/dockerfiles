local stringify = pandoc.utils.stringify
function Pandoc (doc)
  if PANDOC_VERSION < stringify(doc.meta['minversion']) then
    os.exit(1)
  end
end
