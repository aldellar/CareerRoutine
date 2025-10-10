#!/bin/bash

# Reset Xcode - Make it forget everything about the project
# This script clears all Xcode caches and user data

set -e

echo "🧹 Resetting Xcode for InterviewPrepApp..."
echo ""

# 1. Close Xcode if it's running
echo "📍 Step 1: Closing Xcode..."
osascript -e 'quit app "Xcode"' 2>/dev/null || echo "Xcode not running"
sleep 2

# 2. Clear Xcode's Derived Data (global cache)
echo "📍 Step 2: Clearing Xcode Derived Data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "✓ Cleared ~/Library/Developer/Xcode/DerivedData/"

# 3. Clear Xcode's Archives
echo "📍 Step 3: Clearing Xcode Archives..."
rm -rf ~/Library/Developer/Xcode/Archives/*
echo "✓ Cleared ~/Library/Developer/Xcode/Archives/"

# 4. Clear Xcode's Device Logs
echo "📍 Step 4: Clearing Device Logs..."
rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/*/Symbols/System/Library/Caches
echo "✓ Cleared Device Logs"

# 5. Clear project-specific user data
echo "📍 Step 5: Clearing project user data..."
cd "$(dirname "$0")/ios/InterviewPrepApp"

# Remove user-specific Xcode state files
find . -name "*.xcuserstate" -delete
find . -name "*.xcuserdatad" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "xcuserdata" -type d -exec rm -rf {} + 2>/dev/null || true

echo "✓ Cleared project user data"

# 6. Clear workspace shared data (optional - keeps schemes)
echo "📍 Step 6: Clearing workspace cache..."
find . -name "*.xcworkspace" -type d -exec rm -rf {}/xcshareddata/IDEWorkspaceChecks.plist \; 2>/dev/null || true

echo "✓ Cleared workspace cache"

# 7. Clean build folder via command line
echo "📍 Step 7: Cleaning build folder..."
if [ -f "InterviewPrepApp.xcodeproj/project.pbxproj" ]; then
    xcodebuild clean -project InterviewPrepApp.xcodeproj -scheme InterviewPrepApp 2>/dev/null || echo "Clean via xcodebuild (optional step - continuing...)"
fi

echo ""
echo "✅ Xcode has been completely reset!"
echo ""
echo "📱 Next steps:"
echo "1. cd $(pwd)"
echo "2. open InterviewPrepApp.xcodeproj"
echo "3. Wait for Xcode to re-index (watch progress in top bar)"
echo "4. Clean Build Folder (⌘⇧K)"
echo "5. Build (⌘B)"
echo ""
echo "Xcode will now treat this as a fresh project! 🎉"



