Project-Plan.docx: Project-Plan.org references.bib pandoc/cover.lua pandoc/pdfpages.lua pandoc/workpackage.lua pandoc/reference.docx pandoc/logo.emf $(wildcard *.pdf)
	pandoc $< -f org -o $@ \
	  -d ieee \
	  --reference-doc=pandoc/reference.docx \
	  --lua-filter=pandoc/pdfpages.lua \
	  --lua-filter=pandoc/workpackage.lua \
	  --lua-filter=pandoc/cover.lua \
	  --shift-heading-level-by=1
