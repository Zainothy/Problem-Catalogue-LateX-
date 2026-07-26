param(
  [string]$FigureDir = (Get-Location).Path
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
    if (Test-Path -LiteralPath (Join-Path $candidate "figure.tex")) {
      return (Resolve-Path -LiteralPath $candidate).Path
    }
    $parent = Split-Path -Parent $candidate
    if ($parent -eq $candidate) { break }
    $candidate = $parent
  }

  throw "Could not find figure.tex at or above: $StartPath"
}

$dir = Get-FigureDirectory -StartPath $FigureDir
$svg = Join-Path $dir "figure.svg"
$pdf = Join-Path $dir "figure.pdf"

if (Test-Path -LiteralPath $svg) {
  $target = $svg
} elseif (Test-Path -LiteralPath $pdf) {
  $target = $pdf
} else {
  throw "No figure.svg or figure.pdf exists yet. Build the figure first."
}

if (Get-Command code -ErrorAction SilentlyContinue) {
  & code -r $target
} else {
  Invoke-Item -LiteralPath $target
}
