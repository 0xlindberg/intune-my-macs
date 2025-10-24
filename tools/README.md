# Intune My Macs - Tools

This directory contains utility scripts for managing, analyzing, and documenting your macOS Intune configurations. These tools help with deployment analysis, conflict detection, documentation generation, and troubleshooting.

---

## 📋 Available Tools

### 1. Export-MacOSConfigPolicies.ps1

**Purpose:** Export macOS configuration policies from Microsoft Intune to JSON files for analysis, backup, or version control.

**What it does:**
- Lists all macOS configuration policies (both classic device configurations and Settings Catalog policies)
- Presents an indexed table of available policies
- Allows you to select and export specific policies to JSON
- Exports complete policy settings and relationships

**Usage:**

```powershell
# Interactive mode - browse and select policies to export
pwsh ./tools/Export-MacOSConfigPolicies.ps1

# List policies only (no export)
pwsh ./tools/Export-MacOSConfigPolicies.ps1 -NoPrompt

# Export specific policy by ID
pwsh ./tools/Export-MacOSConfigPolicies.ps1 -SelectId "policy-guid-here"

# Specify custom output folder
pwsh ./tools/Export-MacOSConfigPolicies.ps1 -OutputFolder ./my-exports

# Skip authentication (if already connected to Microsoft Graph)
pwsh ./tools/Export-MacOSConfigPolicies.ps1 -SkipConnect
```

**Requirements:**
- PowerShell 7+
- Microsoft.Graph PowerShell modules
- Appropriate Microsoft Graph permissions (DeviceManagementConfiguration.Read.All)

**Output:**
- JSON files in `./exports` directory (default) or custom location
- Each file contains complete policy configuration with settings

---

### 2. Find-DuplicatePayloadSettings.ps1

**Purpose:** Analyze configuration files to identify duplicate or conflicting settings across different policies.

**What it does:**
- Scans all Settings Catalog JSON files, mobileconfig plist files, and compliance policies
- Identifies settings that appear in multiple policy files
- Detects conflicts (same setting with different values)
- Highlights redundant settings (same setting with same value in multiple places)
- Provides detailed file paths and values for each conflict

**Usage:**

```powershell
# Console output with detailed conflict analysis
pwsh ./tools/Find-DuplicatePayloadSettings.ps1

# Export to CSV for Excel analysis
pwsh ./tools/Find-DuplicatePayloadSettings.ps1 -OutputFormat CSV -OutputFile duplicates.csv

# Export to JSON for programmatic processing
pwsh ./tools/Find-DuplicatePayloadSettings.ps1 -OutputFormat JSON -OutputFile duplicates.json
```

**Output Explained:**

- **Conflicts (Red ⚠️):** Same setting ID found in multiple policies with **different values** - requires immediate attention as one will override the other
- **Redundant (Yellow ℹ️):** Same setting with the same value in multiple policies - unnecessary duplication, consider consolidating

**Example Output:**
```
⚠️ CONFLICTS - Same setting with different values:
Setting: com.apple.mcx_DisableGuestAccount
  Occurrences: 2
  Found in these policies:
    • POL-SEC-004 - Guest Account Configuration
      File: configurations/intune/pol-sec-004-guest-account.json
      Value: com.apple.mcx_DisableGuestAccount_true
    • POL-SEC-006 - System Restrictions  
      File: configurations/intune/pol-sec-006-restrictions.json
      Value: com.apple.mcx_disableguestaccount_true
```

**Requirements:**
- PowerShell 7+
- No external dependencies

---

### 3. Generate-ConfigurationDocumentation.py

**Purpose:** Automatically generate comprehensive documentation from your Intune configuration files.

**What it does:**
- Parses Settings Catalog JSON files, mobileconfig plist files, compliance policies, scripts, apps, and custom attributes
- Extracts setting IDs, values, and descriptions from manifest files
- Generates professional markdown documentation with cover page, index, and detailed settings
- Converts markdown to formatted Word document (DOCX) with proper styling
- Creates 4-section document structure: Cover → Description → Index → Detailed Configurations

**Usage:**

```bash
# Generate markdown only
python3 tools/Generate-ConfigurationDocumentation.py

# Generate both markdown and DOCX using pandoc
python3 tools/Generate-ConfigurationDocumentation.py --docx --pandoc

# Generate DOCX using python-docx (no pandoc required)
python3 tools/Generate-ConfigurationDocumentation.py --docx
```

**Requirements:**
- Python 3.8+
- Optional: pandoc (for better DOCX formatting with `--pandoc` flag)
- Python packages: `python-docx` (installed automatically via venv)

**Output:**
- `INTUNE-MY-MACS-DOCUMENTATION.md` - Markdown documentation (always generated)
- `INTUNE-MY-MACS-DOCUMENTATION.docx` - Word document (when `--docx` flag used)

**Features:**
- **Cover Page:** Project title, generation date, artifact count
- **Description Page:** Project overview and artifact type breakdown
- **Index Page:** Clickable table of contents with reference IDs and setting counts
- **Detailed Sections:** Complete settings breakdown for each configuration
- **Professional Formatting:** 
  - Tables: Courier New 8pt, bold values, autofit to contents
  - Body text: Aptos 11pt
  - Headings: Aptos 14pt
  - Cover: Bold 36pt/24pt

