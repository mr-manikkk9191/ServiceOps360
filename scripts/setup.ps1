<#
 One-command setup for Windows PowerShell.
 Usage:  .\scripts\setup.ps1 -DevHub PropertyManagementOrg
#>
param(
    [string]$DevHub = "PropertyManagementOrg",
    [string]$Alias  = "ServiceOps360-Dev",
    [int]$Days      = 30
)
function Run($cmd) {
    Write-Host ">> $cmd" -ForegroundColor Cyan
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: $cmd" -ForegroundColor Red; exit 1 }
}
Run "sf org create scratch --definition-file config/project-scratch-def.json --alias $Alias --duration-days $Days --set-default --target-dev-hub $DevHub --wait 10"
Run "sf project deploy start --source-dir force-app --target-org $Alias --wait 30"
Run "sf org assign permset --name ServiceOps_Admin --target-org $Alias"
Run "sf apex run --file scripts/apex/seed-data.apex --target-org $Alias"
Run "sf apex run --file scripts/apex/schedule-jobs.apex --target-org $Alias"
Write-Host "Done. Opening org..." -ForegroundColor Green
Run "sf org open --target-org $Alias"
