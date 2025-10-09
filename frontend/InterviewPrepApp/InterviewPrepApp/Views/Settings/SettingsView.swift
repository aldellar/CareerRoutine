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
    @State private var showingEditProfile: Bool = false
    @State private var showingResetAlert: Bool = false
    
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
                            ProfileDetailRow(label: "Time Budget", value: "\(profile.timeBudgetHoursPerDay, specifier: "%.1f") hrs/day")
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
            
            // App Info Section
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
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

