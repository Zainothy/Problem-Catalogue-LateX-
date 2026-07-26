# GeoGebra

Use this category for figures whose source of truth is a `.ggb` construction.

Keep each construction in its own directory. Export an SVG from GeoGebra and run the
VSCode task `GeoGebra: Copy latest exported SVG here`, or call:

```powershell
..\common\copy-geogebra-export.ps1 -FigureDir .\my-construction -SourceSvg C:\path\export.svg
```
