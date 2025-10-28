//
//  LoadingView.swift
//  InterviewPrepApp
//
//  Created on 10/10/2025.
//  Full-screen loading view with progress tracking and error handling
//

import SwiftUI

struct LoadingView: View {
    // MARK: - State
    @State private var currentTipIndex: Int = 0
    @State private var tipOpacity: Double = 1.0
    @State private var timer: Timer?
    @State private var showError: Bool = false
    
    // MARK: - Properties
    let progress: Double
    let statusText: String
    let errorState: LoadingErrorState?
    let onSuccess: () -> Void
    let onCancel: () -> Void
    let onRetry: () -> Void
    
    // Dynamic step labels
    let stepLabels: (String, String, String)
    
    init(
        progress: Double,
        statusText: String,
        errorState: LoadingErrorState?,
        onSuccess: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        onRetry: @escaping () -> Void,
        stepLabels: (String, String, String) = ("Step 1", "Step 2", "Step 3")
    ) {
        self.progress = progress
        self.statusText = statusText
        self.errorState = errorState
        self.onSuccess = onSuccess
        self.onCancel = onCancel
        self.onRetry = onRetry
        self.stepLabels = stepLabels
    }
    
    private let motivationalTips = [
        "Pro tip: Stay consistent — small progress compounds.",
        "Focus on understanding, not just solving.",
        "Break down complex problems into smaller parts.",
        "Practice explaining your thought process aloud.",
        "Review your mistakes — they're your best teachers.",
        "Build projects to reinforce what you learn.",
        "Consistent daily practice beats cramming.",
        "Every expert was once a beginner. Keep going!",
        "Take breaks to let your brain consolidate learning.",
        "Ask 'why' at each step to deepen understanding."
    ]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if let error = errorState {
                // Error State
                errorView(error)
                    .transition(.opacity.combined(with: .scale))
            } else {
                // Loading State
                loadingContent
                    .transition(.opacity)
            }
        }
        .onAppear {
            startTipRotation()
        }
        .onDisappear {
            stopTipRotation()
        }
        .onChange(of: errorState) { newError in
            withAnimation(.easeInOut(duration: 0.3)) {
                showError = newError != nil
            }
        }
        .onChange(of: progress) { newProgress in
            if newProgress >= 1.0 {
                provideHapticFeedback()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onSuccess()
                }
            }
        }
    }
    
    // MARK: - Loading Content
    private var loadingContent: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Main content
            VStack(spacing: 32) {
                // Circular progress indicator
                ZStack {
                    Circle()
                        .stroke(
                            Color.blue.opacity(0.2),
                            lineWidth: 12
                        )
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.blue,
                            style: StrokeStyle(
                                lineWidth: 12,
                                lineCap: .round
                            )
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(
                            .easeInOut(duration: 0.5),
                            value: progress
                        )
                    
                    // Progress percentage
                    Text("\(Int(progress * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 8)
                
                // Status text
                Text(statusText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .animation(.easeInOut, value: statusText)
                
                // Progress bar (linear)
                VStack(spacing: 8) {
                    ProgressView(value: progress, total: 1.0)
                        .tint(.blue)
                        .frame(maxWidth: 280)
                    
                    HStack(spacing: 4) {
                        progressStepIndicator(
                            step: 1,
                            label: stepLabels.0,
                            isActive: progress >= 0 && progress < 0.33
                        )
                        progressStepIndicator(
                            step: 2,
                            label: stepLabels.1,
                            isActive: progress >= 0.33 && progress < 0.66
                        )
                        progressStepIndicator(
                            step: 3,
                            label: stepLabels.2,
                            isActive: progress >= 0.66
                        )
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            
            Spacer()
            
            // Motivational tip section
            VStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text("Did you know?")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                Text(motivationalTips[currentTipIndex])
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 40)
                    .opacity(tipOpacity)
                    .animation(
                        .easeInOut(duration: 0.4),
                        value: tipOpacity
                    )
            }
            .padding(.bottom, 48)
        }
    }
    
    // MARK: - Progress Step Indicator
    private func progressStepIndicator(
        step: Int,
        label: String,
        isActive: Bool
    ) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(isActive ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Error View
    private func errorView(_ error: LoadingErrorState) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 72))
                .foregroundColor(.orange)
                .padding(.bottom, 16)
            
            // Error title
            Text(error.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Error message
            Text(error.message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .lineLimit(4)
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        onRetry()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry")
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    withAnimation {
                        onCancel()
                    }
                }) {
                    Text("Cancel")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
    
    // MARK: - Helper Methods
    private func startTipRotation() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 8.0,
            repeats: true
        ) { _ in
            // Fade out
            withAnimation(.easeOut(duration: 0.3)) {
                tipOpacity = 0.0
            }
            
            // Change tip and fade in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentTipIndex = (currentTipIndex + 1)
                    % motivationalTips.count
                
                withAnimation(.easeIn(duration: 0.3)) {
                    tipOpacity = 1.0
                }
            }
        }
    }
    
    private func stopTipRotation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func provideHapticFeedback() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}

// MARK: - Error State Model
struct LoadingErrorState: Equatable {
    let title: String
    let message: String
    
    static func network() -> LoadingErrorState {
        LoadingErrorState(
            title: "Connection Issue",
            message: "Please check your internet connection and try again."
        )
    }
    
    static func timeout() -> LoadingErrorState {
        LoadingErrorState(
            title: "Request Timed Out",
            message: "The request took longer than expected. Please try again."
        )
    }
    
    static func serverError() -> LoadingErrorState {
        LoadingErrorState(
            title: "Server Error",
            message: "Something went wrong on our end. Please try again later."
        )
    }
    
    static func custom(title: String, message: String) -> LoadingErrorState {
        LoadingErrorState(title: title, message: message)
    }
    
    static func generic() -> LoadingErrorState {
        LoadingErrorState(
            title: "Something Went Wrong",
            message: "We couldn't complete your request. Please try again."
        )
    }
}

// MARK: - Preview
#Preview("Loading") {
    LoadingViewPreviewWrapper(simulateError: false)
}

#Preview("Error State") {
    LoadingViewPreviewWrapper(simulateError: true)
}

// MARK: - Preview Wrapper
private struct LoadingViewPreviewWrapper: View {
    @State private var progress: Double = 0.0
    @State private var statusText: String = "Generating your weekly routine…"
    @State private var errorState: LoadingErrorState?
    let simulateError: Bool
    
    var body: some View {
        LoadingView(
            progress: progress,
            statusText: statusText,
            errorState: errorState,
            onSuccess: {
                print("Success!")
            },
            onCancel: {
                print("Cancelled")
                progress = 0.0
                errorState = nil
                statusText = "Generating your weekly routine…"
            },
            onRetry: {
                print("Retrying...")
                errorState = nil
                progress = 0.0
                statusText = "Generating your weekly routine…"
                startSimulation()
            }
        )
        .onAppear {
            startSimulation()
        }
    }
    
    private func startSimulation() {
        if simulateError {
            // Simulate progress then error
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    progress = 0.5
                    statusText = "Building your prep plan…"
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    errorState = .timeout()
                }
            }
        } else {
            // Simulate successful loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    progress = 0.33
                    statusText = "Generating your weekly routine…"
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    progress = 0.66
                    statusText = "Building your prep plan…"
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                withAnimation {
                    progress = 1.0
                    statusText = "Finalizing everything…"
                }
            }
        }
    }
}

