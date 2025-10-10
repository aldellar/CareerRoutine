#!/bin/bash

# Script to help add files to Xcode project
# This creates a reference list of files that need to be added

echo "📁 Files on disk but NOT in Xcode project:"
echo ""
echo "Files in Networking/:"
ls -1 ios/InterviewPrepApp/InterviewPrepApp/Networking/*.swift 2>/dev/null | xargs -I {} basename {}
echo ""
echo "Files in Networking/Models/:"
ls -1 ios/InterviewPrepApp/InterviewPrepApp/Networking/Models/*.swift 2>/dev/null | xargs -I {} basename {}
echo ""
echo "Files in ViewModels/:"
ls -1 ios/InterviewPrepApp/InterviewPrepApp/ViewModels/*.swift 2>/dev/null | xargs -I {} basename {}
echo ""
echo "Files in Utils/:"
ls -1 ios/InterviewPrepApp/InterviewPrepApp/Utils/Loadable.swift ios/InterviewPrepApp/InterviewPrepApp/Utils/AlertState.swift 2>/dev/null | xargs -I {} basename {}
echo ""
echo "================================"
echo "TO FIX:"
echo "1. Open: ios/InterviewPrepApp/InterviewPrepApp.xcodeproj"
echo "2. In Xcode, right-click 'InterviewPrepApp' folder"
echo "3. Select 'Add Files to InterviewPrepApp...'"
echo "4. Navigate to ios/InterviewPrepApp/InterviewPrepApp/"
echo "5. Select 'Networking' and 'ViewModels' folders"
echo "6. Ensure 'Create groups' and 'InterviewPrepApp' target are selected"
echo "7. Click 'Add'"
echo "8. Clean (⌘⇧K) and Build (⌘B)"
echo "================================"

