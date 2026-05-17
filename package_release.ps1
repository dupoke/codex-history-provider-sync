param(
  [string]$Version = (Get-Date -Format 'yyyyMMdd-HHmmss')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageName = "codex-history-provider-sync-$Version"
$distDir = Join-Path $root 'dist'
$stagingDir = Join-Path $distDir $packageName
$zipPath = Join-Path $distDir "$packageName.zip"

if (Test-Path -LiteralPath $stagingDir) {
  Remove-Item -LiteralPath $stagingDir -Recurse -Force
}
if (Test-Path -LiteralPath $zipPath) {
  Remove-Item -LiteralPath $zipPath -Force
}

New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

$literalFiles = @(
  'sync_backend.py',
  'launch_ui.ps1',
  'package_release.ps1',
  'LICENSE'
)

foreach ($file in $literalFiles) {
  Copy-Item -LiteralPath (Join-Path $root $file) -Destination $stagingDir -Force
}

Get-ChildItem -LiteralPath $root -File -Filter '*.cmd' |
  Copy-Item -Destination $stagingDir -Force

Get-ChildItem -LiteralPath $root -File -Filter '*.md' |
  Copy-Item -Destination $stagingDir -Force

$docsSource = Join-Path $root 'docs'
if (Test-Path -LiteralPath $docsSource) {
  Copy-Item -LiteralPath $docsSource -Destination $stagingDir -Recurse -Force
}

$testsSource = Join-Path $root 'tests'
if (Test-Path -LiteralPath $testsSource) {
  Copy-Item -LiteralPath $testsSource -Destination $stagingDir -Recurse -Force
}

Get-ChildItem -LiteralPath $stagingDir -Directory -Recurse -Filter '__pycache__' |
  Remove-Item -Recurse -Force
Get-ChildItem -LiteralPath $stagingDir -File -Recurse |
  Where-Object { $_.Extension -in @('.pyc', '.pyo') } |
  Remove-Item -Force

Compress-Archive -LiteralPath $stagingDir -DestinationPath $zipPath -Force
Write-Output "Package created: $zipPath"
