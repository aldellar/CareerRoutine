//
//  ContentView.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var loadingCoordinator = LoadingCoordinator()
    
    var body: some View {
        Group {
            if appState.isGeneratingInitialContent {
                LoadingView(
                    progress: loadingCoordinator.progress,
                    statusText: loadingCoordinator.statusText,
                    errorState: loadingCoordinator.errorState,
                    onSuccess: {
                        // Mark onboarding as complete and go to home
                        appState.isGeneratingInitialContent = false
                        appState.completeOnboarding()
                        loadingCoordinator.reset()
                    },
                    onCancel: {
                        // Go back to onboarding
                        appState.isGeneratingInitialContent = false
                        loadingCoordinator.reset()
                    },
                    onRetry: {
                        // Retry the failed operation
                        loadingCoordinator.retryCurrentOperation()
                    }
                )
                .onAppear {
                    if let profile = appState.userProfile {
                        loadingCoordinator.startLoading(with: profile, appState: appState)
                    }
                }
            } else if appState.hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

