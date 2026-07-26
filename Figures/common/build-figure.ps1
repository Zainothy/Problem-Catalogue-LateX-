param(
  [string]$FigureDir = (Get-Location).Path,
  [switch]$Watch,
  [switch]$Clean,
  [switch]$Open,
  [switch]$NoPng
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Repair-PathForBuildTools {
  $separator = [System.IO.Path]::PathSeparator
  $cleanParts = @()

  foreach ($part in ($env:PATH -split [regex]::Escape($separator))) {
    if ([string]::IsNullOrWhiteSpace($part)) { continue }
    $trimmed = $part.Trim()
    $asPath = $trimmed.TrimEnd("\", "/")

    if (-not (Test-Path -LiteralPath $asPath)) { continue }
    $item = Get-Item -LiteralPath $asPath -ErrorAction SilentlyContinue
    if ($item -and $item.PSIsContainer) {
      $cleanParts += $trimmed
    }
  }

  $env:PATH = ($cleanParts | Select-Object -Unique) -join $separator
}

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

function Invoke-CheckedCommand {
  param(
    [string]$Command,
    [string[]]$Arguments
  )

  & $Command @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$Command failed with exit code $LASTEXITCODE"
  }
}

function Invoke-PythonGenerator {
  param([string]$Dir)

  $script = Join-Path $Dir "figure.py"
  if (-not (Test-Path -LiteralPath $script)) {
    $pythonFiles = @(Get-ChildItem -LiteralPath $Dir -Filter "*.py" -File)
    if ($pythonFiles.Count -eq 1) {
      $script = $pythonFiles[0].FullName
    } else {
      return
    }
  }

  Write-Host "Running Python generator: $script"
  if (Get-Command python -ErrorAction SilentlyContinue) {
    Invoke-CheckedCommand "python" @($script)
  } elseif (Get-Command py -ErrorAction SilentlyContinue) {
    Invoke-CheckedCommand "py" @("-3", $script)
  } else {
    throw "Python was not found on PATH."
  }
}

function Convert-FigurePdf {
  param(
    [string]$Dir,
    [switch]$SkipPng
  )

  $pdf = Join-Path $Dir "figure.pdf"
  $svg = Join-Path $Dir "figure.svg"
  $png = Join-Path $Dir "figure.png"

  if (Get-Command pdf2svg -ErrorAction SilentlyContinue) {
    Invoke-CheckedCommand "pdf2svg" @($pdf, $svg)
  } elseif (Get-Command dvisvgm -ErrorAction SilentlyContinue) {
    Invoke-CheckedCommand "dvisvgm" @("--pdf", "--no-fonts", "--exact", "--output=$svg", $pdf)
  } elseif (Get-Command inkscape -ErrorAction SilentlyContinue) {
    Invoke-CheckedCommand "inkscape" @($pdf, "--export-type=svg", "--export-filename=$svg")
  } else {
    Write-Warning "No SVG converter found. Install pdf2svg, dvisvgm, or Inkscape."
  }

  if (-not $SkipPng) {
    if ((Test-Path -LiteralPath $svg) -and (Get-Command inkscape -ErrorAction SilentlyContinue)) {
      Invoke-CheckedCommand "inkscape" @($svg, "--export-type=png", "--export-filename=$png", "--export-dpi=300")
    } elseif (Get-Command magick -ErrorAction SilentlyContinue) {
      Invoke-CheckedCommand "magick" @("-density", "300", $pdf, "-background", "white", "-alpha", "remove", $png)
    } else {
      Write-Host "PNG export skipped; install Inkscape or ImageMagick if you need PNG previews."
    }
  }
}

function Invoke-FigureBuild {
  param(
    [string]$Dir,
    [switch]$SkipPng
  )

  $buildDir = Join-Path $Dir "build"
  New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

  Invoke-PythonGenerator -Dir $Dir

  Push-Location $Dir
  try {
    $latexmkArgs = @(
      "-pdf",
      "-interaction=nonstopmode",
      "-synctex=1",
      "-file-line-error",
      "-halt-on-error",
      "-outdir=build",
      "-auxdir=build",
      "figure.tex"
    )
    Invoke-CheckedCommand "latexmk" $latexmkArgs
  } finally {
    Pop-Location
  }

  $builtPdf = Join-Path $buildDir "figure.pdf"
  if (-not (Test-Path -LiteralPath $builtPdf)) {
    throw "latexmk finished, but $builtPdf was not created."
  }

  Copy-Item -LiteralPath $builtPdf -Destination (Join-Path $Dir "figure.pdf") -Force
  Convert-FigurePdf -Dir $Dir -SkipPng:$SkipPng
  Write-Host "Built figure outputs in $Dir"
}

function Clear-FigureBuild {
  param([string]$Dir)

  $buildDir = Join-Path $Dir "build"
  if (Test-Path -LiteralPath $buildDir) {
    Remove-Item -LiteralPath $buildDir -Recurse -Force
  }

  $auxPatterns = @("*.aux", "*.log", "*.out", "*.fls", "*.fdb_latexmk", "*.synctex.gz")
  foreach ($pattern in $auxPatterns) {
    Get-ChildItem -LiteralPath $Dir -Filter $pattern -File -ErrorAction SilentlyContinue |
      Remove-Item -Force
  }
  Write-Host "Cleaned auxiliary files in $Dir"
}

function Get-WatchStamp {
  param([string]$Dir)

  $common = Join-Path (Split-Path -Parent $PSScriptRoot) "common"
  $files = @()
  $files += Get-ChildItem -LiteralPath $Dir -File -Include "*.tex", "*.py", "*.csv", "*.sty" -ErrorAction SilentlyContinue
  if (Test-Path -LiteralPath $common) {
    $files += Get-ChildItem -LiteralPath $common -File -Include "*.sty", "*.tex" -ErrorAction SilentlyContinue
  }

  if ($files.Count -eq 0) { return 0L }
  return ($files | Measure-Object -Property LastWriteTimeUtc -Maximum).Maximum.Ticks
}

$resolvedFigureDir = Get-FigureDirectory -StartPath $FigureDir
Repair-PathForBuildTools

if ($Clean) {
  Clear-FigureBuild -Dir $resolvedFigureDir
  return
}

if ($Watch) {
  Write-Host "Watching $resolvedFigureDir. Press Ctrl+C to stop."
  $lastStamp = -1L
  while ($true) {
    $stamp = Get-WatchStamp -Dir $resolvedFigureDir
    if ($stamp -ne $lastStamp) {
      $lastStamp = $stamp
      try {
        Invoke-FigureBuild -Dir $resolvedFigureDir -SkipPng:$NoPng
      } catch {
        Write-Warning $_.Exception.Message
      }
    }
    Start-Sleep -Seconds 1
  }
}

Invoke-FigureBuild -Dir $resolvedFigureDir -SkipPng:$NoPng

if ($Open) {
  & (Join-Path $PSScriptRoot "preview-figure.ps1") -FigureDir $resolvedFigureDir
}
