# Regeneration Loading Implementation

## Summary

Added a full-screen loading view with progress tracking for regenerating routines and prep packs in the Settings view.

## Changes Made

### 1. SettingsView.swift

#### Added State Variables:
- `@State private var isRegenerating: Bool` - Controls when loading screen is shown
- `@State private var regenerationProgress: Double` - Tracks progress (0.0 to 1.0)
- `@State private var regenerationStatus: String` - Status message to display
- `@State private var regenerationError: LoadingErrorState?` - Error state if regeneration fails
- `@State private var regenerationType: RegenerationType` - Whether regenerating routine or prep pack

#### Modified Functions:
- `regenerateRoutine()` - Now shows loading screen and calls `startRegeneration(type: .routine)`
- `regeneratePrepPack()` - Now shows loading screen and calls `startRegeneration(type: .prepPack)`

#### New Function:
- `startRegeneration(type:)` - Orchestrates the regeneration process with progress updates

#### Added UI:
- Full screen loading view that appears when `isRegenerating` is true
- Shows progress bar, status messages, and error handling
- User can retry on error or cancel

## How It Works

### For Routine Regeneration:
1. User taps "Regenerate" for routine
2. Loading screen appears with 0% progress
3. Progress updates:
   - 20% - "Connecting to server..."
   - 40% - "Generating weekly schedule..."
   - 70% - "Applying time allocations..."
   - 90% - "Finalizing plan..."
   - 100% - "Complete!"
4. Loading screen dismisses automatically when complete

### For Prep Pack Regeneration:
1. User taps "Regenerate" for prep pack
2. Loading screen appears with 0% progress
3. Progress updates:
   - 20% - "Connecting to server..."
   - 40% - "Generating prep topics..."
   - 70% - "Curating resources..."
   - 90% - "Finalizing prep pack..."
   - 100% - "Complete!"
4. Loading screen dismisses automatically when complete

### Error Handling:
- If an error occurs, the loading screen shows an error state
- User can:
  - **Retry** - Restarts the regeneration process
  - **Cancel** - Dismisses loading screen and returns to settings

## Benefits

1. **Better UX**: Users get visual feedback during regeneration
2. **Error Handling**: Users can retry if something goes wrong
3. **Consistent**: Same loading experience as onboarding
4. **Informative**: Users see what's happening at each step

## Testing

To test:
1. Open Settings
2. Tap "Regenerate" under Weekly Routine or Interview Prep
3. Observe loading screen with progress updates
4. Test error handling by disconnecting from network
5. Test retry functionality


