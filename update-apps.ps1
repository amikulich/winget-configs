# Upgrades only the packages listed in a winget export/import config (the whitelist).
# Usage: update-apps.ps1 [-ConfigPath <path>]
param(
    [string]$ConfigPath = (Join-Path $PSScriptRoot 'my-full-winget-config.json')
)

$ErrorActionPreference = 'Stop'

# winget exit codes that aren't real failures
$UPDATE_NOT_APPLICABLE = -1978335189  # 0x8A15002B: already up to date
$NO_APPLICATIONS_FOUND = -1978335212  # 0x8A150014: not installed

if (-not (Test-Path $ConfigPath)) {
    Write-Error "Config not found: $ConfigPath"
}

$config = Get-Content -Raw $ConfigPath | ConvertFrom-Json

$updated = @(); $current = @(); $missing = @(); $failed = @()

foreach ($source in $config.Sources) {
    $sourceName = $source.SourceDetails.Name
    foreach ($pkg in $source.Packages) {
        $id = $pkg.PackageIdentifier
        Write-Host "`n=== $id ===" -ForegroundColor Cyan

        winget upgrade --id $id --exact --source $sourceName `
            --accept-source-agreements --accept-package-agreements --disable-interactivity

        switch ($LASTEXITCODE) {
            0                      { $updated += $id }
            $UPDATE_NOT_APPLICABLE { $current += $id }
            $NO_APPLICATIONS_FOUND { $missing += $id }
            default                { $failed  += "$id (exit $LASTEXITCODE)" }
        }
    }
}

Write-Host "`n===== Summary =====" -ForegroundColor Cyan
Write-Host "Updated:         $($updated.Count)"   -ForegroundColor Green
$updated | ForEach-Object { Write-Host "  $_" }
Write-Host "Up to date:      $($current.Count)"
Write-Host "Not installed:   $($missing.Count)"   -ForegroundColor Yellow
$missing | ForEach-Object { Write-Host "  $_" }
Write-Host "Failed:          $($failed.Count)"    -ForegroundColor Red
$failed  | ForEach-Object { Write-Host "  $_" }

if ($failed.Count -gt 0) { exit 1 }
