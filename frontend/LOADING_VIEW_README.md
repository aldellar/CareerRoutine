# LoadingView - Quick Start Guide

A production-ready, full-screen loading view for your iOS app's onboarding flow.

## ✨ What You Get

- **Dual Progress Indicators**: Circular progress ring + linear progress bar
- **Smart Status Updates**: "Generating your weekly routine…" → "Building your prep plan…" → "Finalizing everything…"
- **Rotating Tips**: 10 motivational tips that fade in/out every 3 seconds
- **Error Handling**: Clean error states with retry and cancel buttons
- **Haptic Feedback**: Success haptic when complete
- **Dark Mode**: Full support for light/dark appearances
- **Accessibility**: Dynamic Type and VoiceOver ready

## 🚀 Quick Integration

### 1. Basic Usage

```swift
import SwiftUI

struct YourView: View {
    @State private var progress: Double = 0.0
    @State private var statusText = "Generating your weekly routine…"
    @State private var errorState: LoadingErrorState?
    
    var body: some View {
        LoadingView(
            progress: progress,
            statusText: statusText,
            errorState: errorState,
            onSuccess: {
                // Navigate to home
                print("Loading complete!")
            },
            onCancel: {
                // Handle cancellation
                print("User cancelled")
            },
            onRetry: {
                // Retry failed operation
                print("Retrying...")
            }
        )
    }
}
```

### 2. Update Progress

```swift
// Instant update
withAnimation {
    progress = 0.33
    statusText = "Building your prep plan…"
}

// Gradual progress (recommended)
func incrementProgress(from start: Double, to end: Double, over duration: TimeInterval) {
    let steps = 20
    let increment = (end - start) / Double(steps)
    let delay = duration / Double(steps)
    
    for i in 1...steps {
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay * Double(i))) {
            progress += increment
        }
    }
}
```

### 3. Show Errors

```swift
// Predefined errors
errorState = .network()      // "Connection Issue"
errorState = .timeout()      // "Request Timed Out"
errorState = .serverError()  // "Server Error"
errorState = .generic()      // "Something Went Wrong"

// Custom error
errorState = .custom(
    title: "Profile Incomplete",
    message: "Please complete your profile before continuing."
)

// Clear error
errorState = nil
```

## 📁 Files

- **`LoadingView.swift`** - Main component (production-ready)
- **`LoadingViewExample.swift`** - Integration patterns & coordinator example
- **`docs/loading-view-guide.md`** - Comprehensive documentation

## 🎯 Integration Points

### Option A: In OnboardingViewModel (Recommended)

Add to your existing `OnboardingViewModel`:

```swift
class OnboardingViewModel: ObservableObject {
    @Published var isGeneratingPlan = false
    @Published var loadingProgress: Double = 0.0
    @Published var loadingStatus = ""
    @Published var loadingError: LoadingErrorState?
    
    func completeOnboarding(appState: AppState) {
        isGeneratingPlan = true
        loadingProgress = 0.1
        loadingStatus = "Generating your weekly routine…"
        
        // Call your API
        NetworkService.shared.generateRoutine { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadingProgress = 0.33
                    self.generatePrepPack()
                case .failure:
                    self.loadingError = .timeout()
                }
            }
        }
    }
}
```

In your `OnboardingView`:

```swift
if viewModel.isGeneratingPlan {
    LoadingView(
        progress: viewModel.loadingProgress,
        statusText: viewModel.loadingStatus,
        errorState: viewModel.loadingError,
        onSuccess: { appState.hasCompletedOnboarding = true },
        onCancel: { viewModel.isGeneratingPlan = false },
        onRetry: { viewModel.completeOnboarding(appState: appState) }
    )
}
```

### Option B: Standalone Coordinator

See `LoadingViewExample.swift` for a complete implementation using `LoadingCoordinator`.

## 🎨 Customization

### Change Tips

Edit `LoadingView.swift`:

```swift
private let motivationalTips = [
    "Your custom tip here",
    "Another helpful message",
    // ...
]
```

