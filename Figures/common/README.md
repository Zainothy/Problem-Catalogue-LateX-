# Common

Shared implementation for the Figure Development Environment.

- `fde.sty`: shared TikZ, PGFPlots, and colour styles.
- `build-figure.ps1`: the one VSCode task helper that runs Python if present,
  builds `figure.tex`, and exports SVG/PDF outputs.
- `preview-figure.ps1`: opens `figure.svg` or `figure.pdf`.
- `new-figure.ps1`: copies a template into a category.
- `copy-geogebra-export.ps1`: copies an exported GeoGebra SVG into a figure directory.
- `latexmkrc`: default latexmk configuration for manual use.
