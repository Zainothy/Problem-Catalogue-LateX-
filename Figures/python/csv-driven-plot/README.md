# CSV-Driven Plot

This is the minimal Python integration pattern:

1. Edit `figure.py` for the computation.
2. Edit `figure.tex` for the visual treatment.
3. Run the VSCode task `Figure: Build PDF+SVG for current figure`.

The builder runs `figure.py` automatically before LaTeX.
