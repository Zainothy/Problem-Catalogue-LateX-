# Figure Development Environment

This folder is a source-driven figure workspace for mathematical and physics figures.

```text
source files
  -> one build command
  -> figure.pdf, figure.svg, optional figure.png
  -> same asset works in Obsidian and LaTeX
```

The normal editing target is `figure.tex`. If a figure is generated from Python, edit
`figure.py` as well. Generated outputs stay beside the source so Obsidian can embed
them directly.

## One-Minute Figure

From VSCode:

1. Open `Figure-Development.code-workspace`.
2. Run the task `Figure: New from template`.
3. Enter a name such as `central-force`.
4. Edit the new `figure.tex`.
5. Save for LaTeX Workshop PDF preview, or run `Figure: Build PDF+SVG for current figure`.
6. Embed `figure.svg` in Obsidian or include it in LaTeX.

From PowerShell:

```powershell
.\Figures\common\new-figure.ps1 -Category mechanics -Name central-force -Template vector-diagram
.\Figures\common\build-figure.ps1 -FigureDir .\Figures\mechanics\central-force
```

## Folder Layout

```text
Figures/
  common/       shared LaTeX style and PowerShell automation
  templates/    copy-ready figure starting points
  mechanics/    physics and mechanics figures
  geometry/     Euclidean and analytic geometry figures
  topology/     topology figures
  graphs/       graph theory and discrete maths figures
  python/       Python-generated data or figures
  geogebra/     GeoGebra constructions and exported SVGs
```

Every figure should live in its own directory:

```text
mechanics/
  pendulum/
    figure.tex
    figure.py
    pendulum.csv
    figure.pdf
    figure.svg
    figure.png
    README.md
```

## Build Pipeline

The shared builder is `common/build-figure.ps1`.

For TikZ and PGFPlots:

```text
figure.tex
  -> latexmk
  -> build/figure.pdf
  -> figure.pdf
  -> figure.svg
  -> figure.png when Inkscape or ImageMagick is available
```

If `figure.py` exists, the builder runs it before LaTeX. If `figure.py` does not exist
but exactly one `.py` file exists, that file is run instead.

Useful commands inside any figure directory:

```powershell
..\..\common\build-figure.ps1 -FigureDir .
..\..\common\build-figure.ps1 -FigureDir . -Clean
..\..\common\build-figure.ps1 -FigureDir . -Open
```

## VSCode Workflow

The workspace defines these tasks:

- `Figure: Build PDF+SVG for current figure`
- `Figure: Clean current figure`
- `Figure: Open SVG/PDF preview`
- `Figure: New from template`
- `GeoGebra: Copy latest exported SVG here`

Your existing LaTeX Workshop setup remains the normal authoring path:

- save `figure.tex` to build the PDF preview
- use LaTeX Workshop's built-in build, clean, view, and SyncTeX commands
- run the FDE build task only when you want the Obsidian/LaTeX-ready `figure.svg`
  and root-level `figure.pdf` refreshed

VSCode stores keyboard shortcuts in user settings rather than in a portable workspace
file. Copy `.vscode/keybindings.sample.json` into your VSCode Keyboard Shortcuts JSON
if you want:

- `Ctrl+Alt+B`: LaTeX Workshop build
- `Ctrl+Alt+F`: full FDE build for the current figure
- `Ctrl+Alt+C`: LaTeX Workshop clean
- `Ctrl+Alt+V`: LaTeX Workshop PDF view
- `Ctrl+Alt+Shift+V`: open the exported SVG/PDF

LaTeX Workshop is configured to build into `build/`, use SyncTeX, lint with ChkTeX,
and format with `latexindent`.

## Obsidian

Put this repository, or at least `Figures/`, inside your Obsidian vault or symlink it
into the vault. The embedded file should be the SVG:

```markdown
![[Figures/mechanics/pendulum/figure.svg]]
```

Do not duplicate source into Obsidian. Obsidian consumes only the built SVG.

## LaTeX

For SVG inclusion, add this to the main document preamble:

```tex
\usepackage{svg}
```

Then include the same output:

```tex
\includesvg[width=0.8\linewidth]{Figures/mechanics/pendulum/figure}
```

If your build environment does not support `svg` shell escape cleanly, use the PDF:

```tex
\includegraphics[width=0.8\linewidth]{Figures/mechanics/pendulum/figure.pdf}
```

## GeoGebra

GeoGebra desktop export is reliable interactively, but command-line SVG export is not
consistent enough to make it the default automation path on Windows.

Recommended manual workflow:

1. Keep the `.ggb` source inside a figure directory.
2. Export from GeoGebra with `File > Export > Graphics View as SVG`.
3. Save to Downloads or directly to the figure directory.
4. Run `GeoGebra: Copy latest exported SVG here`.

That task copies the newest SVG in Downloads to `figure.svg` in the current figure
directory. If you saved somewhere else:

```powershell
.\Figures\common\copy-geogebra-export.ps1 -FigureDir .\Figures\geogebra\my-construction -SourceSvg C:\path\export.svg
```

## Git Policy

Track:

- `figure.tex`
- `figure.py`
- data files needed to rebuild, such as `.csv`
- final `figure.svg`, `figure.pdf`, and useful `figure.png`
- `README.md`

Ignore:

- `build/`
- LaTeX auxiliary files

This keeps outputs available to Obsidian and LaTeX while keeping noisy intermediates
out of Git.

## Main Document Hub

The current repository can stay as the hub:

- `document.tex` remains the book or journal source.
- `Figures/` becomes the canonical asset source.
- `Images/` can remain for screenshots or older bitmap-only assets.
- GitHub Pages can continue publishing only `document.tex`/`document.pdf` until you
choose to expand the workflow.

A later cleanup pass could move the main LaTeX source into `tex/document.tex`, but do
that only after resolving the current changes in `document.tex` and updating the
GitHub Actions workflow.

## Tooling Notes

Good additions for this workflow:

- Inkscape: best fallback converter and PNG exporter.
- `pdf2svg`: simple and fast PDF-to-SVG conversion.
- ChkTeX: lightweight LaTeX linting.
- `latexindent`: automatic formatting.
- `ltex-ls` through the LTEX extension: label and prose spell checking.
- TikZ/PGF manual: <https://tikz.dev/> is the most useful reference while authoring.
- LaTeX Workshop: <https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop>
  is still the best VSCode integration point for this setup.
- Tectonic: <https://tectonic-typesetting.github.io/> is promising for reproducible
  TeX builds, though `latexmk` remains the more compatible default for TikZ,
  PGFPlots, SyncTeX, MiKTeX, and converter-heavy figure pipelines.
- Typst and CeTZ: <https://typst.app/docs/guides/for-latex-users/> and
  <https://typst.app/universe/package/cetz/> are worth watching. Typst's own
  LaTeX-user guide still notes that the LaTeX PGF/TikZ plotting ecosystem is
  broader, so this FDE keeps LaTeX as the source of truth.
