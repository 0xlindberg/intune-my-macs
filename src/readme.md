## mainScript.ps1 – Intune macOS Automation

Automates importing and (optionally) assigning Intune artifacts for a macOS proof‑of‑concept environment:

Supported object types (current script version):
- Configuration Policies (deviceManagement/configurationPolicies)
- Compliance Policies (deviceCompliancePolicies)
- Shell Scripts (deviceShellScripts)
- Custom Attributes (deviceCustomAttributeShellScripts)
- macOS PKG Line‑of‑Business Apps (macOSPkgApp)
- Custom Configuration Profiles (deviceConfigurations/macOSCustomConfiguration)

Deletion (prefix based) covers: configuration policies, custom configurations, compliance policies, scripts, custom attributes, and apps.

### MDE Support
The script includes Microsoft Defender for Endpoint (MDE) content that is excluded by default. Use the `--mde` flag to include MDE-related manifests from the `mde/` folder.

---

### Prerequisites
1. PowerShell 7+ (pwsh)
2. Microsoft Graph PowerShell SDK (core authentication module installs automatically on first `Connect-MgGraph`):
	 - `Microsoft.Graph.Authentication`
	 - Beta device app management cmdlets are auto-installed on demand (module: `Microsoft.Graph.Beta.Devices.CorporateManagement`) when uploading macOS apps.
3. Intune / Graph permissions (delegated) granted at sign‑in:
	 - `DeviceManagementConfiguration.ReadWrite.All`
	 - `DeviceManagementApps.ReadWrite.All` (only required if importing apps)
	 - `DeviceManagementScripts.ReadWrite.All` (only required if importing scripts or custom attributes)
	 - `Group.Read.All` (only required if assigning to groups)

### Authentication
The script calls:
```
Connect-MgGraph -Scopes "DeviceManagementConfiguration.ReadWrite.All,DeviceManagementApps.ReadWrite.All,DeviceManagementScripts.ReadWrite.All,Group.Read.All"
```
Consent once; subsequent runs reuse the token (until expiry). If you do not import apps, scripts, or assign groups, you can safely ignore the extra scopes.

### Distributed XML Manifests
Each Intune object is described by an XML file containing a root `<MacIntuneManifest>` element with metadata. The script automatically discovers all `.xml` files recursively and processes those with valid manifest structure.

#### Script Manifest Example:
```xml
<MacIntuneManifest>
	<Type>Script</Type>
	<Name>Rename Device</Name>
	<Description>Standardize device name.</Description>
	<Platform>macOS</Platform>
	<Category>Device Setup</Category>
	<SourceFile>scripts/intune/device-rename.sh</SourceFile>
	<Script>
		<RunAsAccount>system</RunAsAccount>
		<BlockExecutionNotifications>false</BlockExecutionNotifications>
		<ExecutionFrequency>PT0H</ExecutionFrequency>
		<RetryCount>3</RetryCount>
	</Script>
</MacIntuneManifest>
```

#### Supported Manifest Types:
- **Policy**: Configuration policies referencing JSON settings files
- **Compliance**: Compliance policies with JSON configuration
- **Script**: Shell scripts with execution parameters
- **CustomAttribute**: Custom attribute scripts that report device information back to Intune (always run as system, no schedule)
- **Package**: macOS PKG apps with bundle information and optional pre/post-install scripts  
- **CustomConfig**: Custom configuration profiles (mobileconfig files)

Package manifests include a `<Package>` block with fields like `PrimaryBundleId`, `PrimaryBundleVersion`, `Publisher`, etc. Policy and compliance manifests reference JSON settings files via `<SourceFile>`.

### Naming & Prefix
All created objects are prefixed by default with:
```
[intune-my-macs] 
```
Override with `--prefix="[YourPrefix] "` (include quotes if spaces). A trailing space is auto‑added if omitted.

### Command Line Flags
| Flag | Purpose |
|------|---------|
| `--config` | Import only configuration policies |
| `--compliance` | Import only compliance policies |
| `--scripts` | Import only shell scripts |
| `--custom-attributes` | Import only custom attribute scripts |
| `--apps` | Import only macOS PKG apps |
| `--mde` | Include Microsoft Defender for Endpoint content from `mde/` folder |
| (no selector flags) | If none of the above are supplied, all types are imported |
| `--assign-group="Display Name"` | After creation, assign each created object to the specified Entra ID group |
| `--remove-all` | Delete ALL existing objects whose name starts with the current prefix (asks for `YES` confirmation) |
| `--prefix="Value "` | Set a custom prefix for creation & deletion matching |
| `--show-all-scripts` | (When selecting scripts) show additional script info output |

> Order is not important. Flags are case‑insensitive.

