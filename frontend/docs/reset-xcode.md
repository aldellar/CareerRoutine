# Reset Xcode Guide

How to make Xcode completely forget your project and treat it as fresh.

## When to Reset

Reset Xcode when you encounter:
- Xcode opening with old file paths
- "File not found" errors for files that exist
- Autocomplete not working for new files
- Stale build issues
- Project structure changes not recognized

---

## 🚀 Quick Reset (Recommended)

Run the automated script from the `frontend` directory:

```bash
cd /Users/dellaringo/Documents/GitHub/AiOSapp/frontend
./reset-xcode.sh
```

This will:
1. ✓ Close Xcode
2. ✓ Clear all Derived Data
3. ✓ Clear Archives
4. ✓ Clear Device Logs
5. ✓ Remove project user state files
6. ✓ Clean build folder

Then open the project fresh:

```bash
cd ios/InterviewPrepApp
open InterviewPrepApp.xcodeproj
```

---

## 🔧 Manual Reset (Alternative)

### Step 1: Close Xcode
```bash
# Force quit Xcode
killall Xcode
```

### Step 2: Clear Derived Data (Global Cache)
```bash
# This is Xcode's main cache location
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

**Via Xcode Menu:**
- Xcode → Preferences → Locations
- Click arrow next to "Derived Data" path
- Delete the entire folder

### Step 3: Clear Project User Data
```bash
cd /path/to/frontend/ios/InterviewPrepApp

# Remove user-specific state
find . -name "*.xcuserstate" -delete
find . -name "xcuserdata" -type d -exec rm -rf {} + 2>/dev/null
```

**What this removes:**
- `*.xcuserstate` - Window positions, tabs, breakpoints
- `xcuserdata/` - User-specific settings and state

### Step 4: Clear Workspace Cache
```bash
# Remove workspace caches
find . -name "*.xcworkspace" -type d -exec rm -rf {}/xcshareddata/IDEWorkspaceChecks.plist \; 2>/dev/null
```

### Step 5: Clean Build Folder (In Xcode)
1. Open `InterviewPrepApp.xcodeproj`
2. Press **⌘⇧K** (Product → Clean Build Folder)
3. Wait for completion

### Step 6: Re-index Project
1. Wait for Xcode to finish indexing (progress bar in top center)
2. Press **⌘B** to build
3. Xcode will treat project as fresh!

---

## 📁 What Gets Cleared

| Location | What It Stores | Safe to Delete? |
|----------|----------------|-----------------|
| `~/Library/Developer/Xcode/DerivedData/` | Build products, indexes, logs | ✅ Yes |
| `*.xcuserstate` | Window layout, cursor position | ✅ Yes |
| `xcuserdata/` | Breakpoints, schemes (local) | ✅ Yes |
| `xcshareddata/` | Shared schemes | ⚠️ Usually keep |
| `project.pbxproj` | Project structure | ❌ Never delete |

---

## 🔍 Verify It Worked

After resetting, check:

1. **File Navigator** - All files show correct paths
2. **Autocomplete** - Works for all source files
3. **Build** - Succeeds without "file not found" errors
4. **Indexes** - Jump to Definition (⌘ + Click) works

---

## 🚨 Nuclear Option: Complete Reset

If normal reset doesn't work, try this:

```bash
# 1. Close Xcode
killall Xcode

# 2. Clear ALL Xcode caches
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Developer/Xcode/Archives/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*
rm -rf ~/Library/Caches/org.swift.swiftpm/*

# 3. Clear project files
cd /path/to/frontend/ios/InterviewPrepApp
rm -rf .build
rm -rf .swiftpm
find . -name "*.xcuserstate" -delete
find . -name "xcuserdata" -type d -exec rm -rf {} +

# 4. Restart Mac (optional but effective)
sudo shutdown -r now
```

---

## 💡 Pro Tips

### Prevent Future Issues

1. **Add to .gitignore:**
   ```
   xcuserdata/
   *.xcuserstate
   DerivedData/
   ```

2. **Use Shared Schemes:**
   - Product → Scheme → Manage Schemes
   - Check "Shared" for main scheme
   - Commit `xcshareddata/xcschemes/`

3. **Regular Cleaning:**
   - Clean Build Folder weekly: **⌘⇧K**
   - Clear Derived Data monthly

### Faster Indexing

1. Close unnecessary projects
2. Disable unnecessary targets
3. Wait for complete indexing before editing

---

## 🆘 Still Having Issues?

If Xcode still shows old paths:

1. **Check Git Status:**
   ```bash
   cd /path/to/frontend
   git status
   ```
   Ensure no old paths are tracked

2. **Search for Hardcoded Paths:**
   ```bash
   cd ios/InterviewPrepApp
   grep -r "old/path" . --include="*.pbxproj"
   ```

3. **Verify File Membership:**
   - Select file in Xcode
   - File Inspector (⌥⌘1)
   - Check "Target Membership"

4. **Re-add Files:**
   - Remove file reference (Delete → Remove Reference)
   - Add back: Right-click → Add Files
   - Ensure "Copy items if needed" is checked

---

## 📚 Related Commands

```bash
# View Xcode caches size
du -sh ~/Library/Developer/Xcode/DerivedData

# List Xcode processes
ps aux | grep Xcode

# Force kill Xcode
killall -9 Xcode

# Clean via xcodebuild
xcodebuild clean -project InterviewPrepApp.xcodeproj -scheme InterviewPrepApp
```

---

**Remember:** After any reset, wait for Xcode to fully re-index before assuming something is broken!



