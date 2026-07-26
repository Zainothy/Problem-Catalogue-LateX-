# VSCode Notes

This workspace is tuned around your existing VSCode setup rather than replacing it.

Detected locally:

- LaTeX Workshop `10.16.1`
- `mathematic.vscode-latex`
- Python, Pylance, and debugpy
- Hypersnips plus your existing `latex.json` user snippets
- Manim Sideview
- GitLens and GitHub Actions
- MiKTeX `latexmk`, `pdflatex`, `chktex`, `lacheck`, and `dvisvgm`
- `latexindent` at `C:\latexindent\bin\windows\latexindent.exe`

Working model:

- Use LaTeX Workshop as normal for editing, PDF preview, SyncTeX, clean, linting,
  and format-on-save.
- Use the FDE task only when you need the complete publication/output pipeline:
  Python data, PDF copied beside the source, SVG exported for Obsidian.
- Templates are plain source directories. They do not carry per-template scripts.

Suggested shortcut split:

- `Ctrl+Alt+B`: LaTeX Workshop build
- `Ctrl+Alt+F`: full FDE figure build, including SVG export
- `Ctrl+Alt+C`: LaTeX Workshop clean
- `Ctrl+Alt+V`: LaTeX Workshop PDF view
- `Ctrl+Alt+Shift+V`: exported SVG/PDF preview
