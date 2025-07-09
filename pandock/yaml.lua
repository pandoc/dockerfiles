--- YAML parsing helpers
--
-- Copyright  : © 2025 Albert Krewinkel <albert+pandoc@tarleb.com>
-- License    : MIT

local pandoc   = require 'pandoc'
local utils    = require 'pandoc.utils'
local system   = require 'pandock.system'

--- Remove Inlines and Blocks from a meta tree.
local function stringify_meta (tree)
  local ty = pandoc.utils.type(tree)
  if ty == 'table' or ty == 'Meta' or ty == 'List' then
    local new = setmetatable({}, getmetatable(tree))
    for key, value in pairs(tree) do
      new[key] = stringify_meta(value)
    end
    return new
  elseif ty == 'string' or ty == 'boolean' then
    return tree
  elseif ty == 'Inlines' or ty == 'Blocks' then
    return utils.stringify(tree)
  else
    error('stringify_meta does not know how to handle ' .. ty)
  end
end

--- A kind of YAML parser built on pandoc's Markdown reader.
--
-- This is not a true YAML parser, as it will interpret some characters as
-- Markdown. However, it should be good enough for the time being.
local function parse_yaml (yaml_string)
  -- ensure that the YAML string starts and ends with the proper delimiters.
  yaml_string = yaml_string:find('^\n*%-%-%-\n')
    and yaml_string
    or string.format('---\n%s\n...\n', yaml_string)

  local meta = utils.type(yaml_string) == 'Meta'
    and yaml_string
    or pandoc.read(tostring(yaml_string), 'commonmark_x').meta
  return setmetatable(stringify_meta(meta), nil)
end

local function parse_yaml_file (filepath)
  return parse_yaml(system.read_file(filepath))
end

return {
  stringify_meta = stringify_meta,
  parse = parse_yaml,
  parse_file = parse_yaml_file,
}
