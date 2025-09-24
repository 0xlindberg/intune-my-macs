#!/bin/zsh

# Intune macOS Policy Deployment Script
# This script removes all existing policies and redeploys them with group assignment

set -e  # Exit on any error

echo "🚀 Intune macOS Policy Deployment Script"
echo "========================================="
echo

# Get the script directory to ensure we're in the right location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📍 Working directory: $(pwd)"
echo

# Step 1: Remove all existing policies
echo "🗑️  STEP 1: Removing all existing Intune policies..."
echo "---------------------------------------------------"
pwsh ./src/mainScript.ps1 --remove-all

if [ $? -eq 0 ]; then
    echo "✅ All existing policies successfully removed"
else
    echo "❌ Error removing existing policies"
    exit 1
fi

echo
echo "⏳ Waiting 10 seconds before redeployment..."
sleep 10
echo

# Step 2: Deploy all policies with group assignment
echo "🚀 STEP 2: Deploying policies with group assignment..."
echo "-----------------------------------------------------"
pwsh ./src/mainScript.ps1 --assign-group="intune-my-mac" --mde

if [ $? -eq 0 ]; then
    echo
    echo "🎉 DEPLOYMENT COMPLETE!"
    echo "======================="
    echo "✅ All policies have been successfully deployed"
    echo "🎯 Group Assignment: intune-my-mac"
    echo "🛡️  MDE Integration: Enabled"
    echo
    echo "📋 Next Steps:"
    echo "  1. Verify policies in Microsoft Intune admin center"
    echo "  2. Check group assignments are correct"
    echo "  3. Monitor device compliance and policy application"
else
    echo "❌ Error during policy deployment"
    exit 1
fi
