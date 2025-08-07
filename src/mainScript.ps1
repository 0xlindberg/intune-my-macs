
$manifestUrl = "https://raw.githubusercontent.com/microsoft/intune-my-macs/d5032d75e28614ff2d99dfea62115da3764a5fa4/manifest.xml?token=GHSAT0AAAAAADGFKNLDBFKKBN5XQ75FYGBY2EVENXA"

$xmlManifest = (Invoke-WebRequest -Uri $manifestUrl -Method GET)
$xmlManifest #| ConvertTo-Json -Depth 10

foreach ($item in $xmlManifest.manifest) {
    # Process each item in the manifest
    $item | ConvertTo-Json -Depth 10
    Write-Output $item
}   