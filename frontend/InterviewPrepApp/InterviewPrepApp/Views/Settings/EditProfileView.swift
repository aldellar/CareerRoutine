//
//  EditProfileView.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var stage: AcademicStage
    @State private var targetRole: String
    @State private var hoursPerDay: Double
    @State private var availableDays: Set<Weekday>
    @State private var preferredTools: [String]
    @State private var newTool: String = ""
    
    let suggestedTools = ["LeetCode", "HackerRank", "Pramp", "Cracking the Coding Interview", "System Design Primer", "Swift Playgrounds"]
    
    init(profile: UserProfile) {
        _name = State(initialValue: profile.name)
        _stage = State(initialValue: profile.currentStage)
        _targetRole = State(initialValue: profile.targetRole)
        _hoursPerDay = State(initialValue: profile.timeBudgetHoursPerDay)
        _availableDays = State(initialValue: profile.availableDays)
        _preferredTools = State(initialValue: profile.preferredTools)
    }
    
    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !targetRole.trimmingCharacters(in: .whitespaces).isEmpty &&
        !availableDays.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    
                    Picker("Current Stage", selection: $stage) {
                        ForEach(AcademicStage.allCases, id: \.self) { stage in
                            Text(stage.rawValue).tag(stage)
                        }
                    }
                    
                    TextField("Target Role", text: $targetRole)
                } header: {
                    Text("Basic Info")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hours per day")
                            Spacer()
                            Text("\(hoursPerDay, specifier: "%.1f") hours")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $hoursPerDay, in: 0.5...8, step: 0.5)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available Days")
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(Weekday.allCases, id: \.self) { day in
                                Button(action: {
                                    if availableDays.contains(day) {
                                        availableDays.remove(day)
                                    } else {
                                        availableDays.insert(day)
                                    }
                                }) {
                                    Text(day.rawValue)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(availableDays.contains(day) ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(availableDays.contains(day) ? Color.blue : Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Schedule")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suggested Tools")
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(suggestedTools, id: \.self) { tool in
                                Button(action: {
                                    if preferredTools.contains(tool) {
                                        preferredTools.removeAll { $0 == tool }
                                    } else {
                                        preferredTools.append(tool)
                                    }
                                }) {
                                    Text(tool)
                                        .font(.caption)
                                        .foregroundColor(preferredTools.contains(tool) ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(preferredTools.contains(tool) ? Color.blue : Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    HStack {
                        TextField("Add custom tool", text: $newTool)
                        
                        Button(action: {
                            if !newTool.isEmpty && !preferredTools.contains(newTool) {
                                preferredTools.append(newTool)
                                newTool = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newTool.isEmpty)
                    }
                    
                    if !preferredTools.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Selected Tools")
                                .font(.headline)
                            
                            ForEach(preferredTools, id: \.self) { tool in
                                HStack {
                                    Text(tool)
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        preferredTools.removeAll { $0 == tool }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("Preferred Tools")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func saveProfile() {
        guard let currentProfile = appState.userProfile else { return }
        
        let updatedProfile = UserProfile(
            id: currentProfile.id,
            name: name,
            currentStage: stage,
            targetRole: targetRole,
            timeBudgetHoursPerDay: hoursPerDay,
            availableDays: availableDays,
            preferredTools: preferredTools,
            createdAt: currentProfile.createdAt,
            updatedAt: Date()
        )
        
        appState.updateProfile(updatedProfile)
        dismiss()
    }
}

#Preview {
    EditProfileView(profile: UserProfile(
        name: "John Doe",
        currentStage: .secondYear,
        targetRole: "iOS SWE",
        timeBudgetHoursPerDay: 2.0,
        availableDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
        preferredTools: ["LeetCode", "Swift Playgrounds"]
    ))
    .environmentObject(AppState())
}

