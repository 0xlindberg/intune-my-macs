#!/bin/zsh

############################################################################################
## Install Microsoft 365 Copilot (macOS Universal PKG)
## Version: 1.1.1
## Maintainer: neiljohn@microsoft.com
## Summary: Resolve fwlink -> download PKG -> validate -> install -> record Last-Modified.
## Exit codes: 0 success / not-needed, 1 failure.
############################################################################################

## Copyright (c) 2020 Microsoft Corp. All rights reserved.
## Scripts are not supported under any Microsoft standard support program or service. The scripts are provided AS IS without warranty of any kind.
## Microsoft disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a
## particular purpose. The entire risk arising out of the use or performance of the scripts and documentation remains with you. In no event shall
## Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever
## (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary
## loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility
## of such damages.
## Feedback: neiljohn@microsoft.com

## Config
weburl="https://go.microsoft.com/fwlink/?linkid=2325438"  # fwlink to latest Copilot PKG
appname="Microsoft 365 Copilot"
app="Microsoft 365 Copilot.app"
logandmetadir="/Library/Logs/Microsoft/IntuneScripts/installM365Copilot"
processpath="/Applications/Microsoft 365 Copilot.app/Contents/MacOS/Microsoft 365 Copilot"
terminateprocess="true"   # Kill running app first
autoUpdate="true"         # App self-updates; skip if present

# Generated variables
tempdir=$(mktemp -d)
log="$logandmetadir/$appname.log"                                               # The location of the script log file
metafile="$logandmetadir/$appname.meta"                                         # The location of our meta file (for updates)

## Helpers
cleanup() { [[ -d "$tempdir" ]] && rm -rf "$tempdir"; }
trap cleanup EXIT

## waitForProcess <proc> <fixedDelay?> <terminate?>
waitForProcess () {
    local name="$1" fixed="$2" terminate="$3" delay pid
    echo "$(date) | Waiting for [$name]"
    while pgrep -f "$name" >/dev/null 2>&1; do
        if [[ $terminate == true || $terminate == "true" ]]; then
            pid=$(pgrep -f "$name" | head -n1)
            [[ -n $pid ]] && { echo "$(date) | Terminating pid [$pid] ($name)"; kill -9 "$pid" 2>/dev/null || true; }
            return
        fi
        delay=${fixed:-$(( RANDOM % 50 + 10 ))}
        echo "$(date) | Still running, sleep $delay"
        sleep "$delay"
    done
    echo "$(date) | No running [$name]"
}

# (Rosetta check removed - app is universal)

## fetchLastModifiedDate [update]
fetchLastModifiedDate() {
    mkdir -p "$logandmetadir"
    local target="${resolvedurl:-$weburl}"
    lastmodified=$(curl -sIL "$target" | awk 'tolower($0) ~ /^last-modified:/ { $1=""; sub(/^ +/, ""); gsub(/\r$/, ""); print }' | tail -n1)
    [[ $1 == update ]] && echo "$lastmodified" > "$metafile"
}

# Download PKG
downloadApp () {
    echo "$(date) | Download $appname"
    cd "$tempdir" || exit 1
    finalurl=$(curl -sIL -o /dev/null -w '%{url_effective}' "$weburl")
    resolvedurl="$finalurl"
    echo "$(date) | Final URL: $finalurl"
    if [[ -z $finalurl || ( $finalurl != *.pkg && $finalurl != *.pkg\?* ) ]]; then
        echo "$(date) | Invalid final URL"; updateOctory failed; exit 1
    fi
    local outfile="copilot.pkg"
    curl -f -S --connect-timeout 30 --retry 5 --retry-delay 60 -L -D headers.txt -o "$outfile" "$weburl" || { echo "$(date) | Download failed"; updateOctory failed; exit 1; }
    local expected=$(awk 'tolower($0) ~ /^content-length:/ {print $2}' headers.txt | tail -n1 | tr -d '\r')
    local size=$(stat -f%z "$outfile" 2>/dev/null || echo 0)
    [[ -n $expected && $expected != $size ]] && { echo "$(date) | Size mismatch expected $expected got $size"; updateOctory failed; exit 1; }
    filetype=$(file -b "$outfile" 2>/dev/null || echo unknown)
    echo "$filetype" | grep -qi xar || { echo "$(date) | Not a PKG"; updateOctory failed; exit 1; }
    tempfile="$outfile"; packageType="PKG"
    if [[ $outfile == *_universal_*_Installer.pkg ]]; then
        detectedVersion="${outfile##*_universal_}"; detectedVersion="${detectedVersion%_Installer.pkg}"; echo "$(date) | Version $detectedVersion"
    fi
    echo "$(date) | Download OK"
}

# Check if we need to update or not
updateCheck() {
    echo "$(date) | Update check"
    if [[ -d "/Applications/$app" ]]; then
        [[ $autoUpdate == true || $autoUpdate == "true" ]] && { echo "$(date) | Present & self-updating"; exit 0; }
        fetchLastModifiedDate
        if [[ -f $metafile ]]; then
            local prev=$(cat "$metafile")
            [[ -n $prev && $prev == $lastmodified ]] && { echo "$(date) | No change"; exit 0; } || echo "$(date) | Updated content detected"
        else
            echo "$(date) | No meta file"
        fi
    else
        echo "$(date) | Not installed"
    fi
}

## Install PKG Function (PKG-only path)
installPKG () {
    waitForProcess "$processpath" 300 "$terminateprocess"
    echo "$(date) | Install $appname"
    updateOctory installing
    [[ -d "/Applications/$app" ]] && rm -rf "/Applications/$app"
    if installer -pkg "$tempfile" -target /; then
        fetchLastModifiedDate update
        updateOctory installed
        echo "$(date) | Install complete"
        exit 0
    else
        echo "$(date) | Install failed"; updateOctory failed; exit 1
    fi
}

updateOctory () { [[ -e "/Library/Application Support/Octory" && $(pgrep -f Octory) ]] && /usr/local/bin/octo-notifier monitor "$appname" --state "$1" >/dev/null 2>&1 || true; }

startLog() { mkdir -p "$logandmetadir"; exec > >(tee -a "$log") 2>&1; }

# delay until the user has finished setup assistant.
waitForDesktop () { until pgrep -f "/CoreServices/Dock.app/Contents/MacOS/Dock" >/dev/null 2>&1; do local d=$(( RANDOM % 50 + 10 )); echo "$(date) | Dock not ready ($d)s"; sleep $d; done; echo "$(date) | Desktop ready"; }

###################################################################################
###################################################################################
## Begin Script Body
###################################################################################
###################################################################################

startLog

echo "\n### $(date) | $appname install log -> $log"

updateCheck
waitForDesktop

downloadApp

[[ $packageType == PKG ]] && installPKG || { echo "$(date) | Unsupported package type [$packageType]"; exit 1; }