---

### 4. Get-IntuneAgentProcessingOrder.ps1

**Purpose:** Display the order in which the Intune Management Extension (Intune Agent) will process scripts and applications on macOS devices.

**What it does:**
- Queries Microsoft Graph for assigned macOS shell scripts and macOS applications (PKG/DMG)
- Lists items in the order they will be processed by the Intune Agent
- Shows assignment status for each item
- Supports filtering by display name prefix
- Color-coded output: Scripts (yellow), Apps (green)

**Usage:**

```powershell
# Show all assigned scripts and apps in processing order
pwsh ./tools/Get-IntuneAgentProcessingOrder.ps1

# Filter by prefix (e.g., show only items starting with "SCR-")
pwsh ./tools/Get-IntuneAgentProcessingOrder.ps1 -Prefix "SCR-"

# Filter for apps only
pwsh ./tools/Get-IntuneAgentProcessingOrder.ps1 -Prefix "APP-"
```

**Example Output:**
```
Items returned: 8
 1. [Script] SCR-APP-100 - Install Company Portal (Assigned: Yes)
 2. [App] APP-UTL-001 - Swift Dialog (Assigned: Yes)
 3. [App] APP-UTL-002 - Swift Dialog Onboarding (Assigned: Yes)
 4. [Script] SCR-SYS-100 - Device Rename (Assigned: Yes)
 5. [Script] SCR-SYS-101 - Configure Dock (Assigned: Yes)
```

**Why This Matters:**
Understanding processing order helps you:
- Ensure dependencies are installed in the correct sequence
- Troubleshoot deployment timing issues
- Plan script execution that depends on previously installed apps
- Validate your deployment strategy

**Requirements:**
- PowerShell 7+
- Microsoft.Graph PowerShell modules
- Permissions: DeviceManagementScripts.Read.All, DeviceManagementApps.Read.All

---

### 5. Get-MacOSGlobalAssignments.ps1

**Purpose:** Identify all macOS Intune objects that are assigned to "All Devices" or "All Users" groups.

**What it does:**
- Scans all macOS configuration objects in your Intune tenant:
  - Settings Catalog policies
  - Classic device configurations
  - Custom configurations (mobileconfig)
  - Shell scripts
  - PKG/DMG applications
- Identifies which objects are targeted to all devices or all users
- Helps identify overly broad assignments that may impact unintended devices
- Exports results to table, JSON, or CSV

**Usage:**

```powershell
# Display table of global assignments
pwsh ./tools/Get-MacOSGlobalAssignments.ps1

# Output JSON to stdout (after table)
pwsh ./tools/Get-MacOSGlobalAssignments.ps1 -OutputJson

# Export to CSV file
pwsh ./tools/Get-MacOSGlobalAssignments.ps1 -CsvPath ./mac-global-assignments.csv

# Both JSON and CSV
pwsh ./tools/Get-MacOSGlobalAssignments.ps1 -OutputJson -CsvPath ./mac-global.csv
```

**Example Output:**
```
DisplayName                           Type                    AllDevices  AllUsers
-----------                           ----                    ----------  --------
POL-SYS-103 - Software Update         Settings Catalog        Yes         No
SCR-SYS-100 - Device Rename           Shell Script            Yes         No
APP-UTL-001 - Swift Dialog            macOS PKG App           No          Yes
```

**Why This Matters:**
Global assignments (All Devices/All Users) apply configuration or apps to every macOS device in your tenant, which can:
- Cause unintended policy conflicts
- Apply security settings too broadly
- Deploy apps to inappropriate device groups
- Create compliance issues

Use this tool to audit and refine your assignment strategy.

**Requirements:**
- PowerShell 7+
- Microsoft.Graph PowerShell modules  
- Permissions: DeviceManagementConfiguration.Read.All, DeviceManagementApps.Read.All

---

## 🔧 Setup & Prerequisites

### PowerShell Tools

All PowerShell tools require:

1. **PowerShell 7+**
   ```bash
   # macOS - Install via Homebrew
   brew install --cask powershell
   
   # Verify installation
   pwsh --version
   ```

2. **Microsoft Graph PowerShell SDK**
   ```powershell
   # Install required modules
   Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
   Install-Module Microsoft.Graph.DeviceManagement -Scope CurrentUser
   ```

3. **Authentication**
   Most tools will prompt for Microsoft Graph authentication with required scopes. Use an account with appropriate Intune permissions.

### Python Tools

The Python documentation generator requires:

1. **Python 3.8 or later**
   ```bash
   # Verify Python version
   python3 --version
   ```

2. **Virtual Environment** (recommended)
   ```bash
   # Create venv (one time)
   python3 -m venv .venv
   
   # Activate venv
   source .venv/bin/activate  # macOS/Linux
   ```

