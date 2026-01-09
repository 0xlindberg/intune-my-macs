# 🛡️ Microsoft Defender for Endpoint (MDE)

This folder adds optional Microsoft Defender for Endpoint (MDE) artifacts on top of the core `intune-my-macs` deployment.

> To use `--mde`, you must provide your own onboarding payload and a matching XML manifest.

---

## 1. What you need before `--mde`

`mainScript.ps1` will only deploy MDE content when you pass the `--mde` switch **and** both of the following exist in this folder:

1. **Onboarding payload** – Your tenant-specific `.mobileconfig` file.
2. **Matching XML manifest** – An XML manifest that points to that `.mobileconfig` file.

Only after these are in place should you run:

```bash
pwsh ./mainScript.ps1 --assign-group "<your group>" --mde
```

General prerequisites (PowerShell, APNS, permissions) are documented in the root `README.md`. This file focuses on MDE specifics only.

---

## 2. Get your onboarding payload

1. Sign in to the [Microsoft Defender Portal](https://security.microsoft.com).
2. Go to **system** > **Settings** > **Endpoints** > **Device management** > **Onboarding**.
3. Select **Operating system**: **macOS**.
4. Select **Deployment method**: **Mobile Device Management / Microsoft Intune**.
5. Download the onboarding package.

You will get a file called `GatewayWindowsDefenderATPOnboardingPackage.zip` extract the archive and in the Intune folder rename the file `WindowsDefenderATPOnboarding.xml` to '`cfg-mde-001-onboarding.mobileconfig`.

Copy `cfg-mde-001-onboarding.mobileconfig` into the `mde` folder of this project

The onboarding file must be named exactly `cfg-mde-001-onboarding.mobileconfig`.

> Security note: do not commit your onboarding file into a public fork of this repo.

---

## 3. Create the onboarding manifest

Create `mde/cfg-mde-001-onboarding.xml` with the following content. The `<SourceFile>` value must match your onboarding payload name and path.

```xml
<MacIntuneManifest>
  <ReferenceId>CFG-MDE-001</ReferenceId>
  <Version>1.0</Version>
  <Type>CustomConfig</Type>
  <Name>CFG-MDE-001 - Microsoft Defender Onboarding Profile</Name>
  <Description>Onboards Microsoft Defender for Endpoint using a macOS custom configuration (mobileconfig) profile.</Description>
  <Platform>macOS</Platform>
  <Category>Security</Category>
  <SourceFile>mde/cfg-mde-001-onboarding.mobileconfig</SourceFile>
</MacIntuneManifest>
```

At this point you should have:

- `mde/cfg-mde-001-onboarding.mobileconfig` – your tenant-specific onboarding payload.
- `mde/cfg-mde-001-onboarding.xml` – the manifest above.

---

## 4. Run the toolkit with MDE

With the onboarding payload and manifest in place, you can include MDE in a run:

```bash
pwsh ./mainScript.ps1 --assign-group "<your group>" --mde
```

The `--mde` switch tells `mainScript.ps1` to:

- Import the onboarding custom configuration (`CFG-MDE-001`).
- Import the MDE settings catalog policy (`POL-MDE-001`).
- Import and assign the MDE install script (`SCR-MDE-100`).

The script handles ordering automatically (install app, onboard, then apply settings).

---

## 5. What lives in `mde/`

- `cfg-mde-001-onboarding.mobileconfig` – **Required** onboarding payload (supplied by you; not committed here).
- `cfg-mde-001-onboarding.xml` – Manifest for the onboarding profile (see template above).
- `pol-mde-001-settings-catalog.json` / `.xml` – Settings catalog policy for MDE.
- `scr-mde-100-install-defender.zsh` / `.xml` – Script and manifest to install the Defender agent.

For general MDE concepts (licensing, OS requirements, tuning, CLI), use Microsoft documentation:

- [Deploy MDE for macOS with Intune](https://learn.microsoft.com/microsoft-365/security/defender-endpoint/mac-install-with-intune)
- [Microsoft Defender for Endpoint on macOS](https://learn.microsoft.com/microsoft-365/security/defender-endpoint/microsoft-defender-endpoint-mac)

---

## 6. Common MDE-specific issues

- **Onboarding file not found**  
  - Confirm the file is named `cfg-mde-001-onboarding.mobileconfig`.  
  - Confirm it is in the `mde/` folder.  
  - Confirm the `<SourceFile>` in `cfg-mde-001-onboarding.xml` matches exactly.  
  - Confirm you ran `mainScript.ps1` with `--mde`.

- **Device not appearing in Defender**  
  - Verify the onboarding profile was created and assigned in Intune.  
  - On the Mac, run `sudo mdatp health` to check status.  
  - Allow time for initial onboarding and portal reporting.

For broader troubleshooting and best practices, refer to the MDE docs linked above.

---

Built with ❤️ by the **Microsoft Intune Customer Experience Engineering team**
