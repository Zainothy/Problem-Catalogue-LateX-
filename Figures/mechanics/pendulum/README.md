# Pendulum

This is a complete Python-driven figure:

1. `figure.py` writes `pendulum.csv`.
2. `figure.tex` imports the CSV with PGFPlots.
3. The VSCode task `Figure: Build PDF+SVG for current figure` produces
   `figure.pdf`, `figure.svg`, and optionally `figure.png`.

Build it from the repository root with:

```powershell
.\Figures\common\build-figure.ps1 -FigureDir .\Figures\mechanics\pendulum
```

Embed the result in Obsidian:

```markdown
![[Figures/mechanics/pendulum/figure.svg]]
```
