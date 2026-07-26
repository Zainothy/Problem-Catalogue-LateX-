param(
  [string]$FigureDir = (Get-Location).Path,
  [string]$SourceSvg,
  [string]$OutputName = "figure.svg"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-FigureDirectory {
  param([string]$StartPath)

  $candidate = Resolve-Path -LiteralPath $StartPath
  $item = Get-Item -LiteralPath $candidate
  if (-not $item.PSIsContainer) {
    $candidate = Split-Path -Parent $item.FullName
  } else {
    $candidate = $item.FullName
  }

  while ($candidate -and (Test-Path -LiteralPath $candidate)) {
    if ((Test-Path -LiteralPath (Join-Path $candidate "figure.tex")) -or
        (Test-Path -LiteralPath (Join-Path $candidate "figure.ggb"))) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
    $parent = Split-Path -Parent $candidate
    if ($parent -eq $candidate) { break }
    $candidate = $parent
  }

  return (Resolve-Path -LiteralPath $StartPath).Path
}

$dir = Get-FigureDirectory -StartPath $FigureDir

if (-not $SourceSvg) {
  $downloads = Join-Path $HOME "Downloads"
  $latest = Get-ChildItem -LiteralPath $downloads -Filter "*.svg" -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if (-not $latest) {
    throw "No SVG export found in $downloads. Pass -SourceSvg explicitly."
  }
  $SourceSvg = $latest.FullName
}

$destination = Join-Path $dir $OutputName
Copy-Item -LiteralPath $SourceSvg -Destination $destination -Force
Write-Host "Copied GeoGebra SVG to $destination"
