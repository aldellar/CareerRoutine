# 🔧 Fix Xcode "Cannot Find" Errors

## The Problem
Files exist on disk but Xcode doesn't know about them yet.

## The Solution (5 minutes)

### ✅ Xcode is now open! Follow these steps:

---

## Step 1: Locate the Project Navigator

In Xcode's **left sidebar**, you should see:

```
▼ InterviewPrepApp (blue icon at top)
  ▼ InterviewPrepApp (yellow folder)
    ▼ Models
    ▼ Views
    ▼ Services
    ▼ Utils
    ▶ Assets.xcassets
    ▶ ContentView.swift
    ▶ Info.plist
    ...
```

---

## Step 2: Add the Missing Folders

1. **RIGHT-CLICK** on the **InterviewPrepApp** folder (the yellow one)
2. Select **"Add Files to 'InterviewPrepApp'..."**

![Right-click menu](https://i.imgur.com/example.png)

---

## Step 3: Navigate to the Folders

In the file picker that opens:

1. You should already be in: `InterviewPrepApp/InterviewPrepApp/`
2. If not, navigate there
3. You'll see these folders:
   - ✅ `Networking` (blue folder)
   - ✅ `ViewModels` (blue folder)
   - Models, Views, Services, Utils, etc.

---

## Step 4: Select the Folders

1. **Click** on the `Networking` folder
2. Hold **⌘ (Command)** and **click** on the `ViewModels` folder
3. Both should be highlighted/selected

---

## Step 5: Configure Import Options

At the bottom of the dialog, make sure:

- ✅ **"Create groups"** is selected (NOT "Create folder references")
- ✅ **"InterviewPrepApp"** target is checked
- ⬜ **"Copy items if needed"** is UNchecked (they're already there!)

---

## Step 6: Click "Add"

Click the **"Add"** button (bottom right)

---

## Step 7: Add Utils Files (if needed)

If `Loadable.swift` and `AlertState.swift` aren't showing in the Utils folder:

1. **Right-click** the **Utils** folder
2. Select **"Add Files to 'InterviewPrepApp'..."**
3. Navigate to the **Utils** folder
4. Select **`Loadable.swift`** (⌘-click to select multiple)
5. Also select **`AlertState.swift`**
6. Click **"Add"**

---

## Step 8: Clean and Build

1. Press **⌘⇧K** (Command + Shift + K) to **Clean Build Folder**
2. Press **⌘B** (Command + B) to **Build**
3. ✅ **Errors should be gone!**

---

## ✅ After Adding, You Should See:

```
▼ InterviewPrepApp
  ▼ Models
  ▼ Views
  ▼ Services
  ▼ Utils
      ColorExtensions.swift
      DateExtensions.swift
      Loadable.swift          ← NEW
      AlertState.swift        ← NEW
  ▼ Networking               ← NEW FOLDER
      APIClient.swift
      APIError.swift
      APIError+Display.swift
      Config.swift
      Reachability.swift
      ▼ Models
          APIProfile.swift
          APIPlan.swift
          APIPrep.swift
  ▼ ViewModels              ← NEW FOLDER
      WeekViewModel.swift
      PrepViewModel.swift
      RerollViewModel.swift
```

---

## 🎯 Quick Verification

After building, check:

1. **No red errors** in the code
2. **Build Succeeded** message in Xcode
3. All files show with **no warning icons**

---

## ❌ If Errors Persist

### "Cannot find X in scope"
- Select the file showing the error
- Press **⌘⌥1** (File Inspector)
- Under **Target Membership**, check **InterviewPrepApp**

### "Ambiguous use of X"
- You might have duplicate files
- Search for the file name (⌘⇧O)
- Remove duplicates if any

### Still issues?
1. Clean Build Folder: **⌘⇧K**
2. Delete Derived Data:
   - Xcode → Settings → Locations → Derived Data
   - Click the arrow icon
   - Delete the folder
3. Restart Xcode
4. Build again: **⌘B**

---

## 🚀 Ready to Test!

Once the build succeeds:

1. **Run in Simulator**: Press **⌘R**
2. **Test Developer Tools**: Settings → Developer Tools
3. **Ping Backend**: Tap "Ping Health Endpoint"

---

## 📊 Files Added

| Folder | Files |
|--------|-------|
| Networking/ | 5 files + 3 in Models/ |
| ViewModels/ | 3 files |
| Utils/ | 2 new files (total 4) |
| **Total** | **13 new files** |

All files are **already on disk** in the correct location.  
They just need to be **registered** in the Xcode project.

---

**You got this! 🎉**

