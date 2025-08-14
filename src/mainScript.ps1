# Requires: PowerShell 7+
$ErrorActionPreference = 'Stop'

# Install Microsoft.Graph.Authentication module if not found
if (-not (Get-Module -Name Microsoft.Graph.Authentication -ErrorAction SilentlyContinue)) {
    Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser -Force -AllowClobber
}

# Choose what to run
$importPolicies = $true
$importPackages = $false
$importScripts = $true

# set policy prefix
$policyPrefix = "[CK-import] "

# connect to Graph
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All" -NoWelcome

<#
# Resolve repo root (script is in src/, manifest is at repo root)
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
$repoRoot = (Resolve-Path (Join-Path $scriptDir '..')).Path
$manifestPath = Join-Path $repoRoot 'manifest.json'
#>

# set repo directory
$repoRoot = "C:\Users\ckunze\OneDrive - Microsoft\Documents\Intune-my-macs\intune-my-macs"

# set manifest path
$manifestPath = Join-Path $repoRoot 'manifest.json'

if (-not (Test-Path -LiteralPath $manifestPath)) {
    Write-Error "manifest.json not found at: $manifestPath"
    exit 1
}

# Load manifest
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

# Header
if ($manifest.metadata) {
    Write-Host "Manifest: $($manifest.metadata.title) v$($manifest.metadata.version) ($($manifest.metadata.lastUpdated))" -ForegroundColor Cyan
}

# Enumerate policies
if ($importPolicies) {
    $policies = @()
    if ($manifest.policies) {
        $policies = $manifest.policies | Where-Object { $_.type -eq 'Policy' }
    }

    Write-Host "Found $($policies.Count) policies:`n" -ForegroundColor Cyan

    foreach ($p in $policies) {
        $policyPath = Join-Path $repoRoot $p.filePath
        $exists = Test-Path -LiteralPath $policyPath
        $status = if ($exists) { 'OK' } else { 'MISSING' }

        $desc = $p.description
        if ($null -ne $desc -and $desc.Length -gt 140) { $desc = $desc.Substring(0, 137) + '...' }

        Write-Host "• $($p.name)" -ForegroundColor Yellow
        Write-Host "  - Category: $($p.category); Platform: $($p.platform); Settings: $($p.settingCount)"
        Write-Host "  - Path: $($p.filePath) [$status]"
        if ($desc) { Write-Host "  - Desc: $desc" }

        # import policy into Intune
        try {
            $policyContentJson = Get-Content -LiteralPath $policyPath -Raw
            $policyContent = ConvertFrom-Json -InputObject $policyContentJson -Depth 20
            $policyContent.name = $policyPrefix + $policyContent.name
            $policyContentJson = ConvertTo-Json -InputObject $policyContent -Depth 20

            # create policy with json content
            $policyImportResults = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Body $policyContentJson
            if ($policyImportResults) {
                Write-Host "  - Policy $($policyImportResults.name)imported successfully with ID: $($policyImportResults.id)" -ForegroundColor Green
            } else {
                Write-Host "  - Policy import failed or returned no results." -ForegroundColor Red
            }

        } catch {
            Write-Error "Failed to process policy '$($p.name)': $_"
        }
        Write-Host ""

    }
}

# Enumerate packages/apps
if ($importPackages) {
    $packages = @()
    if ($manifest.policies) {
        $packages = $manifest.policies | Where-Object { $_.type -in @('Package','App') }
    }

    Write-Host "Found $($packages.Count) packages/apps:`n" -ForegroundColor Cyan

    foreach ($a in $packages) {
        $assetPath = Join-Path $repoRoot $a.filePath
        $exists = Test-Path -LiteralPath $assetPath
        $status = if ($exists) { 'OK' } else { 'MISSING' }

        $desc = $a.description
        if ($null -ne $desc -and $desc.Length -gt 140) { $desc = $desc.Substring(0, 137) + '...' }

        Write-Host "• $($a.name)" -ForegroundColor Yellow
        Write-Host "  - Category: $($a.category); Platform: $($a.platform)"
        Write-Host "  - Path: $($a.filePath) [$status]"
        if ($desc) { Write-Host "  - Desc: $desc" }
        Write-Host ""
    }
}


# Enumerate scripts
if ($importScripts) {
    $scripts = @()
    if ($manifest.policies) {
        $scripts = $manifest.policies | Where-Object { $_.type -eq 'Script' }
    }

    Write-Host "Found $($scripts.Count) scripts:`n" -ForegroundColor Cyan

    foreach ($s in $scripts) {
        $scriptPath = Join-Path $repoRoot $s.filePath
        $exists = Test-Path -LiteralPath $scriptPath
        $status = if ($exists) { 'OK' } else { 'MISSING' }

        $desc = $s.description
        if ($null -ne $desc -and $desc.Length -gt 140) { $desc = $desc.Substring(0, 137) + '...' }

        Write-Host "• $($s.name)" -ForegroundColor Yellow
        Write-Host "  - Platform: $($s.platform); RequiresElevation: $($s.requiresElevation)"
        Write-Host "  - Intune: RunAsSignedInUser=$($s.runAsSignedInUser); HideNotifications=$($s.hideNotifications); Frequency='$($s.frequency)'; MaxRetries=$($s.maxRetries)"
        Write-Host "  - Path: $($s.filePath) [$status]"
        
        try {
            if ($desc) { Write-Host "  - Desc: $desc" }
            # Read the script content
            $ScriptContent = Get-Content -Path $s.filePath -Raw
            $EncodedScript = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ScriptContent))
            $scriptJson = @{
                displayName = $policyPrefix + $s.name
                description = $s.description
                scriptContent = $EncodedScript
                runAsAccount = $s.runAsAccount
                fileName = [System.IO.Path]::GetFileName($s.filePath)
                roleScopeTagIds = @("0")
                blockExecutionNotifications = $s.blockExecutionNotifications
                retryCount = $s.retryCount
                executionFrequency = $s.executionFrequency
            } | ConvertTo-Json -Depth 20

            $scriptImportResults = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceShellScripts" -Body $scriptJson

            Write-Host "  - Script '$($scriptImportResults.displayName)' imported successfully." -ForegroundColor Green
        } catch {
            Write-Error "Failed to import script '$($s.name)': $_"
        }

        Write-Host ""
    }
}