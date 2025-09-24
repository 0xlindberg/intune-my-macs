# Intune macOS Policy Deployment Script (PowerShell)
# This script removes all existing policies and redeploys them with group assignment

[CmdletBinding()]
param()

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

Write-Host "🚀 Intune macOS Policy Deployment Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host

# Get the script directory to ensure we're in the right location
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "📍 Working directory: $(Get-Location)" -ForegroundColor Yellow
Write-Host

try {
    # Step 1: Remove all existing policies
    Write-Host "🗑️  STEP 1: Removing all existing Intune policies..." -ForegroundColor Magenta
    Write-Host "---------------------------------------------------" -ForegroundColor Gray
    
    & pwsh ./src/mainScript.ps1 --remove-all
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ All existing policies successfully removed" -ForegroundColor Green
    } else {
        throw "Error removing existing policies (Exit Code: $LASTEXITCODE)"
    }

    Write-Host
    Write-Host "⏳ Waiting 10 seconds before redeployment..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Write-Host

    # Step 2: Deploy all policies with group assignment
    Write-Host "🚀 STEP 2: Deploying policies with group assignment..." -ForegroundColor Magenta
    Write-Host "-----------------------------------------------------" -ForegroundColor Gray
    
    & pwsh ./src/mainScript.ps1 --assign-group="intune-my-mac" --mde
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host
        Write-Host "🎉 DEPLOYMENT COMPLETE!" -ForegroundColor Green
        Write-Host "=======================" -ForegroundColor Green
        Write-Host "✅ All policies have been successfully deployed" -ForegroundColor Green
        Write-Host "🎯 Group Assignment: intune-my-mac" -ForegroundColor Cyan
        Write-Host "🛡️  MDE Integration: Enabled" -ForegroundColor Cyan
        Write-Host
        Write-Host "📋 Next Steps:" -ForegroundColor Yellow
        Write-Host "  1. Verify policies in Microsoft Intune admin center" -ForegroundColor White
        Write-Host "  2. Check group assignments are correct" -ForegroundColor White
        Write-Host "  3. Monitor device compliance and policy application" -ForegroundColor White
    } else {
        throw "Error during policy deployment (Exit Code: $LASTEXITCODE)"
    }
}
catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