3. **Python Packages**
   ```bash
   # Install required packages
   pip install python-docx
   
   # Optional: Install pandoc for better DOCX formatting
   brew install pandoc  # macOS
   ```

---

## 📊 Common Workflows

### Workflow 1: Pre-Deployment Validation

Before deploying configurations, check for conflicts:

```powershell
# 1. Check for duplicate/conflicting settings
pwsh ./tools/Find-DuplicatePayloadSettings.ps1

# 2. Review global assignments
pwsh ./tools/Get-MacOSGlobalAssignments.ps1 -CsvPath pre-deploy-audit.csv

# 3. Generate documentation for review
python3 tools/Generate-ConfigurationDocumentation.py --docx --pandoc
```

### Workflow 2: Backup & Documentation

Create comprehensive backups and documentation:

```powershell
# 1. Export all policies from Intune
pwsh ./tools/Export-MacOSConfigPolicies.ps1 -NoPrompt

# 2. Generate current state documentation
python3 tools/Generate-ConfigurationDocumentation.py --docx --pandoc

# 3. Archive exports with timestamp
$date = Get-Date -Format "yyyy-MM-dd"
Compress-Archive -Path ./exports -DestinationPath "./backups/intune-backup-$date.zip"
```

### Workflow 3: Troubleshooting Deployment Order

When scripts or apps fail due to dependency issues:

```powershell
# Check processing order
pwsh ./tools/Get-IntuneAgentProcessingOrder.ps1

# Review specific prefix (e.g., all scripts)
pwsh ./tools/Get-IntuneAgentProcessingOrder.ps1 -Prefix "SCR-"
```

### Workflow 4: Audit & Cleanup

Identify configuration issues:

```powershell
# Find all conflicts
pwsh ./tools/Find-DuplicatePayloadSettings.ps1 -OutputFormat CSV -OutputFile conflicts.csv

# Identify overly broad assignments
pwsh ./tools/Get-MacOSGlobalAssignments.ps1 -CsvPath global-assignments.csv

# Review in Excel and plan remediation
```

---

## 🎯 Best Practices

### 1. Regular Audits
- Run `Find-DuplicatePayloadSettings.ps1` monthly to catch configuration drift
- Review `Get-MacOSGlobalAssignments.ps1` quarterly to validate assignment strategy

### 2. Documentation
- Regenerate documentation after major configuration changes
- Store DOCX in SharePoint/Teams for stakeholder review
- Include documentation in change management processes

### 3. Version Control
- Export policies before making changes using `Export-MacOSConfigPolicies.ps1`
- Commit exports to Git for historical tracking
- Use diff tools to compare policy versions

### 4. Deployment Planning
- Check `Get-IntuneAgentProcessingOrder.ps1` before deploying dependent configurations
- Ensure prerequisites (like Swift Dialog) deploy before scripts that use them
- Test processing order in pilot groups first

### 5. Conflict Resolution
When conflicts are found:
- **Priority 1:** Resolve value conflicts (different values for same setting)
- **Priority 2:** Consolidate redundant settings (same value in multiple policies)
- **Priority 3:** Document intentional overlaps with clear justification

---

## 🆘 Troubleshooting

### Issue: "Connect-MgGraph" command not found
**Solution:** Install Microsoft Graph PowerShell modules
```powershell
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
```

### Issue: Python script fails with "No module named 'docx'"
**Solution:** Install python-docx
```bash
pip install python-docx
```

### Issue: Authentication fails with insufficient permissions
**Solution:** Ensure your account has required Graph API permissions:
- DeviceManagementConfiguration.Read.All
- DeviceManagementApps.Read.All  
- DeviceManagementScripts.Read.All

### Issue: Pandoc not found when using --pandoc flag
**Solution:** Install pandoc
```bash
# macOS
brew install pandoc

# Verify installation
pandoc --version
```

### Issue: Export-MacOSConfigPolicies returns no policies
**Solution:** 
- Verify you have macOS policies in your Intune tenant
- Check your account has read permissions
- Try running without `-SkipConnect` to re-authenticate

---

## 📚 Additional Resources

- [Main Repository README](../README.md) - Overview of Intune My Macs project
- [Manifest Documentation](../manifest.md) - Policy manifest structure reference
- [Project Structure](../PROJECT_STRUCTURE.md) - Repository organization
- [Microsoft Graph API Documentation](https://learn.microsoft.com/en-us/graph/api/resources/intune-graph-overview)
- [Intune for macOS Documentation](https://learn.microsoft.com/en-us/mem/intune/configuration/device-profiles)

---

## 🤝 Contributing

Found a bug or have a feature request for these tools?
1. Check existing issues in the GitHub repository
2. Create a new issue with detailed description
3. Submit pull requests with improvements

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

**Tool Versions:**
- Export-MacOSConfigPolicies.ps1: v1.0
- Find-DuplicatePayloadSettings.ps1: v1.0.0
- Generate-ConfigurationDocumentation.py: v1.0
- Get-IntuneAgentProcessingOrder.ps1: v1.0
- Get-MacOSGlobalAssignments.ps1: v1.0

**Last Updated:** October 2025
