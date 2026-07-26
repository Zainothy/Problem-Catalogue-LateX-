# GeoGebra Manual Export Example

Keep the `.ggb` construction in this directory.

Recommended workflow:

1. Open the `.ggb` file in GeoGebra.
2. Use `File > Export > Graphics View as SVG`.
3. Save to Downloads, or directly to this directory.
4. In VSCode, run the task `GeoGebra: Copy latest exported SVG here`.

The task copies the newest SVG from Downloads to `figure.svg`, ready for:

```markdown
![[Figures/geogebra/manual-export-example/figure.svg]]
```

For LaTeX:

```tex
\includesvg{Figures/geogebra/manual-export-example/figure}
```
