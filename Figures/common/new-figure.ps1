param(
  [string]$Name,
  [string]$Category = "mechanics",
  [string]$Template = "standalone-tikz"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$figuresRoot = Split-Path -Parent $PSScriptRoot
$templateDir = Join-Path $figuresRoot "templates\$Template"

if (-not $Name) {
  $Name = Read-Host "Figure name, for example pendulum-small-angle"
}

if (-not (Test-Path -LiteralPath $templateDir)) {
  throw "Unknown template '$Template'. See Figures/templates."
}

$categoryDir = Join-Path $figuresRoot $Category
$targetDir = Join-Path $categoryDir $Name

if (Test-Path -LiteralPath $targetDir) {
  throw "Figure already exists: $targetDir"
}

New-Item -ItemType Directory -Force -Path $categoryDir | Out-Null
Copy-Item -LiteralPath $templateDir -Destination $targetDir -Recurse

Get-ChildItem -LiteralPath $targetDir -Recurse -Directory -Filter "build" -ErrorAction SilentlyContinue |
  Remove-Item -Recurse -Force
Get-ChildItem -LiteralPath $targetDir -File -Include "figure.pdf", "figure.svg", "figure.png" -ErrorAction SilentlyContinue |
  Remove-Item -Force

Write-Host "Created $targetDir from template '$Template'."
Write-Host "Edit figure.tex, then run the VSCode task: Figure: Build PDF+SVG for current figure"
