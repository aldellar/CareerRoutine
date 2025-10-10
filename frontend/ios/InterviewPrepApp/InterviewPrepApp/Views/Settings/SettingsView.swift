//
//  SettingsView.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @StateObject private var weekViewModel = WeekViewModel()
    @StateObject private var prepViewModel = PrepViewModel()
    @State private var showingEditProfile: Bool = false
    @State private var showingResetAlert: Bool = false
    @State private var apiBaseOverride: String = 
        UserDefaults.standard.string(forKey: "api_base") ?? ""
    @State private var healthCheckResult: String?
    @State private var showingHealthCheck = false
    
    var body: some View {
        List {
            // Profile Section
            Section {
                if let profile = appState.userProfile {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(profile.targetRole)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingEditProfile = true
                            }) {
                                Text("Edit")
                                    .font(.body)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Divider()
                        
                        VStack(spacing: 8) {
                            ProfileDetailRow(label: "Stage", value: profile.currentStage.rawValue)
                            ProfileDetailRow(label: "Time Budget", value: String(format: "%.1f hrs/day", profile.timeBudgetHoursPerDay))
                            ProfileDetailRow(label: "Available Days", value: "\(profile.availableDays.count) days/week")
                        }
                    }
                    .padding(.vertical, 8)
                }
            } header: {
                Text("Profile")
            }
            
            // Routine Section
            Section {
                if let routine = appState.currentRoutine {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Plan")
                                .font(.headline)
                            Text("Version \(routine.version)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            regenerateRoutine()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                Text("Regenerate")
                            }
                            .font(.body)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                } else {
                    Button(action: {
                        generateRoutine()
                    }) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Generate Routine")
                        }
                    }
                }
            } header: {
                Text("Weekly Routine")
            }
            
            // Prep Pack Section
            Section {
                if let prepPack = appState.prepPack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Interview Prep Pack")
                                .font(.headline)
                            Text("\(prepPack.topicLadder.count) topics • \(prepPack.resources.count) resources")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            regeneratePrepPack()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                Text("Regenerate")
                            }
                            .font(.body)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                } else {
                    Button(action: {
                        generatePrepPack()
                    }) {
                        HStack {
                            Image(systemName: "book.badge.plus")
                            Text("Generate Prep Pack")
                        }
                    }
                }
            } header: {
                Text("Interview Prep")
            }
            
            // Stats Section
            Section {
                StatRow(label: "Current Streak", value: "\(appState.streakData.currentStreak) days", icon: "flame.fill", color: .orange)
                StatRow(label: "Longest Streak", value: "\(appState.streakData.longestStreak) days", icon: "star.fill", color: .yellow)
                StatRow(label: "Tasks Completed", value: "\(appState.streakData.totalTasksCompleted)", icon: "checkmark.circle.fill", color: .green)
            } header: {
                Text("Statistics")
            }
            
            // Data Management Section
            Section {
                Button(role: .destructive, action: {
                    showingResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Reset All Data")
                    }
                }
            } header: {
                Text("Data")
            } footer: {
                Text("This will delete all your data including profile, routines, and progress. This action cannot be undone.")
                    .font(.caption)
            }
            
            // Developer Tools Section (DEBUG only)
            #if DEBUG
            Section {
                // API Base URL Override
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Base URL Override")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField(
                        "http://localhost:8081",
                        text: $apiBaseOverride
                    )
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .onChange(of: apiBaseOverride) { newValue in
                        UserDefaults.standard.set(
                            newValue,
                            forKey: "api_base"
                        )
                    }
                    
                    Text("Leave empty to use default. Restart app after changing.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                
                // Health Check
                Button(action: checkHealth) {
                    HStack {
                        Image(systemName: "heart.text.square")
                        Text("Ping Health Endpoint")
                        Spacer()
                        if showingHealthCheck {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(showingHealthCheck)
                
                if let result = healthCheckResult {
                    Text(result)
                        .font(.caption)
                        .foregroundColor(
                            result.contains("OK") ? .green : .red
                        )
                }
                
                // Generate with Sample Profile
                Button(action: generateSamplePlan) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("Generate Plan (Sample Profile)")
                    }
                }
                
                Button(action: generateSamplePrep) {
                    HStack {
                        Image(systemName: "book.badge.plus")
                        Text("Generate Prep (Sample Profile)")
                    }
                }
                
                // Load Stub Data
                Button(action: loadStubPlan) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Load Stub Plan Locally")
                    }
                }
                
                Button(action: loadStubPrep) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text("Load Stub Prep Locally")
                    }
                }
            } header: {
                Text("Developer Tools")
            } footer: {
                Text("These tools are only available in DEBUG builds.")
                    .font(.caption)
            }
            #endif
            
            // App Info Section
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("API Base URL")
                    Spacer()
                    Text(APIConfig.baseURL.absoluteString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditProfile) {
            if let profile = appState.userProfile {
                EditProfileView(profile: profile)
            }
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                appState.resetOnboarding()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete all your data? This action cannot be undone.")
        }
    }
    
    private func generateRoutine() {
        guard let profile = appState.userProfile else { return }
        
        let networkService = NetworkService()
        Task {
            do {
                let routine = try await networkService.generateRoutine(profile: profile)
                await MainActor.run {
                    appState.saveRoutine(routine)
                }
            } catch {
                print("Error generating routine: \(error)")
            }
        }
    }
    
    private func regenerateRoutine() {
        appState.regenerateRoutine()
        generateRoutine()
    }
    
    private func generatePrepPack() {
        guard let profile = appState.userProfile else { return }
        
        let networkService = NetworkService()
        Task {
            do {
                let prepPack = try await networkService.generatePrepPack(profile: profile)
                await MainActor.run {
                    appState.savePrepPack(prepPack)
                }
            } catch {
                print("Error generating prep pack: \(error)")
            }
        }
    }
    
    private func regeneratePrepPack() {
        generatePrepPack()
    }
    
    // MARK: - Developer Tools
    
    #if DEBUG
    private func checkHealth() {
        showingHealthCheck = true
        healthCheckResult = nil
        
        Task {
            let apiClient = APIClient()
            let isHealthy = await apiClient.health()
            
            await MainActor.run {
                showingHealthCheck = false
                healthCheckResult = isHealthy 
                    ? "✓ Server is healthy (200 OK)" 
                    : "✗ Server unavailable"
            }
        }
    }
    
    private func generateSamplePlan() {
        guard let profile = appState.userProfile else {
            // Create sample profile if none exists
            let sampleProfile = UserProfile(
                name: "Sample User",
                currentStage: .secondYear,
                targetRole: "iOS Engineer",
                timeBudgetHoursPerDay: 2.0,
                availableDays: [.monday, .tuesday, .wednesday, .thursday, .friday]
            )
            appState.saveUserProfile(sampleProfile)
            weekViewModel.generatePlan(profile: sampleProfile)
            return
        }
        weekViewModel.generatePlan(profile: profile)
    }
    
    private func generateSamplePrep() {
        guard let profile = appState.userProfile else {
            let sampleProfile = UserProfile(
                name: "Sample User",
                currentStage: .secondYear,
                targetRole: "iOS Engineer",
                timeBudgetHoursPerDay: 2.0,
                availableDays: [.monday, .tuesday, .wednesday, .thursday, .friday]
            )
            appState.saveUserProfile(sampleProfile)
            prepViewModel.generatePrep(profile: sampleProfile)
            return
        }
        prepViewModel.generatePrep(profile: profile)
    }
    
    private func loadStubPlan() {
        weekViewModel.loadStubPlan()
        // Reload from storage to update UI
        if let routine = StorageService().loadRoutine() {
            appState.currentRoutine = routine
        }
    }
    
    private func loadStubPrep() {
        prepViewModel.loadStubPrep()
        // Reload from storage to update UI
        if let prepPack = StorageService().loadPrepPack() {
            appState.prepPack = prepPack
        }
    }
    #endif
}

struct ProfileDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(AppState())
    }
}

