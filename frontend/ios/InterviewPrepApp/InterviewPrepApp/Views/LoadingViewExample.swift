//
//  LoadingViewExample.swift
//  InterviewPrepApp
//
//  Created on 10/10/2025.
//  Example integration of LoadingView with networking and navigation
//

import SwiftUI

// MARK: - Example Integration
/// This example shows how to integrate LoadingView with your onboarding
/// flow and backend API calls. Copy this pattern to your OnboardingViewModel
/// or create a dedicated loading coordinator.

struct LoadingCoordinatorExample: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var coordinator = LoadingCoordinator()
    
    var body: some View {
        if coordinator.isLoading {
            LoadingView(
                progress: coordinator.progress,
                statusText: coordinator.statusText,
                errorState: coordinator.errorState,
                onSuccess: {
                    // Navigate to main home screen
                    appState.hasCompletedOnboarding = true
                },
                onCancel: {
                    // Navigate back to onboarding or home
                    coordinator.reset()
                },
                onRetry: {
                    // Retry the failed operation
                    coordinator.retryCurrentOperation()
                }
            )
        } else {
            // Your normal view
            Text("Content View")
        }
    }
}

// MARK: - Loading Coordinator
/// Manages the loading process, progress tracking, and error handling
class LoadingCoordinator: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var progress: Double = 0.0
    @Published var statusText: String = ""
    @Published var errorState: LoadingErrorState?
    
    private var currentStep: LoadingStep = .routine
    private var userProfile: UserProfile?
    private var appState: AppState?
    private var generatedRoutine: Routine?
    private var generatedPrepPack: PrepPack?
    private var progressTimer: Timer?
    private var targetProgress: Double = 0.0
    private var hasStarted: Bool = false
    
    enum LoadingStep {
        case routine
        case prepPack
        case saving
    }
    
    // MARK: - Public Methods
    
    /// Start the loading process with user profile
    func startLoading(with profile: UserProfile, appState: AppState) {
        // Prevent multiple starts
        guard !hasStarted else {
            print("⚠️ Loading already started, ignoring duplicate call")
            return
        }
        
        hasStarted = true
        self.userProfile = profile
        self.appState = appState
        isLoading = true
        errorState = nil
        currentStep = .routine
        
        print("🚀 ========================================")
        print("🚀 Loading coordinator started")
        print("🚀 User: \(profile.name)")
        print("🚀 Target Role: \(profile.targetRole)")
        print("🚀 Estimated total time: ~19 seconds")
        print("🚀 Steps: 1) Routine (~8s) → 2) Prep Pack (~8s) → 3) Save (~2s)")
        print("🚀 ========================================")
        
        generateRoutine()
    }
    
    /// Reset the loading state
    func reset() {
        stopProgressSimulation()
        isLoading = false
        progress = 0.0
        errorState = nil
        currentStep = .routine
        generatedRoutine = nil
        generatedPrepPack = nil
        hasStarted = false
    }
    
    /// Retry the current failed operation
    func retryCurrentOperation() {
        errorState = nil
        hasStarted = false  // Allow restart
        
        switch currentStep {
        case .routine:
            hasStarted = true
            generateRoutine()
        case .prepPack:
            hasStarted = true
            generatePrepPack()
        case .saving:
            hasStarted = true
            saveLocally()
        }
    }
    
    // MARK: - Private Methods
    
    private func generateRoutine() {
        guard let profile = userProfile else {
            print("❌ No user profile available for routine generation")
            return
        }
        
        print("📝 User profile available: \(profile.name)")
        currentStep = .routine
        updateProgress(0.05, status: "Generating your weekly routine…")
        
        // Gradual progress simulation (matching the ~8 second API call)
        startProgressSimulation(from: 0.05, to: 0.32, duration: 8.0)
        
        Task { @MainActor in
            do {
                print("🔵 Starting routine generation...")
                let routine = try await NetworkService.shared.generateRoutine(profile: profile)
                self.generatedRoutine = routine
                print("✅ Routine generated successfully")
                
                self.stopProgressSimulation()
                self.updateProgress(0.33, status: "Routine created!")
                
                print("⏳ Waiting 0.5s before starting prep pack generation...")
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                print("➡️ Moving to prep pack generation")
                self.generatePrepPack()
            } catch {
                print("❌ Routine generation failed: \(error)")
                self.stopProgressSimulation()
                self.handleError(error)
            }
        }
    }
    
    private func generatePrepPack() {
        guard let profile = userProfile else {
            print("❌ No user profile available for prep pack generation")
            return
        }
        
        print("📝 User profile available for prep pack: \(profile.name)")
        currentStep = .prepPack
        updateProgress(0.35, status: "Building your prep plan…")
        
        // Gradual progress simulation (matching the ~8 second API call)
        startProgressSimulation(from: 0.35, to: 0.65, duration: 8.0)
        
        Task { @MainActor in
            do {
                print("🔵 Starting prep pack generation...")
                let prepPack = try await NetworkService.shared.generatePrepPack(profile: profile)
                self.generatedPrepPack = prepPack
                print("✅ Prep pack generated successfully")
                
                self.stopProgressSimulation()
                self.updateProgress(0.66, status: "Prep pack ready!")
                
                print("⏳ Waiting 0.5s before saving locally...")
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                print("➡️ Moving to save locally")
                self.saveLocally()
            } catch {
                print("❌ Prep pack generation failed: \(error)")
                self.stopProgressSimulation()
                self.handleError(error)
            }
        }
    }
    
    private func saveLocally() {
        currentStep = .saving
        updateProgress(0.70, status: "Finalizing everything…")
        
        print("💾 Saving content locally...")
        
        // Validate that we have both routine and prep pack before saving
        guard generatedRoutine != nil else {
            print("❌ ERROR: No routine was generated!")
            errorState = .custom(title: "Generation Error", message: "Failed to generate routine. Please try again.")
            return
        }
        
        guard generatedPrepPack != nil else {
            print("❌ ERROR: No prep pack was generated!")
            errorState = .custom(title: "Generation Error", message: "Failed to generate prep pack. Please try again.")
            return
        }
        
        // Gradual progress simulation for save
        startProgressSimulation(from: 0.70, to: 0.98, duration: 2.5)
        
        Task { @MainActor in
            // Wait for save animation
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            self.stopProgressSimulation()
            
            // Save the generated content to AppState
            if let routine = self.generatedRoutine {
                self.appState?.saveRoutine(routine)
                print("✅ Routine saved to AppState")
            }
            
            if let prepPack = self.generatedPrepPack {
                self.appState?.savePrepPack(prepPack)
                print("✅ Prep pack saved to AppState")
            }
            
            // Final validation before completing
            print("📝 Final validation:")
            print("   - Routine: \(self.generatedRoutine != nil ? "✅" : "❌")")
            print("   - Prep Pack: \(self.generatedPrepPack != nil ? "✅" : "❌")")
            
            self.updateProgress(1.0, status: "All set!")
            print("🎉 Loading complete! Total time: ~19 seconds")
            // LoadingView will automatically call onSuccess when progress
            // reaches 1.0
        }
    }
    
    private func updateProgress(_ value: Double, status: String) {
        print("📊 Progress update: \(Int(value * 100))% - \(status)")
        withAnimation(.easeInOut(duration: 0.3)) {
            self.progress = value
            self.statusText = status
        }
    }
    
    private func startProgressSimulation(from start: Double, to target: Double, duration: TimeInterval) {
        stopProgressSimulation()
        targetProgress = target
        progress = start
        
        print("🎯 Starting progress simulation: \(start) → \(target) over \(duration)s")
        
        // Update progress smoothly every 0.2 seconds
        let updateInterval: TimeInterval = 0.2
        let totalSteps = duration / updateInterval
        let increment = (target - start) / totalSteps
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Safety check: don't go beyond target or 0.95 (reserve 0.95-1.0 for final completion)
                let maxProgress = min(self.targetProgress, 0.95)
                let newProgress = min(self.progress + increment, maxProgress)
                
                if self.progress < maxProgress {
                    withAnimation(.linear(duration: updateInterval)) {
                        self.progress = newProgress
                    }
                } else {
                    self.stopProgressSimulation()
                }
            }
        }
    }
    
    private func stopProgressSimulation() {
        if progressTimer != nil {
            print("⏹️ Stopping progress simulation")
        }
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func handleError(_ error: Error) {
        // Map error to LoadingErrorState
        if let apiError = error as? APIError {
            switch apiError {
            case .networkUnavailable:
                errorState = .network()
            case .timeout:
                errorState = .timeout()
            case .server:
                errorState = .serverError()
            default:
                errorState = .generic()
            }
        } else {
            errorState = .custom(
                title: "Error",
                message: error.localizedDescription
            )
        }
    }
}

