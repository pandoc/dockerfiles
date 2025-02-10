--- short-description.lua: get the short description for a repository
--- Author: Albert Krewinkel <albert+pandoc@tarleb.com>
--- License: MIT

local io     = require 'io'
local pandoc = require 'pandoc'

local stringify = pandoc.utils.stringify

--- Command-line arguments
local arg = arg

--- The image type / repository name
local repo = assert(arg[1], "Repository name is required")
local inputfile = arg[2] or 'docs/short-descriptions.md'
local fh = io.open(inputfile, 'r')
local contents = fh:read('a')
fh:close()

local doc = pandoc.read(contents)

assert(doc.meta[repo], "No description found for repository " .. repo)

print(stringify(doc.meta[repo]))
