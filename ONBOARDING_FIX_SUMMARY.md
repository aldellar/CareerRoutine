# Onboarding Flow Fix Summary

## Issues Fixed

### 1. No Automatic Schedule Generation After Onboarding
**Problem**: After completing onboarding, no API calls were made to generate a weekly plan or prep pack.

**Solution**: Updated `OnboardingViewModel` to automatically trigger both API calls after the user completes onboarding.

### 2. No Loading State During Generation
**Problem**: Users didn't see any feedback that their plan was being generated.

**Solution**: Added a loading screen in `OnboardingView` that displays while the API calls are in progress, with appropriate messaging and error handling.

### 3. Prep Pack Not Displaying After Manual Generation
**Problem**: When manually generating a prep pack, it said "created successfully" but nothing was displayed.

**Solution**: Updated `PrepViewModel.generatePrep()` to accept an optional `AppState` parameter and update it after successful generation, ensuring the UI reflects the changes.

## Files Modified

### 1. OnboardingViewModel.swift
- Made the class `@MainActor` to support async operations
- Added `isGeneratingPlan` and `generationError` published properties
- Added `apiClient` and `storage` dependencies via initializer
- Implemented `generateInitialContent()` method that:
  - Generates both weekly routine and prep pack in parallel
  - Saves results to both storage and AppState
  - Handles errors gracefully
- Added conversion helper methods:
  - `convertToRoutine()` - converts APIPlan to Routine
  - `convertToPrepPack()` - converts APIPrep to PrepPack
  - `weekdayFrom()` - converts day strings to Weekday enum
  - `inferCategory()` - infers task category from label
  - `inferResourceType()` - infers resource type from title

### 2. OnboardingView.swift
- Added conditional rendering based on `viewModel.isGeneratingPlan`
- When generating, displays:
  - Progress indicator
  - Informative message about what's happening
  - Error handling UI with "Try Again" and "Skip for Now" options
- Maintains existing step-by-step onboarding flow when not generating

### 3. PrepViewModel.swift
- Updated `generatePrep()` to accept optional `appState` parameter
- After successful generation, now updates `appState.savePrepPack()` in addition to local storage
- Ensures UI reflects the newly generated prep pack immediately

### 4. PrepView.swift
- Updated `generatePrepPack()` call to pass `appState` to the view model
- Ensures prep pack updates are reflected in both the view model and app state

## Technical Details

### Async/Await Implementation
- Used Swift's structured concurrency with `async let` to generate both plan and prep pack in parallel
- This reduces the total wait time for users compared to sequential generation

### Error Handling
- Catches `APIError` specifically for better error messages
- Falls back to generic error for unexpected failures
- Provides user-friendly retry mechanism

### State Management
- All data is saved in three places:
  1. Local storage (via `StorageService`) - for persistence
  2. View model state (via `Loadable` enum) - for view-specific state
  3. App state (via `AppState`) - for global app state
- This ensures consistency across all parts of the app

## User Experience Flow

### Before Fix:
1. User completes onboarding
2. Redirected to home screen
3. No plan or prep pack exists
4. User must manually trigger generation
5. Manual generation appears successful but doesn't display

### After Fix:
1. User completes onboarding
2. Loading screen appears with message "Setting up your interview prep plan..."
3. Both weekly routine and prep pack are generated (takes ~10-30 seconds depending on API)
4. If successful: User sees home screen with full schedule and prep materials
5. If error: User sees error message with options to "Try Again" or "Skip for Now"
6. Manual generation now properly updates the UI

## Testing Recommendations

1. **Happy Path**: Complete onboarding with good network connection
   - Verify loading screen appears
   - Verify both plan and prep pack are generated
   - Verify user sees populated WeekView and PrepView

2. **Network Error**: Complete onboarding with network disabled
   - Verify error message appears
   - Verify "Try Again" retries the generation
   - Verify "Skip for Now" allows proceeding without generation

3. **Manual Generation**: After onboarding, manually generate prep pack
   - Verify loading state shows
   - Verify success banner appears
   - Verify prep pack is immediately visible in UI

4. **Parallel Generation**: Monitor backend logs
   - Verify both API calls happen simultaneously
   - Verify total time is optimal (not sequential)

## Backend Considerations

The frontend now makes two API calls simultaneously after onboarding:
- `POST /generate/routine` - generates weekly schedule
- `POST /generate/prep` - generates prep pack materials

Ensure the backend can handle concurrent requests from the same user without issues.

## Future Improvements

1. **Progress Indicator**: Show more detailed progress (e.g., "Generating weekly routine... Done! Generating prep pack...")
2. **Partial Success**: Handle case where one API call succeeds and one fails
3. **Background Generation**: Allow user to explore app while generation continues
4. **Caching**: Implement intelligent caching to avoid regenerating unnecessarily