// MARK: - NetworkService Extension (Example)
/// The NetworkService already has async methods for generateRoutine and generatePrepPack
/// No extension needed - the actual implementation uses async/await pattern

// MARK: - Integration with OnboardingViewModel
/// Add this to your OnboardingViewModel or create a new loading flow
///
/// Example usage in OnboardingViewModel:
///
/// ```swift
/// class OnboardingViewModel: ObservableObject {
///     @Published var showLoadingView = false
///     @Published var loadingCoordinator = LoadingCoordinator()
///
///     func completeOnboarding(appState: AppState) {
///         let profile = createUserProfile()
///         showLoadingView = true
///         loadingCoordinator.startLoading(with: profile, appState: appState)
///     }
/// }
/// ```
///
/// Then in your OnboardingView:
///
/// ```swift
/// if viewModel.showLoadingView {
///     LoadingView(
///         progress: viewModel.loadingCoordinator.progress,
///         statusText: viewModel.loadingCoordinator.statusText,
///         errorState: viewModel.loadingCoordinator.errorState,
///         onSuccess: {
///             appState.hasCompletedOnboarding = true
///         },
///         onCancel: {
///             viewModel.showLoadingView = false
///             viewModel.loadingCoordinator.reset()
///         },
///         onRetry: {
///             viewModel.loadingCoordinator.retryCurrentOperation()
///         }
///     )
/// }
/// ```

// MARK: - Preview
#Preview {
    LoadingCoordinatorExample()
        .environmentObject(AppState())
}