### Content Filtering
- Content under the `exports/` folder is automatically excluded from processing (these are output artifacts)
- MDE content under the `mde/` folder is excluded by default unless `--mde` is specified

### Typical Workflows
Import everything (default):
```bash
pwsh ./src/mainScript.ps1
```

Import ONLY policies and scripts with custom prefix:
```bash
pwsh ./src/mainScript.ps1 --config --scripts --prefix="[POC] "
```

Import apps and assign them to a group:
```bash
pwsh ./src/mainScript.ps1 --apps --assign-group="macOS POC Devices"
```

Import custom attributes only:
```bash
pwsh ./src/mainScript.ps1 --custom-attributes --assign-group="macOS Inventory Group"
```

Import with MDE content included:
```bash
pwsh ./src/mainScript.ps1 --mde --assign-group="Security Test Group"
```

Full environment rebuild (dangerous):
```bash
pwsh ./src/mainScript.ps1 --remove-all --prefix="[intune-my-macs] "
# Type YES when prompted
pwsh ./src/mainScript.ps1 --prefix="[intune-my-macs] "
```

Import compliance policies only:
```bash
pwsh ./src/mainScript.ps1 --compliance --assign-group="Secure Devices"
```

### Deletion Logic (`--remove-all`)
1. Lists all matching objects (policies, compliance policies, scripts, apps).
2. Shows a summary & requires typing `YES` (uppercase) before deletion proceeds.
3. Uses `startsWith()` server-side filtering where supported; compliance falls back to client filtering if necessary.

### Assignments
If `--assign-group` is used:
- Configuration policies are assigned via the `/assign` endpoint.
- Custom configurations (deviceConfigurations) are assigned via their `/assign` endpoint.
- Compliance policies are assigned via their `/assign` endpoint.
- Scripts are assigned via the `/assign` endpoint.
- Custom attributes are assigned via the `/assign` endpoint.
- Apps are assigned with intent `required` (only if `--apps` was specified in the current run).
- Only objects created in the current run are assigned; previous objects are unaffected.
- Group resolution uses exact display name matching via Microsoft Graph.

### macOS PKG App Upload Notes
- Utilizes Graph beta endpoints and chunked upload logic.
- Requires valid PKG path from the manifest `<SourceFile>`.
- Supports pre-install and post-install scripts (base64 encoded automatically).
- Automatically commits version and waits for publishing state.
- Default chunk size is 8MB (configurable via `ChunkSizeMB` parameter).
- Includes retry logic and proper error handling for failed uploads.

### Custom Attributes Notes
- Custom attributes are scripts that collect and report device information back to Intune.
- Always run as `system` account (cannot be changed).
- Have no execution schedule - they run when assigned and on device check-in.
- Support `string` custom attribute types (additional types may be added in future).
- Useful for inventory collection, compliance reporting, and device categorization.
- Script output is captured and stored as the custom attribute value in Intune.

### Troubleshooting
| Symptom | Hint |
|---------|------|
| 403 Forbidden | Ensure you consented to requested scopes when prompted |
| App upload hangs | Large PKG: allow processing time; monitor verbose output |
| Nothing deleted with `--remove-all` | Confirm prefix spacing matches creation prefix |
| Group not found | Display name mismatch; verify exact Entra group name |
| XML parsing errors | Verify manifest files have valid XML structure with `<MacIntuneManifest>` root |
| Missing source files | Check that file paths in manifests are relative to repository root |
| Compliance policy failures | Ensure `scheduledActionsForRule` contains at least one block action |
| Beta module installation fails | Run PowerShell as administrator or install to current user scope |

### Exit & Error Behavior
- Script sets `$ErrorActionPreference = 'Stop'` for fail-fast behavior in most blocks but wraps API calls in try/catch to continue other items.
- Individual failures are logged; the script proceeds with remaining objects.

### Debug Mode
Set the environment variable `IMM_DEBUG=1` to enable detailed debugging output:
```bash
$env:IMM_DEBUG='1'; pwsh ./src/mainScript.ps1
```
This provides additional information about XML parsing, element detection, and manifest processing.

### Validation
The script includes built-in validation for all manifest types:
- Checks for required fields per object type
- Validates file paths and references
- Provides summary counts by type
- Reports missing files with warnings

### Extending
Potential future additions (not yet in this version):
- Enrollment restrictions
- Dry-run mode (`--what-if` style)
- Structured JSON summary output
- Additional log level controls

### Minimal Quick Start
```bash
git clone https://github.com/microsoft/intune-my-macs.git
cd intune-my-macs
pwsh ./src/mainScript.ps1 --scripts --config --assign-group="Your Group"
```

### Disclaimer
This script manipulates production Intune objects. Test in a lab tenant before applying to production.

---
Maintained by the Intune Customer Experience Engineering team.
