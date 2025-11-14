# Intune My Macs

## Configuration Documentation

**Generated:** November 14, 2025

**Total Artifacts:** 30

```{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
```

# About Intune My Macs

**Intune My Macs** is a production-ready configuration repository for Microsoft Intune-based macOS device management. This project provides enterprise-grade policies, configuration profiles, scripts, and packages to secure, configure, and manage macOS devices in enterprise environments.

## What's Included

This repository contains the following artifact types:

- **Settings Catalog Policies** - Modern declarative configuration policies
- **Custom Configuration Profiles** - Traditional mobileconfig profiles
- **Compliance Policies** - Device compliance requirements
- **Shell Scripts** - Automated configuration and remediation scripts
- **Application Packages** - macOS application installers
- **Custom Attributes** - Device inventory attributes

## About This Documentation

This document catalogs all configuration artifacts with complete settings details. Use the Index to quickly locate specific configurations, then refer to the detailed sections for complete settings breakdowns.

```{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
```

# Index

Click any reference ID to jump to detailed configuration.

| Ref | Type | Settings Count |
|-----|------|----------------|
| [app-utl-001-swift-dialog](#app-utl-001-swift-dialog-package) | Package | 5 |
| [app-utl-002-dialog-onboarding](#app-utl-002-dialog-onboarding-package) | Package | 7 |
| [cat-sys-100-compatibility-checker](#cat-sys-100-compatibility-checker-customattribute) | CustomAttribute | 1 |
| [cfg-idp-001-platform-sso](#cfg-idp-001-platform-sso-policy) | Policy | 18 |
| [cfg-sec-001-login-window](#cfg-sec-001-login-window-customconfig) | CustomConfig | 4 |
| [cfg-sec-002-screensaver-idle](#cfg-sec-002-screensaver-idle-customconfig) | CustomConfig | 1 |
| [cmp-cmp-001-macos-baseline](#cmp-cmp-001-macos-baseline-compliance) | Compliance | 12 |
| [pol-app-100-office](#pol-app-100-office-policy) | Policy | 15 |
| [pol-app-101-edge-level1](#pol-app-101-edge-level1-policy) | Policy | 22 |
| [pol-mde-001-settings-catalog](#pol-mde-001-settings-catalog-policy) | Policy | 60 |
| [pol-sec-001-filevault](#pol-sec-001-filevault-policy) | Policy | 9 |
| [pol-sec-002-firewall](#pol-sec-002-firewall-policy) | Policy | 2 |
| [pol-sec-003-gatekeeper](#pol-sec-003-gatekeeper-policy) | Policy | 4 |
| [pol-sec-004-guest-account](#pol-sec-004-guest-account-policy) | Policy | 1 |
| [pol-sec-005-screensaver](#pol-sec-005-screensaver-policy) | Policy | 6 |
| [pol-sec-006-restrictions](#pol-sec-006-restrictions-policy) | Policy | 80 |
| [pol-sys-100-ntp](#pol-sys-100-ntp-policy) | Policy | 1 |
| [pol-sys-101-login-items](#pol-sys-101-login-items-policy) | Policy | 8 |
| [pol-sys-102-power](#pol-sys-102-power-policy) | Policy | 5 |
| [pol-sys-103-software-update](#pol-sys-103-software-update-policy) | Policy | 9 |
| [pol-sys-104-ddm-passcode](#pol-sys-104-ddm-passcode-policy) | Policy | 11 |
| [pol-sys-105-enrollment-restriction](#pol-sys-105-enrollment-restriction-policy) | Policy | 6 |
| [scr-app-100-install-company-portal](#scr-app-100-install-company-portal-script) | Script | 4 |
| [scr-app-101-office-defaults](#scr-app-101-office-defaults-script) | Script | 4 |
| [scr-app-102-install-remote-help](#scr-app-102-install-remote-help-script) | Script | 4 |
| [scr-app-103-install-intunelogwatch](#scr-app-103-install-intunelogwatch-script) | Script | 4 |
| [scr-mde-100-install-defender](#scr-mde-100-install-defender-script) | Script | 4 |
| [scr-sec-100-install-escrow-buddy](#scr-sec-100-install-escrow-buddy-script) | Script | 4 |
| [scr-sys-100-device-rename](#scr-sys-100-device-rename-script) | Script | 4 |
| [scr-sys-101-configure-dock](#scr-sys-101-configure-dock-script) | Script | 4 |

```{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
```

# Detailed Configuration

### app-utl-001-swift-dialog (Package)

Installs Swift Dialog v2.5.6, a native macOS application for displaying rich, interactive dialogs. This is a required dependency for the visual onboarding experience that provides users with real-time progress feedback during device provisioning and application installation.

**Source:** `apps/app-utl-001-swift-dialog.pkg`  
**Settings:** 5

| Key | Value |
|-----|-------|
| `PrimaryBundleId` | `au.csiro.dialog` |
| `PrimaryBundleVersion` | `2.5.6` |
| `Publisher` | `Bart Reardon` |
| `MinimumSupportedOperatingSystem` | `v13_0` |
| `IgnoreVersionDetection` | `true` |


### app-utl-002-dialog-onboarding (Package)

Displays an interactive Swift Dialog onboarding splash screen showing real-time progress while automatically installing essential Microsoft applications: Company Portal, Office 365, Microsoft Edge, Microsoft 365 Copilot, and Windows App. Pre-install script waits for Swift Dialog binary availability (20 min timeout), and post-install script executes bundled installation scripts in parallel for each application.

**Source:** `apps/app-utl-002-dialog-onboarding.pkg`  
**Settings:** 7

| Key | Value |
|-----|-------|
| `PrimaryBundleId` | `com.intune.swiftdialog` |
| `PrimaryBundleVersion` | `1.3` |
| `Publisher` | `Microsoft` |
| `MinimumSupportedOperatingSystem` | `v13_0` |
| `IgnoreVersionDetection` | `true` |
| `PreInstallScript` | `apps/app-utl-002-dialog-onboarding_pre.sh` |
| `PostInstallScript` | `apps/app-utl-002-dialog-onboarding_post.sh` |


### cat-sys-100-compatibility-checker (CustomAttribute)

Determines the maximum supported macOS version for the current Mac by querying Apple's GDMF API with the hardware's board ID. Works with both Intel and Apple Silicon Macs to provide compatibility information for macOS upgrades.

**Source:** `custom attributes/cat-sys-100-compatibility-checker.zsh`  
**Settings:** 1

| Key | Value |
|-----|-------|
| `CustomAttributeType` | `string` |


### cfg-idp-001-platform-sso (Policy)

Platform Single Sign-On (SSO) configuration for Microsoft Entra ID on macOS.

**Source:** `configurations/entra/cfg-idp-001-platform-sso.json`  
**Settings:** 18

| Key | Value |
|-----|-------|
| `com.apple.extensiblesso_authenticationmethod` | `1` |
| `com.apple.extensiblesso_extensionidentifier` | `com.microsoft.CompanyPortalMac.ssoextension` |
| `com.apple.extensiblesso_platformsso_authenticationmethod` | `1` |
| `com.apple.extensiblesso_platformsso_tokentousermapping_accountname` | `preferred_username` |
| `com.apple.extensiblesso_platformsso_tokentousermapping_fullname` | `name` |
| `com.apple.extensiblesso_platformsso_useshareddevicekeys` | `True` |
| `com.apple.extensiblesso_platformsso_userauthorizationmode` | `1` |
| `com.apple.extensiblesso_registrationtoken` | `{{DEVICEREGISTRATION}}` |
| `com.apple.extensiblesso_screenlockedbehavior` | `0` |
| `com.apple.extensiblesso_teamidentifier` | `UBF8T346G9` |
| `com.apple.extensiblesso_type` | `1` |
| `com.apple.extensiblesso_urls[0]` | `https://login.microsoftonline.com` |
| `com.apple.extensiblesso_urls[1]` | `https://login.microsoft.com` |
| `com.apple.extensiblesso_urls[2]` | `https://sts.windows.net` |
| `com.apple.extensiblesso_urls[3]` | `https://login.partner.microsoftonline.cn` |
| `com.apple.extensiblesso_urls[4]` | `https://login.chinacloudapi.cn` |
| `com.apple.extensiblesso_urls[5]` | `https://login.microsoftonline.us` |
| `com.apple.extensiblesso_urls[6]` | `https://login-us.microsoftonline.com` |


### cfg-sec-001-login-window (CustomConfig)

Essential login window security configuration for macOS devices. Disables FileVault auto-login to ensure users must explicitly authenticate, blocks external account authentication for tighter access control, and prevents administrators from disabling managed preferences to maintain security policy enforcement.

**Source:** `configurations/intune/cfg-sec-001-login-window.mobileconfig`  
**Settings:** 4

| Key | Value |
|-----|-------|
| `com.apple.loginwindow.AdminMayDisableMCX` | `False` |
| `com.apple.loginwindow.DisableFDEAutoLogin` | `True` |
| `com.apple.loginwindow.EnableExternalAccounts` | `False` |
| `com.apple.loginwindow.com.apple.login.mcx.DisableAutoLoginClient` | `True` |


### cfg-sec-002-screensaver-idle (CustomConfig)

Configures screensaver idle time (10 minutes) to address Mac Evaluation Utility warning about unmanaged screensaver idle time settings. This legacy setting requires mobileconfig format as it's not available in Settings Catalog. Works in conjunction with POL-SEC-005 (Screensaver Security) which handles password requirements and other modern screensaver settings via Settings Catalog.

**Source:** `configurations/intune/cfg-sec-002-screensaver-idle.mobileconfig`  
**Settings:** 1

| Key | Value |
|-----|-------|
| `com.apple.screensaver.idleTime` | `600` |


### cmp-cmp-001-macos-baseline (Compliance)

Baseline compliance: FileVault required, Firewall enabled, SIP enabled, minimum macOS 15.0. Gatekeeper configuration handled separately via configuration policy.

**Source:** `configurations/intune/cmp-cmp-001-macos-baseline.json`  
**Settings:** 12

| Key | Value |
|-----|-------|
| `passwordRequired` | `False` |
| `storageRequireEncryption` | `True` |
| `deviceThreatProtectionEnabled` | `False` |
| `deviceThreatProtectionRequiredSecurityLevel` | `unavailable` |
| `firewallEnabled` | `True` |
| `firewallBlockAllIncoming` | `False` |
| `firewallEnableStealthMode` | `True` |
| `systemIntegrityProtectionEnabled` | `True` |
| `osMinimumVersion` | `15.0` |
| `managedEmailProfileRequired` | `False` |
| `scheduledActionsForRule.default.actionCount` | `1` |
| `scheduledActionsForRule.default.action_0` | `block (grace: 0h)` |


### pol-app-100-office (Policy)

Configures Microsoft 365 Office update, channel, auto sign-in, diagnostic, activation, and Outlook experience settings.

**Source:** `configurations/intune/pol-app-100-office.json`  
**Settings:** 15

| Key | Value |
|-----|-------|
| `com.apple.managedclient.preferences_acknowledgeddatacollectionpolicy` | `1` |
| `com.apple.managedclient.preferences_updatedeadline.daysbeforeforcedquit` | `3` |
| `com.apple.managedclient.preferences_disableinsidercheckbox` | `True` |
| `com.apple.managedclient.preferences_howtocheck` | `0` |
| `com.apple.managedclient.preferences_enablecheckforupdatesbutton` | `True` |
| `com.apple.managedclient.preferences_updatedeadline.finalcountdown` | `60` |
| `com.apple.managedclient.preferences_startdaemononapplaunch` | `True` |
| `com.apple.managedclient.preferences_channelname` | `0` |
| `com.apple.managedclient.preferences_updatecheckfrequency` | `240` |
| `com.apple.managedclient.preferences_diagnosticdatatypepreference` | `1` |
| `com.apple.managedclient.preferences_officeautosignin` | `True` |
| `com.apple.managedclient.preferences_officeactivationemailaddress` | `{{mail}}` |
| `com.apple.managedclient.preferences_defaultemailaddressordomain` | `{{mail}}` |
| `com.apple.managedclient.preferences_enablenewoutlook` | `3` |
| `com.apple.managedclient.preferences_userpreference_maxchecklistdisplaydurationmet` | `True` |


### pol-app-101-edge-level1 (Policy)

Enhanced basic browser configuration for Microsoft Edge addressing gap analysis findings (Certificate management, network policies, system integration)

**Source:** `configurations/Secure Enterprise Browser/pol-app-101-edge-level1.json`  
**Settings:** 22

| Key | Value |
|-----|-------|
| `com.apple.managedclient.preferences_importautofillformdata` | `False` |
| `com.apple.managedclient.preferences_importsavedpasswords` | `False` |
| `com.apple.managedclient.preferences_personalizationreportingenabled` | `False` |
| `com.apple.managedclient.preferences_quicallowed` | `False` |
| `com.apple.managedclient.preferences_autoselectcertificateforurls[0]` | `*.arnab.fun` |
| `com.apple.managedclient.preferences_trackingprevention` | `3` |
| `com.apple.managedclient.preferences_automatichttpsdefault` | `2` |
| `com.apple.managedclient.preferences_smartscreenenabled` | `True` |
| `com.apple.managedclient.preferences_homepagelocation` | `https://outlook.office.com` |
| `com.apple.managedclient.preferences_newtabpagelocation` | `https://outlook.office.com` |
| `com.apple.managedclient.preferences_defaultpopupssetting` | `1` |
| `com.apple.managedclient.preferences_dnsinterceptionchecksenabled` | `True` |
| `com.apple.managedclient.preferences_autofilladdressenabled` | `False` |
| `com.apple.managedclient.preferences_autofillcreditcardenabled` | `False` |
| `com.apple.managedclient.preferences_componentupdatesenabled` | `True` |
| `com.apple.managedclient.preferences_networkpredictionoptions` | `2` |
| `com.apple.managedclient.preferences_passwordmanagerenabled` | `False` |
| `com.apple.managedclient.preferences_searchsuggestenabled` | `False` |
| `com.apple.managedclient.preferences_hidefirstrunexperience` | `True` |
| `com.apple.managedclient.preferences_diagnosticdata` | `1` |
| `com.apple.managedclient.preferences_showhomebutton` | `True` |
| `com.apple.managedclient.preferences_updatepolicyoverride` | `0` |


### pol-mde-001-settings-catalog (Policy)

Combined Microsoft Defender for Endpoint settings catalog configuration for macOS.

**Source:** `mde/pol-mde-001-settings-catalog.json`  
**Settings:** 60

| Key | Value |
|-----|-------|
| `com.apple.servicemanagement_rules_item_comment` | `com.microsoft.dlp` |
| `com.apple.servicemanagement_rules_item_ruletype` | `0` |
| `com.apple.servicemanagement_rules_item_rulevalue` | `com.microsoft.fresno` |
| `com.apple.servicemanagement_rules_item_teamidentifier` | `UBF8T346G9` |
| `com.apple.servicemanagement_rules_item_comment` | `com.microsoft.dlp` |
| `com.apple.servicemanagement_rules_item_ruletype` | `0` |
| `com.apple.servicemanagement_rules_item_rulevalue` | `com.microsoft.dlp` |
| `com.apple.servicemanagement_rules_item_teamidentifier` | `UBF8T346G9` |
| `com.apple.servicemanagement_rules_item_comment` | `com.microsoft.wdav` |
| `com.apple.servicemanagement_rules_item_ruletype` | `0` |
| `com.apple.servicemanagement_rules_item_rulevalue` | `com.microsoft.wdav` |
| `com.apple.servicemanagement_rules_item_teamidentifier` | `UBF8T346G9` |
| `com.apple.tcc.configuration-profile-policy_services_accessibility_item_authorization` | `0` |
| `com.apple.tcc.configuration-profile-policy_services_accessibility_item_coderequirement` | `identifier "com.microsoft.dlp.daemon" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* e...` |
| `com.apple.tcc.configuration-profile-policy_services_accessibility_item_identifier` | `com.microsoft.dlp.daemon` |
| `com.apple.tcc.configuration-profile-policy_services_accessibility_item_identifiertype` | `0` |
| `com.apple.tcc.configuration-profile-policy_services_accessibility_item_staticcode` | `False` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_authorization` | `0` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_coderequirement` | `identifier "com.microsoft.wdav" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* exists ...` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_identifier` | `com.microsoft.wdav` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_identifiertype` | `0` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_staticcode` | `False` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_authorization` | `0` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_coderequirement` | `identifier "com.microsoft.wdav.epsext" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* ...` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_identifier` | `com.microsoft.wdav.epsext` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_identifiertype` | `0` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_staticcode` | `False` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_authorization` | `0` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_coderequirement` | `identifier "com.microsoft.dlp.daemon" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* e...` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_identifier` | `com.microsoft.dlp.daemon` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_identifiertype` | `0` |
| `com.apple.tcc.configuration-profile-policy_services_systempolicyallfiles_item_staticcode` | `False` |
| `com.apple.system-extension-policy_allowuseroverrides` | `True` |
| `com.apple.system-extension-policy_allowedsystemextensions_generickey[0]` | `com.microsoft.wdav.epsext` |
| `com.apple.system-extension-policy_allowedsystemextensions_generickey[1]` | `com.microsoft.wdav.netext` |
| `com.apple.system-extension-policy_allowedsystemextensions_generickey_keytobereplaced` | `UBF8T346G9` |
| `com.apple.notificationsettings_notificationsettings_item_alerttype` | `2` |
| `com.apple.notificationsettings_notificationsettings_item_badgesenabled` | `True` |
| `com.apple.notificationsettings_notificationsettings_item_bundleidentifier` | `com.microsoft.autoupdate2` |
| `com.apple.notificationsettings_notificationsettings_item_criticalalertenabled` | `False` |
| `com.apple.notificationsettings_notificationsettings_item_notificationsenabled` | `True` |
| `com.apple.notificationsettings_notificationsettings_item_showinlockscreen` | `False` |
| `com.apple.notificationsettings_notificationsettings_item_showinnotificationcenter` | `True` |
| `com.apple.notificationsettings_notificationsettings_item_soundsenabled` | `True` |
| `com.apple.notificationsettings_notificationsettings_item_alerttype` | `1` |
| `com.apple.notificationsettings_notificationsettings_item_badgesenabled` | `True` |
| `com.apple.notificationsettings_notificationsettings_item_bundleidentifier` | `com.microsoft.wdav.tray` |
| `com.apple.notificationsettings_notificationsettings_item_criticalalertenabled` | `False` |
| `com.apple.notificationsettings_notificationsettings_item_notificationsenabled` | `True` |
| `com.apple.notificationsettings_notificationsettings_item_showinlockscreen` | `False` |
| `com.apple.notificationsettings_notificationsettings_item_showinnotificationcenter` | `True` |
| `com.apple.notificationsettings_notificationsettings_item_soundsenabled` | `True` |
| `com.apple.webcontent-filter_filterdataproviderbundleidentifier` | `com.microsoft.wdav.netext` |
| `com.apple.webcontent-filter_filterdataproviderdesignatedrequirement` | `identifier "com.microsoft.wdav.netext" and anchor apple generic and certificate 1[field.1.2.840.113635.100.6.2.6] /* ...` |
| `com.apple.webcontent-filter_filtergrade` | `1` |
| `com.apple.webcontent-filter_filterpackets` | `False` |
| `com.apple.webcontent-filter_filtersockets` | `True` |
| `com.apple.webcontent-filter_filtertype` | `1` |
| `com.apple.webcontent-filter_pluginbundleid` | `com.microsoft.wdav` |
| `com.apple.webcontent-filter_userdefinedname` | `MDE Network Filter` |


### pol-sec-001-filevault (Policy)

Configures FileVault disk encryption on macOS devices during Setup Assistant with recovery key escrow.

**Source:** `configurations/intune/pol-sec-001-filevault.json`  
**Settings:** 9

| Key | Value |
|-----|-------|
| `com.apple.mcx.filevault2_defer` | `True` |
| `com.apple.mcx.filevault2_enable` | `0` |
| `com.apple.mcx.filevault2_forceenableinsetupassistant` | `True` |
| `com.apple.mcx.filevault2_showrecoverykey` | `False` |
| `com.apple.mcx.filevault2_userecoverykey` | `True` |
| `com.apple.mcx.filevault2_userentersmissinginfo` | `False` |
| `com.apple.mcx_dontallowfdedisable` | `True` |
| `com.apple.mcx_dontallowfdeenable` | `False` |
| `com.apple.security.fderecoverykeyescrow_location` | `https://user.manage.microsoft.com` |


### pol-sec-002-firewall (Policy)

**Source:** `configurations/intune/pol-sec-002-firewall.json`  
**Settings:** 2

| Key | Value |
|-----|-------|
| `com.apple.preference.security_dontAllowFireWallUI` | `True` |
| `com.apple.security.firewall_EnableFirewall` | `True` |


### pol-sec-003-gatekeeper (Policy)

Comprehensive Gatekeeper and system policy security configuration for macOS devices. Enables application security assessment, allows identified developers while maintaining security, enables XProtect malware upload for threat intelligence, and prevents users from overriding these critical security policies through system preferences.

**Source:** `configurations/intune/pol-sec-003-gatekeeper.json`  
**Settings:** 4

| Key | Value |
|-----|-------|
| `com.apple.systempolicy.control_AllowIdentifiedDevelopers` | `True` |
| `com.apple.systempolicy.control_EnableAssessment` | `True` |
| `com.apple.systempolicy.control_EnableXProtectMalwareUpload` | `True` |
| `com.apple.systempolicy.managed_DisableOverride` | `True` |


### pol-sec-004-guest-account (Policy)

**Source:** `configurations/intune/pol-sec-004-guest-account.json`  
**Settings:** 1

| Key | Value |
|-----|-------|
| `com.apple.mcx_DisableGuestAccount` | `True` |


### pol-sec-005-screensaver (Policy)

Configures comprehensive screensaver security settings to protect unattended devices. Sets screensaver to activate after 10 minutes of inactivity (user setting), requires password authentication after 60 seconds of screensaver activation, sets login window idle timeout to 20 minutes, and enforces the Flurry screensaver module for both system and user contexts.

**Source:** `configurations/intune/pol-sec-005-screensaver.json`  
**Settings:** 6

| Key | Value |
|-----|-------|
| `com.apple.screensaver_askForPassword` | `True` |
| `com.apple.screensaver_askForPasswordDelay` | `60` |
| `com.apple.screensaver_loginWindowIdleTime` | `1200` |
| `com.apple.screensaver_moduleName` | `Flurry` |
| `com.apple.screensaver.user_idleTime` | `600` |
| `com.apple.screensaver.user_moduleName` | `Flurry` |


### pol-sec-006-restrictions (Policy)

Comprehensive security policy for macOS devices that restricts various system features and applications to enhance enterprise security. Disables AirDrop, Activity Continuation, Game Center, cloud services, App Store, and other potentially risky features while maintaining core business functionality.

**Source:** `configurations/intune/pol-sec-006-restrictions.json`  
**Settings:** 80

| Key | Value |
|-----|-------|
| `com.apple.mcx_disableguestaccount` | `True` |
| `com.apple.applicationaccess_allowaccountmodification` | `True` |
| `com.apple.applicationaccess_allowactivitycontinuation` | `False` |
| `com.apple.applicationaccess_allowaddinggamecenterfriends` | `False` |
| `com.apple.applicationaccess_allowairplayincomingrequests` | `False` |
| `com.apple.applicationaccess_allowairdrop` | `False` |
| `com.apple.applicationaccess_allowappleintelligencereport` | `False` |
| `com.apple.applicationaccess_allowapplepersonalizedadvertising` | `False` |
| `com.apple.applicationaccess_allowardremotemanagementmodification` | `True` |
| `com.apple.applicationaccess_allowassistant` | `False` |
| `com.apple.applicationaccess_allowautounlock` | `True` |
| `com.apple.applicationaccess_allowbluetoothmodification` | `True` |
| `com.apple.applicationaccess_allowbluetoothsharingmodification` | `True` |
| `com.apple.applicationaccess_allowbookstore` | `False` |
| `com.apple.applicationaccess_allowbookstoreerotica` | `False` |
| `com.apple.applicationaccess_allowcamera` | `True` |
| `com.apple.applicationaccess_allowcloudaddressbook` | `False` |
| `com.apple.applicationaccess_allowcloudbookmarks` | `False` |
| `com.apple.applicationaccess_allowcloudcalendar` | `False` |
| `com.apple.applicationaccess_allowclouddesktopanddocuments` | `False` |
| `com.apple.applicationaccess_allowclouddocumentsync` | `False` |
| `com.apple.applicationaccess_allowcloudfreeform` | `False` |
| `com.apple.applicationaccess_allowcloudkeychainsync` | `False` |
| `com.apple.applicationaccess_allowcloudmail` | `False` |
| `com.apple.applicationaccess_allowcloudnotes` | `False` |
| `com.apple.applicationaccess_allowcloudphotolibrary` | `False` |
| `com.apple.applicationaccess_allowcloudprivaterelay` | `False` |
| `com.apple.applicationaccess_allowcloudreminders` | `False` |
| `com.apple.applicationaccess_allowcontentcaching` | `False` |
| `com.apple.applicationaccess_allowdefinitionlookup` | `False` |
| `com.apple.applicationaccess_allowdevicenamemodification` | `True` |
| `com.apple.applicationaccess_allowdiagnosticsubmission` | `False` |
| `com.apple.applicationaccess_allowdictation` | `False` |
| `com.apple.applicationaccess_allowerasecontentandsettings` | `True` |
| `com.apple.applicationaccess_allowexplicitcontent` | `False` |
| `com.apple.applicationaccess_allowexternalintelligenceintegrations` | `False` |
| `com.apple.applicationaccess_allowexternalintelligenceintegrationssignin` | `False` |
| `com.apple.applicationaccess_allowfilesharingmodification` | `False` |
| `com.apple.applicationaccess_allowfindmydevice` | `True` |
| `com.apple.applicationaccess_allowfindmyfriends` | `False` |
| `com.apple.applicationaccess_allowfingerprintforunlock` | `True` |
| `com.apple.applicationaccess_allowfingerprintmodification` | `True` |
| `com.apple.applicationaccess_allowgamecenter` | `False` |
| `com.apple.applicationaccess_allowgenmoji` | `False` |
| `com.apple.applicationaccess_allowimageplayground` | `False` |
| `com.apple.applicationaccess_allowinternetsharingmodification` | `True` |
| `com.apple.applicationaccess_allowiphonemirroring` | `True` |
| `com.apple.applicationaccess_allowitunesfilesharing` | `False` |
| `com.apple.applicationaccess_allowlocalusercreation` | `True` |
| `com.apple.applicationaccess_allowmailsmartreplies` | `False` |
| `com.apple.applicationaccess_allowmailsummary` | `False` |
| `com.apple.applicationaccess_allowmediasharingmodification` | `True` |
| `com.apple.applicationaccess_allowmultiplayergaming` | `False` |
| `com.apple.applicationaccess_allowmusicservice` | `True` |
| `com.apple.applicationaccess_allownotestranscription` | `False` |
| `com.apple.applicationaccess_allownotestranscriptionsummary` | `False` |
| `com.apple.applicationaccess_allowpasscodemodification` | `True` |
| `com.apple.applicationaccess_allowpasswordautofill` | `False` |
| `com.apple.applicationaccess_allowpasswordproximityrequests` | `False` |
| `com.apple.applicationaccess_allowpasswordsharing` | `False` |
| `com.apple.applicationaccess_allowprintersharingmodification` | `True` |
| `com.apple.applicationaccess_allowrapidsecurityresponseinstallation` | `True` |
| `com.apple.applicationaccess_allowrapidsecurityresponseremoval` | `True` |
| `com.apple.applicationaccess_allowremoteappleeventsmodification` | `True` |
| `com.apple.applicationaccess_allowremotescreenobservation` | `True` |
| `com.apple.applicationaccess_allowsafarihistoryclearing` | `True` |
| `com.apple.applicationaccess_allowsafariprivatebrowsing` | `True` |
| `com.apple.applicationaccess_allowsafarisummary` | `True` |
| `com.apple.applicationaccess_allowscreenshot` | `True` |
| `com.apple.applicationaccess_allowspotlightinternetresults` | `False` |
| `com.apple.applicationaccess_allowstartupdiskmodification` | `False` |
| `com.apple.applicationaccess_allowtimemachinebackup` | `False` |
| `com.apple.applicationaccess_allowuiconfigurationprofileinstallation` | `False` |
| `com.apple.applicationaccess_allowuniversalcontrol` | `False` |
| `com.apple.applicationaccess_allowusbrestrictedmode` | `True` |
| `com.apple.applicationaccess_allowwallpapermodification` | `True` |
| `com.apple.applicationaccess_allowwritingtools` | `False` |
| `com.apple.applicationaccess_forcebypassscreencapturealert` | `False` |
| `com.apple.applicationaccess_forceondeviceonlydictation` | `True` |
| `com.apple.applicationaccess_safariallowautofill` | `False` |


### pol-sys-100-ntp (Policy)

Configures macOS devices to synchronize time with Apple's official time servers (time.apple.com) to ensure accurate system time across all managed devices. Essential for security features, certificate validation, and consistent logging.

**Source:** `configurations/intune/pol-sys-100-ntp.json`  
**Settings:** 1

| Key | Value |
|-----|-------|
| `com.apple.mcx_timeserver` | `time.apple.com` |


### pol-sys-101-login-items (Policy)

**Source:** `configurations/intune/pol-sys-101-login-items.json`  
**Settings:** 8

| Key | Value |
|-----|-------|
| `com.apple.servicemanagement_rules_item_comment` | `Palo Alto` |
| `com.apple.servicemanagement_rules_item_ruletype` | `4` |
| `com.apple.servicemanagement_rules_item_rulevalue` | `PXPZ95SK77` |
| `com.apple.servicemanagement_rules_item_teamidentifier` | `PXPZ95SK77` |
| `com.apple.servicemanagement_rules_item_comment` | `Microsoft` |
| `com.apple.servicemanagement_rules_item_ruletype` | `4` |
| `com.apple.servicemanagement_rules_item_rulevalue` | `UBF8T346G9` |
| `com.apple.servicemanagement_rules_item_teamidentifier` | `UBF8T346G9` |


### pol-sys-102-power (Policy)

Configures power management and energy saver settings for macOS devices. Sets display sleep to 5 minutes and system sleep to 10 minutes for both desktop (AC power) and portable devices. Enables Wake on LAN for desktop computers to allow network-based device management and remote wake capabilities.

**Source:** `configurations/intune/pol-sys-102-power.json`  
**Settings:** 5

| Key | Value |
|-----|-------|
| `com.apple.mcx_com.apple.energysaver.desktop.acpower_display sleep timer` | `5` |
| `com.apple.mcx_com.apple.energysaver.desktop.acpower_system sleep timer` | `10` |
| `com.apple.mcx_com.apple.energysaver.desktop.acpower_wake on lan` | `1` |
| `com.apple.mcx_com.apple.energysaver.portable.acpower_display sleep timer` | `5` |
| `com.apple.mcx_com.apple.energysaver.portable.acpower_system sleep timer` | `10` |


### pol-sys-103-software-update (Policy)

Manages macOS software updates with automatic installation at 1:00 AM (3-day delay for latest updates), enables standard user OS updates, automatic download/install of OS and security updates, enables notifications and Rapid Security Response (RSR) updates for immediate threat mitigation.

**Source:** `configurations/intune/pol-sys-103-software-update.json`  
**Settings:** 9

| Key | Value |
|-----|-------|
| `ddm-latestsoftwareupdate_enforcelatestsoftwareupdateversion` | `0` |
| `ddm-latestsoftwareupdate_delayindays` | `3` |
| `ddm-latestsoftwareupdate_installtime` | `01:00` |
| `softwareupdate_allowstandarduserosupdates` | `True` |
| `softwareupdate_automaticactions_download` | `1` |
| `softwareupdate_automaticactions_installosupdates` | `1` |
| `softwareupdate_automaticactions_installsecurityupdate` | `1` |
| `softwareupdate_notifications` | `True` |
| `softwareupdate_rapidsecurityresponse_enable` | `True` |


### pol-sys-104-ddm-passcode (Policy)

Enforces passcode requirements including length, complexity, failed attempts, and expiration.

**Source:** `configurations/intune/pol-sys-104-ddm-passcode.json`  
**Settings:** 11

| Key | Value |
|-----|-------|
| `passcode_changeatnextauth` | `False` |
| `passcode_failedattemptsresetinminutes` | `0` |
| `passcode_maximumgraceperiodinminutes` | `0` |
| `passcode_maximumfailedattempts` | `11` |
| `passcode_maximumpasscodeageindays` | `365` |
| `passcode_minimumcomplexcharacters` | `1` |
| `passcode_minimumlength` | `6` |
| `passcode_passcodereuselimit` | `1` |
| `passcode_requirealphanumericpasscode` | `True` |
| `passcode_requirecomplexpasscode` | `True` |
| `passcode_requirepasscode` | `True` |


### pol-sys-105-enrollment-restriction (Policy)

**Source:** `configurations/intune/pol-sys-105-enrollment-restriction.json`  
**Settings:** 6

| Key | Value |
|-----|-------|
| `platformRestriction.platformBlocked` | `False` |
| `platformRestriction.personalDeviceEnrollmentBlocked` | `False` |
| `platformRestriction.osMinimumVersion` | `15.0` |
| `platformRestriction.osMaximumVersion` | `` |
| `platformRestriction.blockedManufacturers` | `[]` |
| `platformRestriction.blockedSkus` | `[]` |


### scr-app-100-install-company-portal (Script)

Downloads and installs Microsoft Company Portal from a signed PKG. Automatically installs Microsoft Auto Update (MAU) first and ensures Rosetta 2 is present on Apple Silicon. Performs intelligent update checking via HTTP Last-Modified headers to avoid unnecessary reinstalls.

**Source:** `scripts/intune/scr-app-100-install-company-portal.sh`  
**Settings:** 4

| Key | Value |
|-----|-------|
| `RunAsAccount` | `system` |
| `BlockExecutionNotifications` | `true` |
| `ExecutionFrequency` | `PT0S` |
| `RetryCount` | `3` |


### scr-app-101-office-defaults (Script)

Configures Microsoft Office applications (Word, Excel, PowerPoint, Outlook) as the default handlers for all Office-related document types and URL schemes. Automatically installs utiluti v1.1 if not present and runs associations in the current user context via launchctl.

**Source:** `scripts/intune/scr-app-101-office-defaults.sh`  
**Settings:** 4

| Key | Value |
|-----|-------|
| `RunAsAccount` | `system` |
| `BlockExecutionNotifications` | `true` |
| `ExecutionFrequency` | `PT0S` |
| `RetryCount` | `3` |


### scr-app-102-install-remote-help (Script)

Downloads and installs Microsoft Remote Help from a signed PKG. Automatically installs Microsoft Auto Update (MAU) first and ensures Rosetta 2 is present on Apple Silicon. Performs intelligent update checking via HTTP Last-Modified headers to avoid unnecessary reinstalls. Enables IT support teams to provide remote assistance to macOS devices.

**Source:** `scripts/intune/scr-app-102-install-remote-help.sh`  
**Settings:** 4

| Key | Value |
|-----|-------|
| `RunAsAccount` | `system` |
| `BlockExecutionNotifications` | `true` |
| `ExecutionFrequency` | `PT0S` |
| `RetryCount` | `3` |


### scr-app-103-install-intunelogwatch (Script)

Downloads the latest Intune Log Watch DMG from GitHub, mounts it, and copies IntuneLogWatch.app into /Applications. Cleans up the DMG and mount point automatically.

**Source:** `scripts/intune/scr-app-103-install-intunelogwatch.zsh`  
**Settings:** 4

| Key | Value |
|-----|-------|
| `RunAsAccount` | `system` |
| `BlockExecutionNotifications` | `true` |
| `ExecutionFrequency` | `PT0S` |
| `RetryCount` | `3` |


### scr-mde-100-install-defender (Script)

Install Microsoft Defender for Endpoint (PKG); waits for core Microsoft apps, ensures Rosetta, uses Last-Modified for update skip.

**Source:** `mde/scr-mde-100-install-defender.zsh`  
**Settings:** 4

| Key | Value |
|-----|-------|
| `RunAsAccount` | `system` |
| `BlockExecutionNotifications` | `true` |
| `ExecutionFrequency` | `PT0S` |
| `RetryCount` | `3` |


### scr-sec-100-install-escrow-buddy (Script)

Downloads and installs the latest release of Escrow Buddy security agent plugin from GitHub. Ensures FileVault recovery keys are properly escrowed to Intune by configuring the authorization database and triggering escrow at login when the FDE profile and PRK file are present.

**Source:** `scripts/intune/scr-sec-100-install-escrow-buddy.sh`  
**Settings:** 4

| Key | Value |
|-----|-------|
| `RunAsAccount` | `system` |
| `BlockExecutionNotifications` | `true` |
| `ExecutionFrequency` | `PT0S` |
| `RetryCount` | `3` |


### scr-sys-100-device-rename (Script)

Automatically renames Mac devices using a standardized naming convention based on enrollment type (ADE/BYOD), device model type (MBA/MBP/iMac/etc), serial number, and detected country code via IP geolocation. Differentiates between corporate (ABM-enrolled) and personal (manually-enrolled) devices with configurable prefixes.

**Source:** `scripts/intune/scr-sys-100-device-rename.sh`  
**Settings:** 4

| Key | Value |
|-----|-------|
| `RunAsAccount` | `system` |
| `BlockExecutionNotifications` | `true` |
| `ExecutionFrequency` | `PT0S` |
| `RetryCount` | `3` |


### scr-sys-101-configure-dock (Script)

Configures the macOS Dock with a standardized set of Microsoft 365 and system applications. Optionally waits for applications to be installed before configuration. Supports both dockutil and native plist manipulation methods. Integrates with Swift Dialog for deployment progress visualization and adapts to macOS versions (Apps.app vs Launchpad).

**Source:** `scripts/intune/scr-sys-101-configure-dock.sh`  
**Settings:** 4

| Key | Value |
|-----|-------|
| `RunAsAccount` | `system` |
| `BlockExecutionNotifications` | `true` |
| `ExecutionFrequency` | `PT0S` |
| `RetryCount` | `3` |


