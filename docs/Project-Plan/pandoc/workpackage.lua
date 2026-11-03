-- Pandoc filter: a #+begin_workpackage block holding a description list
--   - WP Title :: ...
--   - Objectives :: ...   (may span several lines, paragraphs and nested lists)
-- becomes the department's "WORK PACKAGE DESCRIPTION" table.
-- Labels are matched case-insensitively; any that are missing are left blank.
-- Borders come from the "WorkPackage" table style in reference.docx.

local SHORT = { 'Start Event', 'Duration' }
local LONG = { 'Objectives', 'Task Description', 'Inputs',
  'Interfaces/links with other tasks or WPs', 'Deliverables' }
-- column widths from the template: label | title | "WP number" | number
local WIDTHS = { 0.161, 0.534, 0.189, 0.116 }

local function key(s)
  return pandoc.utils.stringify(s):lower():gsub('[%s:]+$', '')
end

local function cell(blocks, span, align)
  return pandoc.Cell(blocks, align or 'AlignDefault', 1, span or 1)
end

local function label(text)
  return { pandoc.Plain({ pandoc.Strong({ pandoc.Str(text .. ':') }) }) }
end

local function value(blocks)
  if blocks == nil or #blocks == 0 then return { pandoc.Plain({}) } end
  return blocks
end

function Div(div)
  if not div.classes:includes('workpackage') then return nil end

  local fields = {}
  for _, b in ipairs(div.content) do
    if b.t == 'DefinitionList' then
      for _, item in ipairs(b.content) do
        local blocks = {}
        for _, def in ipairs(item[2]) do
          for _, blk in ipairs(def) do blocks[#blocks + 1] = blk end
        end
        fields[key(item[1])] = blocks
      end
    end
  end

  local rows = {
    pandoc.Row({ cell({ pandoc.Plain({ pandoc.Strong({ pandoc.Str('WORK PACKAGE DESCRIPTION') }) }) },
      4, 'AlignCenter') }),
    pandoc.Row({
      cell(label('WP Title')), cell(value(fields['wp title'])),
      cell(label('WP number')), cell(value(fields['wp number'])),
    }),
  }
  for _, name in ipairs(SHORT) do
    rows[#rows + 1] = pandoc.Row({ cell(label(name)), cell(value(fields[name:lower()]), 3) })
  end
  for _, name in ipairs(LONG) do
    local blocks = label(name)
    for _, blk in ipairs(fields[name:lower()] or {}) do blocks[#blocks + 1] = blk end
    -- an empty section still gets a blank line to write in
    if #blocks == 1 then blocks[2] = pandoc.Para({ pandoc.Str('\u{00A0}') }) end
    rows[#rows + 1] = pandoc.Row({ cell(blocks, 4) })
  end

  local colspecs = {}
  for i, w in ipairs(WIDTHS) do colspecs[i] = { 'AlignDefault', w } end
  return pandoc.Table({ long = {} }, colspecs, pandoc.TableHead(),
    { { attr = {}, body = rows, head = {}, row_head_columns = 0 } },
    pandoc.TableFoot(), { ['custom-style'] = 'WorkPackage' })
end
