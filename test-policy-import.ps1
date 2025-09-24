#Requires -Modules Microsoft.Graph.Authentication

<#
.SYNOPSIS
Alternative policy import tester using direct Graph API calls

.DESCRIPTION
Tests importing a single Settings Catalog policy using Invoke-MgGraphRequest for better error visibility

.PARAMETER PolicyPath
Path to the JSON policy file

.PARAMETER Platform
Target platform (macOS, windows10, iOS, etc.)

.EXAMPLE
.\test-policy-import-alt.ps1 -PolicyPath "test-policies/fulldisk.json" -Platform "macOS"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PolicyPath,
    
    [Parameter(Mandatory = $false)]
    [string]$Platform = "macOS"
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Magenta = "`e[35m"
$Cyan = "`e[36m"
$Reset = "`e[0m"

Write-Host "${Cyan}🔬 Alternative Policy Import Tester (Direct Graph API)${Reset}" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Gray
Write-Host

try {
    # Check if file exists
    if (-not (Test-Path $PolicyPath)) {
        throw "Policy file not found: $PolicyPath"
    }

    Write-Host "${Yellow}📁 Policy File:${Reset} $PolicyPath" -ForegroundColor Yellow
    Write-Host "${Yellow}🖥️  Platform:${Reset} $Platform" -ForegroundColor Yellow
    Write-Host

    # Read and parse JSON
    Write-Host "${Blue}📖 Reading policy file...${Reset}" -ForegroundColor Blue
    $policyContent = Get-Content -Path $PolicyPath -Raw
    $policy = $policyContent | ConvertFrom-Json
    
    Write-Host "${Green}✅ JSON parsed successfully${Reset}" -ForegroundColor Green
    Write-Host "${Blue}📋 Policy Name:${Reset} $($policy.name)" -ForegroundColor Blue
    Write-Host "${Blue}📋 Description:${Reset} $($policy.description)" -ForegroundColor Blue
    Write-Host "${Blue}📋 Settings Count:${Reset} $($policy.settingCount)" -ForegroundColor Blue
    Write-Host

    # Check Graph connection
    Write-Host "${Blue}🔐 Checking Microsoft Graph connection...${Reset}" -ForegroundColor Blue
    try {
        $context = Get-MgContext
        if ($null -eq $context) {
            Write-Host "${Yellow}⚠️  Not connected to Microsoft Graph. Attempting to connect...${Reset}" -ForegroundColor Yellow
            Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All" -NoWelcome
        } else {
            Write-Host "${Green}✅ Connected to Microsoft Graph${Reset}" -ForegroundColor Green
            Write-Host "${Blue}   Account:${Reset} $($context.Account)" -ForegroundColor Blue
            Write-Host "${Blue}   Tenant:${Reset} $($context.TenantId)" -ForegroundColor Blue
        }
    } catch {
        throw "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
    }
    Write-Host

    # Prepare policy for import
    Write-Host "${Blue}🚀 Preparing policy for import...${Reset}" -ForegroundColor Blue
    
    # Clean up policy object for import (remove read-only properties)
    $importPolicy = @{
        name = $policy.name
        description = $policy.description
        platforms = $Platform
        technologies = $policy.technologies
        settings = $policy.settings
    }

    # Add template reference if it exists and is not empty
    if ($policy.templateReference -and $policy.templateReference.templateId) {
        $importPolicy.templateReference = $policy.templateReference
    }

    Write-Host "${Green}✅ Policy prepared for import${Reset}" -ForegroundColor Green
    Write-Host

    # Show the JSON that will be sent
    Write-Host "${Yellow}📤 Request Body (JSON):${Reset}" -ForegroundColor Yellow
    $jsonBody = $importPolicy | ConvertTo-Json -Depth 20 -Compress:$false
    Write-Host $jsonBody -ForegroundColor Gray
    Write-Host

    # Attempt import using direct Graph API call
    Write-Host "${Magenta}🔄 Attempting import via direct Graph API call...${Reset}" -ForegroundColor Magenta
    Write-Host "POST https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -ForegroundColor Gray
    Write-Host

    $result = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies" -Body $jsonBody -ContentType "application/json"

    Write-Host "${Green}🎉 SUCCESS! Policy imported successfully${Reset}" -ForegroundColor Green
    Write-Host "${Blue}📋 Policy ID:${Reset} $($result.id)" -ForegroundColor Blue
    Write-Host "${Blue}📋 Policy Name:${Reset} $($result.name)" -ForegroundColor Blue
    Write-Host "${Blue}📋 Created:${Reset} $($result.createdDateTime)" -ForegroundColor Blue
    Write-Host

} catch {
    Write-Host "${Red}❌ ERROR: Policy import failed${Reset}" -ForegroundColor Red
    Write-Host "${Red}═══════════════════════════════${Reset}" -ForegroundColor Red
    Write-Host
    
    $errorMessage = $_.Exception.Message
    $errorResponse = $_.Exception.Response
    
    Write-Host "${Yellow}📝 Error Message:${Reset}" -ForegroundColor Yellow
    Write-Host $errorMessage -ForegroundColor Red
    Write-Host

    # Try to get response content for Graph API errors
    if ($errorResponse) {
        Write-Host "${Yellow}🌐 HTTP Status:${Reset} $($errorResponse.StatusCode) - $($errorResponse.ReasonPhrase)" -ForegroundColor Yellow
        
        try {
            if ($errorResponse.Content) {
                $responseContent = $errorResponse.Content.ReadAsStringAsync().Result
                if ($responseContent) {
                    Write-Host "${Yellow}📋 Response Content:${Reset}" -ForegroundColor Yellow
                    
                    try {
                        $errorJson = $responseContent | ConvertFrom-Json
                        Write-Host "Error Code: $($errorJson.error.code)" -ForegroundColor Red
                        Write-Host "Error Message: $($errorJson.error.message)" -ForegroundColor Red
                        
                        if ($errorJson.error.details) {
                            Write-Host "Error Details:" -ForegroundColor Red
                            $errorJson.error.details | ForEach-Object {
                                Write-Host "  - $($_.message)" -ForegroundColor Red
                            }
                        }
                    } catch {
                        Write-Host $responseContent -ForegroundColor Red
                    }
                }
            }
        } catch {
            Write-Host "Could not read response content: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }

    Write-Host
    Write-Host "${Yellow}💡 Troubleshooting Tips:${Reset}" -ForegroundColor Yellow
    Write-Host "   • Verify all setting definition IDs exist in Settings Catalog" -ForegroundColor White
    Write-Host "   • Check that the platform '$Platform' is correct" -ForegroundColor White
    Write-Host "   • Ensure all required dependent settings are included" -ForegroundColor White
    Write-Host "   • Validate JSON structure matches Graph API expectations" -ForegroundColor White
    
    exit 1
}

Write-Host "${Cyan}🏁 Test completed successfully${Reset}" -ForegroundColor Cyan