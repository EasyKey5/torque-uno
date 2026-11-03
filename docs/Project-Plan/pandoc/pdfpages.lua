-- Pandoc filter: a paragraph holding only a link to a PDF (e.g. [[file:./form.pdf]])
-- is replaced by an image of every page of that PDF, since Word can't show PDFs.
-- Pages are rasterised with Ghostscript (gs) and embedded straight into the .docx.

local DPI = 200
local PAGE_HEIGHT = '21cm' -- A4 page fits under a heading within 2.54cm margins

local input_dir = PANDOC_STATE.input_files[1]
  and pandoc.path.directory(PANDOC_STATE.input_files[1]) or '.'

local function pdf_pages(pdf)
  local images = {}
  pandoc.system.with_temporary_directory('pdfpages', function(tmp)
    pandoc.pipe('gs', {
      '-q', '-dNOPAUSE', '-dBATCH', '-dSAFER', '-sDEVICE=png16m', '-r' .. DPI,
      '-dTextAlphaBits=4', '-dGraphicsAlphaBits=4',
      '-sOutputFile=' .. pandoc.path.join({ tmp, 'page-%03d.png' }), pdf,
    }, '')
    local files = pandoc.system.list_directory(tmp)
    table.sort(files)
    local stem = pandoc.path.split_extension(pandoc.path.filename(pdf))
    for i, f in ipairs(files) do
      local fh = assert(io.open(pandoc.path.join({ tmp, f }), 'rb'))
      local name = stem .. '-' .. i .. '.png'
      pandoc.mediabag.insert(name, 'image/png', fh:read('a'))
      fh:close()
      images[#images + 1] = pandoc.Para({ pandoc.Image({}, name, '', { height = PAGE_HEIGHT }) })
    end
  end)
  return images
end

function Para(p)
  if #p.content ~= 1 or p.content[1].t ~= 'Link' then return nil end
  local target = p.content[1].target:gsub('^file:', '')
  if not target:lower():match('%.pdf$') then return nil end
  if not pandoc.path.is_absolute(target) then
    target = pandoc.path.normalize(pandoc.path.join({ input_dir, target }))
  end
  return pdf_pages(target)
end
