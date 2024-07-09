--- Project Gutenberg License:
--- This ebook is for the use of anyone anywhere in the United States and most other parts of the world at no cost and with almost no restrictions whatsoever.
--- You may copy it, give it away or re-use it under the terms of the Project Gutenberg License included with this ebook or online at www.gutenberg.org.
--- If you are not located in the United States, you will have to check the laws of the country where you are located before using this eBook.
--- Release date: April 1, 2004 [eBook #10681]
--- Most recently updated: January 26, 2021
---
local license_text = [[
# Project Gutenberg License:
This eBook is for the use of anyone anywhere in the United States and most other parts of the world at no cost and with almost no restrictions whatsoever.
You may copy it, give it away or re-use it under the terms of the Project Gutenberg License included with this eBook or online at www.gutenberg.org.
If you are not located in the United States, you will have to check the laws of the country where you are located before using this eBook.
]]

local cmp = require("cmp")
if not cmp then return end

local source = {}
source.new = function()
  return setmetatable({}, { __index = source })
end

source.get_trigger_characters = function()
  return { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k',
           'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
           'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
           'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
           'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' }
end

source.is_available = function()
  return vim.api.nvim_get_mode().mode == 'i'
end

local function is_win()
  return package.config:sub(1, 1) == '\\'
end

local function get_path_separator()
  if is_win() then
    return '\\'
  end
  return '/'
end


local function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  if is_win() then
    str = str:gsub('/', '\\')
  end
  return str:match('(.*' .. get_path_separator() .. ')')
end

-- Create key-value parts for the thesaurus based on the concept number
local key_value_parts = {}
local rogets_thesaurus = {}
local script_path = script_path()

function table.reverse(tab)
    for i = 1, math.floor(#tab/2), 1 do
        tab[i], tab[#tab-i+1] = tab[#tab-i+1], tab[i]
    end
    return tab
end

-- see if the file exists
function io.file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function io.lines_from(file)
  if not io.file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

source.complete = function(self, request, callback)
  local line = vim.fn.getline('.')
  local original_start = vim.fn.col('.') - 1
  local start = original_start
  while start > 0 and string.match(line:sub(start, start), '%S') do
      start = start - 1
  end
  local query_word = line:sub(start + 1, vim.fn.col('.') - 1)
  if #query_word < 3 then return end  --- Short input requires a lot of processing, so let's skip it.

  local cleaned_query_word = query_word:gsub('%(',''):gsub('%)',''):gsub('%[',''):gsub('%]','')
  if not vim.fn.filereadable(script_path..'words/'..cleaned_query_word) then return end

  local items = {}
  local seen_items = {}


  local word_path = script_path..'words/'..cleaned_query_word
  if is_win() then
    word_path = word_path:gsub('/', '\\')
  end
  local lines = io.lines_from(word_path)
  if not lines then return end
  for _, entry in pairs(lines) do
    local parts = vim.split(entry, '\t', true) -- True to trim results
    local concept = parts[1]
    local concept_number = parts[2]
    if seen_items[concept_number] == nil then
      local synonyms_formatted =  string.gsub(parts[3], cleaned_query_word, '**'..cleaned_query_word..'**')
      local initial_doc = '**' .. concept .. '**' .. ' ' .. concept_number .. ': ' .. synonyms_formatted
      local concept_path = script_path..'concepts/'..concept_number:gsub('#',''):gsub('%.','')
      if is_win() then
        concept_path = concept_path:gsub('/', '\\')
      end
      local related_concepts = io.lines_from(concept_path)
      local _related_concepts = '\n• '..table.concat(related_concepts, '\n• ')
      local header = '# Roget\'s Thesaurus:\n--------------------\n'
      table.insert(items, {
        label = cleaned_query_word .. ' (' .. concept .. ' '..concept_number..')',
        documentation = '```markdown\n' .. header .. initial_doc.. '\n\n**See also**: ' .. _related_concepts .. '\n\n' .. license_text .. '\n```',
        textEdit = {
          newText = query_word,
          filterText = query_word,
          range = {
            ['start'] = {
              line = request.context.cursor.row - 1,
                character = original_start,
            },
            ['end'] = {
                line = request.context.cursor.row - 1,
                character = request.context.cursor.col - 1,
            }
          },
        },
      })
    seen_items[concept_number] = true
    end
  end
  callback({items = items, isIncomplete = false})
end

return source
