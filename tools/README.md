# Intune My Macs - Tools

This directory contains utility scripts for managing, analyzing, and documenting your macOS Intune configurations. These tools help with deployment analysis, conflict detection, documentation generation, and troubleshooting.

---

## 📋 Available Tools

### Summary

| Tool                                   | Type       | Summary                                                   |
|----------------------------------------|------------|-----------------------------------------------------------|
| `Export-MacOSConfigPolicies.ps1`       | PowerShell | Export macOS Intune policies to JSON                      |
| `Find-DuplicatePayloadSettings.ps1`    | PowerShell | Find duplicate/conflicting settings across payload files  |
| `Generate-ConfigurationDocumentation.py` | Python   | Generate Markdown/DOCX documentation from manifests       |
| `Get-IntuneAgentProcessingOrder.ps1`   | PowerShell | Show script/app processing order for Intune Agent         |
| `Get-MacOSGlobalAssignments.ps1`       | PowerShell | List macOS objects assigned to All Devices/All Users      |

---

### `Export-MacOSConfigPolicies.ps1`

- **Purpose:** Export macOS configuration policies from Intune to JSON for backup/analysis.
- **Dependencies:** PowerShell 7+, Microsoft.Graph modules, `DeviceManagementConfiguration.Read.All`.
- **Key options:**
   - `-NoPrompt` – list policies only.
   - `-SelectId "<guid>"` – export a specific policy.
   - `-OutputFolder "<path>"` – change export path.
   - `-SkipConnect` – reuse existing Graph connection.
- **Examples:**
   ```powershell
   pwsh ./tools/Export-MacOSConfigPolicies.ps1 -NoPrompt
   pwsh ./tools/Export-MacOSConfigPolicies.ps1 -SelectId "<policy-guid>" -OutputFolder ./exports
   ```

---

### `Find-DuplicatePayloadSettings.ps1`

- **Purpose:** Detect duplicate or conflicting settings across JSON, mobileconfig, and compliance files.
- **Dependencies:** PowerShell 7+ (no additional modules).
- **Key options:**
   - `-OutputFormat CSV|JSON` – choose export format.
   - `-OutputFile "<file>"` – path for the exported report.
- **Examples:**
   ```powershell
   pwsh ./tools/Find-DuplicatePayloadSettings.ps1
   pwsh ./tools/Find-DuplicatePayloadSettings.ps1 -OutputFormat CSV -OutputFile duplicates.csv
   ```

---

### `Generate-ConfigurationDocumentation.py`

- **Purpose:** Generate Markdown and optional DOCX documentation from Intune manifests.
- **Dependencies:** Python 3.8+
- **Key options:**
   - `--docx` – also create a DOCX file. Requires `python-docx`:
     ```bash
     pip install python-docx
     ```
   - `--pandoc` – use pandoc pipeline for DOCX formatting. Requires the `pandoc` binary, for example on macOS:
     ```bash
     brew install pandoc
     ```
- **Examples:**
   ```bash
   python3 tools/Generate-ConfigurationDocumentation.py
   python3 tools/Generate-ConfigurationDocumentation.py --docx --pandoc
   ```

---

### `Get-IntuneAgentProcessingOrder.ps1`

- **Purpose:** Show the order in which the Intune Management Extension processes scripts and apps.
- **Dependencies:** PowerShell 7+, Microsoft.Graph modules, `DeviceManagementScripts.Read.All`, `DeviceManagementApps.Read.All`.
- **Key options:**
   - `-Prefix "SCR-"` – filter by display name prefix.
- **Examples:**
   ```powershell
   pwsh ./tools/Get-IntuneAgentProcessingOrder.ps1
   pwsh ./tools/Get-IntuneAgentProcessingOrder.ps1 -Prefix "SCR-"
   ```

---

### `Get-MacOSGlobalAssignments.ps1`

- **Purpose:** Find macOS policies, scripts, and apps targeted to All Devices/All Users.
- **Dependencies:** PowerShell 7+, Microsoft.Graph modules, `DeviceManagementConfiguration.Read.All`, `DeviceManagementApps.Read.All`.
- **Key options:**
   - `-OutputJson` – emit JSON after the table.
   - `-CsvPath "<file>"` – export results to CSV.
- **Examples:**
   ```powershell
   pwsh ./tools/Get-MacOSGlobalAssignments.ps1
   pwsh ./tools/Get-MacOSGlobalAssignments.ps1 -OutputJson -CsvPath ./mac-global-assignments.csv
   ```

---


## 🆘 Troubleshooting

### Issue: "Connect-MgGraph" command not found
**Solution:** Install Microsoft Graph PowerShell modules
```powershell
Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force
```

### Issue: Authentication fails with insufficient permissions
**Solution:** Ensure your account has required Graph API permissions:
- DeviceManagementConfiguration.Read.All
- DeviceManagementApps.Read.All  
- DeviceManagementScripts.Read.All


---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---


**Last Updated:** October 2025