### Change Colors

```swift
// In LoadingView.swift, replace Color.blue with your brand color
Circle()
    .stroke(Color.purple, lineWidth: 12)

Button(action: ...) {
    Text("Retry")
}
.background(Color.purple)  // was Color.blue
```

### Change Progress Steps

```swift
progressStepIndicator(step: 1, label: "Step 1", ...)
progressStepIndicator(step: 2, label: "Step 2", ...)
progressStepIndicator(step: 3, label: "Step 3", ...)
```

## 🧪 Testing

### In Xcode Previews

```swift
#Preview("Loading") {
    // Simulates successful loading
}

#Preview("Error State") {
    // Simulates timeout error
}
```

### Manual Testing Checklist

- [ ] Progress flows smoothly 0% → 33% → 66% → 100%
- [ ] Tips rotate every ~3 seconds
- [ ] Error state appears on network failure
- [ ] Retry button restarts the process
- [ ] Cancel button navigates away
- [ ] Dark mode colors look good
- [ ] Large text sizes don't break layout
- [ ] VoiceOver announces progress correctly

## 📊 Progress Stages

| Range | Stage | Status Text |
|-------|-------|-------------|
| 0.00 - 0.33 | Generating routine | "Generating your weekly routine…" |
| 0.33 - 0.66 | Generating prep pack | "Building your prep plan…" |
| 0.66 - 1.00 | Saving locally | "Finalizing everything…" |

When progress reaches `1.0`, the view automatically:
1. Triggers haptic feedback
2. Waits 0.5 seconds
3. Calls `onSuccess()`

## ⚠️ Important Notes

### Do's ✅

- Update progress gradually for smooth animations
- Always set error state on main thread: `DispatchQueue.main.async { errorState = ... }`
- Wrap progress updates in `withAnimation`
- Test with slow/flaky network conditions
- Keep status text concise (< 50 characters)

### Don'ts ❌

- Don't show for operations < 1 second (use simple spinner instead)
- Don't let progress go backward
- Don't use technical error messages
- Don't forget to implement all three callbacks
- Don't hide the cancel button

## 🐛 Troubleshooting

**Progress doesn't animate smoothly**
```swift
withAnimation(.easeInOut(duration: 0.5)) {
    progress = 0.5
}
```

**Tips don't rotate**
- Ensure LoadingView is visible when rendered
- Timer starts on `onAppear`

**Error doesn't show**
```swift
DispatchQueue.main.async {
    errorState = .timeout()
}
```

**Success callback doesn't fire**
- Check that progress reaches exactly `1.0`
- Verify callback is set (not nil)

## 📚 Full Documentation

See `docs/loading-view-guide.md` for:
- Detailed API reference
- Advanced integration patterns
- Accessibility guidelines
- Performance optimization
- Complete troubleshooting guide

## 🎬 Next Steps

1. ✅ Files added to Xcode project
2. ⬜ Integrate with your `OnboardingViewModel`
3. ⬜ Test with your actual API endpoints
4. ⬜ Customize tips and colors to match your brand
5. ⬜ Test with VoiceOver and Dynamic Type

## 💡 Example Flow

```swift
// 1. User completes onboarding
// 2. Show LoadingView with progress = 0

// 3. Call backend API #1 (generate routine)
progress = 0.1 → 0.33
statusText = "Generating your weekly routine…"

// 4. On success, call API #2 (generate prep pack)
progress = 0.33 → 0.66
statusText = "Building your prep plan…"

// 5. Save to local storage
progress = 0.66 → 1.0
statusText = "Finalizing everything…"

// 6. LoadingView auto-calls onSuccess()
// 7. Navigate to home screen
```

## 📞 Support

Questions? Check:
1. This README for quick answers
2. `LoadingViewExample.swift` for integration patterns
3. `docs/loading-view-guide.md` for comprehensive docs
4. Xcode previews to see it in action

---

**Built with ❤️ for the InterviewPrepApp iOS team**

