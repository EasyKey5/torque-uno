-- Pandoc filter for Project-Plan.org -> .docx
--  * builds the departmental cover page from the #+ keywords at the top of the org file
--  * "-----" (horizontal rule) becomes a page break
--  * "#+TOC:" becomes a Word table of contents (right-click > Update Field in Word)

local fields = {}
local script_dir = PANDOC_SCRIPT_FILE:match('(.*[/\\])') or './'

local function xml_escape(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'))
end

local function para(text, size, opts)
  opts = opts or {}
  local rpr = '<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="' .. size .. '"/>'
  if opts.underline then rpr = rpr .. '<w:u w:val="single"/>' end
  return pandoc.RawBlock('openxml',
    '<w:p><w:pPr><w:jc w:val="center"/><w:spacing w:after="240"/></w:pPr>'
    .. '<w:r><w:rPr>' .. rpr .. '</w:rPr><w:t xml:space="preserve">'
    .. xml_escape(text) .. '</w:t></w:r></w:p>')
end

local function blank(n)
  local b = {}
  for _ = 1, n do b[#b + 1] = pandoc.RawBlock('openxml', '<w:p/>') end
  return b
end

local function field(key, placeholder)
  local v = fields[key]
  if v == nil or v == '' then return placeholder end
  return v
end

local page_break = pandoc.RawBlock('openxml', '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')

local toc = pandoc.RawBlock('openxml',
  '<w:sdt><w:sdtPr><w:docPartObj><w:docPartGallery w:val="Table of Contents"/><w:docPartUnique/></w:docPartObj></w:sdtPr>'
  .. '<w:sdtContent><w:p><w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>'
  .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "1-3" \\h \\z \\u </w:instrText></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
  .. '<w:r><w:t>Right-click and choose Update Field to build the table of contents.</w:t></w:r>'
  .. '<w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:sdtContent></w:sdt>')

function Pandoc(doc)
  local meta = doc.meta
  fields.title = meta.title and pandoc.utils.stringify(meta.title) or nil
  fields.author = meta.author and pandoc.utils.stringify(meta.author) or nil

  local body = {}
  for _, b in ipairs(doc.blocks) do
    if b.t == 'RawBlock' and b.format == 'org' then
      local k, v = b.text:match('^#%+([%w_]+):%s*(.-)%s*$')
      if k and k:lower() == 'toc' then
        body[#body + 1] = toc
      elseif k then
        fields[k:lower()] = v
      end
    elseif b.t == 'HorizontalRule' then
      body[#body + 1] = page_break
    else
      body[#body + 1] = b
    end
  end

  local logo = pandoc.Para({ pandoc.Image({}, script_dir .. 'logo.emf', '', { width = '9cm' }) })
  local cover = {
    pandoc.Div({ logo }, { ['custom-style'] = 'Cover' }),
    para('DEPARTMENT OF ELECTRICAL ENGINEERING & ELECTRONICS', 24),
  }
  for _, b in ipairs(blank(3)) do cover[#cover + 1] = b end
  cover[#cover + 1] = para('Project Plan for project \u{2018}' .. field('title', '…..name of project ….') .. '\u{2019}', 40)
  cover[#cover + 1] = para('Author: ' .. field('author', '…your name…') .. ' (' .. field('student_id', '…your student ID…') .. ')', 36)
  cover[#cover + 1] = para('Project Supervisor: ' .. field('supervisor', '…name of supervisor…'), 36)
  cover[#cover + 1] = para('Project Assessor: ' .. field('assessor', '…name of assessor…'), 36)
  for _, b in ipairs(blank(2)) do cover[#cover + 1] = b end

  for i = #cover, 1, -1 do table.insert(body, 1, cover[i]) end

  -- cover page replaces pandoc's default title block
  meta.title, meta.author, meta.date = nil, nil, nil
  return pandoc.Pandoc(body, meta)
end
