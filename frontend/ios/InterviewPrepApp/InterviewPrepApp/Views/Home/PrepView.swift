//
//  PrepView.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import SwiftUI

struct PrepView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = PrepViewModel()
    @StateObject private var reachability = Reachability()
    @State private var showingRegenerateOptions: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Offline indicator
                if !reachability.isOnline {
                    HStack {
                        Image(systemName: "wifi.slash")
                        Text("Offline")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .cornerRadius(8)
                }
                
                // Save confirmation banner
                if viewModel.showSaveConfirmation {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Prep pack saved successfully")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .cornerRadius(8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                if let prepPack = appState.prepPack {
                    // Practice Cadence
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Practice Plan")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                showingRegenerateOptions = true
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.body)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text(prepPack.practiceCadence)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    
                    // Topic Ladder
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Topic Roadmap")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(prepPack.topicLadder) { topic in
                                TopicCard(topic: topic)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Resources
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recommended Resources")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                regenerateResources()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.caption)
                                    Text("Refresh")
                                        .font(.caption)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(prepPack.resources) { resource in
                                ResourceCard(resource: resource)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Mock Interview Prompts
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Practice Questions")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                regenerateMockPrompts()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.caption)
                                    Text("New Set")
                                        .font(.caption)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(prepPack.mockInterviewPrompts.enumerated()), id: \.offset) { index, prompt in
                                MockPromptCard(number: index + 1, prompt: prompt)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    // Loading, error, or no prep pack states
                    VStack(spacing: 16) {
                        if viewModel.prepState.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Generating your prep pack...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        } else {
                            Image(systemName: "book.closed")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text("No prep pack generated yet")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Button(action: generatePrepPack) {
                                Text("Generate Prep Pack")
                                    .fontWeight(.semibold)
                                    .padding()
                                    .background(
                                        reachability.isOnline 
                                            ? Color.blue 
                                            : Color.gray
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(!reachability.isOnline)
                        }
                    }
                    .padding(.top, 60)
                }
                
                Spacer(minLength: 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .confirmationDialog("Regenerate", isPresented: $showingRegenerateOptions) {
            Button("Regenerate Resources") {
                regenerateResources()
            }
            Button("Regenerate Practice Questions") {
                regenerateMockPrompts()
            }
            Button("Regenerate Everything") {
                generatePrepPack()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(item: $viewModel.alertState) { alertState in
            if let secondary = alertState.secondaryButton {
                return Alert(
                    title: Text(alertState.title),
                    message: Text(alertState.message),
                    primaryButton: .default(
                        Text(alertState.primaryButton?.title ?? "OK"),
                        action: alertState.primaryButton?.action
                    ),
                    secondaryButton: .cancel(
                        Text(secondary.title),
                        action: secondary.action
                    )
                )
            } else {
                return Alert(
                    title: Text(alertState.title),
                    message: Text(alertState.message),
                    dismissButton: .default(
                        Text(alertState.primaryButton?.title ?? "OK"),
                        action: alertState.primaryButton?.action
                    )
                )
            }
        }
        .onAppear {
            syncPrepState()
        }
    }
    
    private func generatePrepPack() {
        guard let profile = appState.userProfile else { return }
        viewModel.generatePrep(profile: profile, appState: appState)
    }
    
    private func regenerateResources() {
        // TODO: Implement with RerollViewModel if needed
        print("Regenerate resources not yet implemented via API")
    }
    
    private func regenerateMockPrompts() {
        // TODO: Implement with RerollViewModel if needed
        print("Regenerate prompts not yet implemented via API")
    }
    
    private func syncPrepState() {
        // Sync ViewModel state with AppState
        if let prepPack = appState.prepPack,
           !viewModel.prepState.hasValue {
            appState.prepPack = prepPack
        }
    }
}

struct TopicCard: View {
    let topic: PrepTopic
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Priority indicator
                Circle()
                    .fill(priorityColor(topic.priority.color))
                    .frame(width: 12, height: 12)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(topic.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text(topic.priority.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(priorityColor(topic.priority.color))
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("\(topic.estimatedWeeks) weeks")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if isExpanded {
                        Text(topic.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
                        if !topic.subtopics.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Subtopics:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.top, 8)
                                
                                ForEach(topic.subtopics, id: \.self) { subtopic in
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark")
                                            .font(.caption2)
                                        Text(subtopic)
                                            .font(.caption)
                                    }
                                    .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func priorityColor(_ colorName: String) -> Color {
        switch colorName {
        case "red": return .red
        case "orange": return .orange
        case "green": return .green
        default: return .blue
        }
    }
}

struct ResourceCard: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: resource.type.icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.title)
                        .font(.headline)
                    
                    Text(resource.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if resource.url != nil {
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Text(resource.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            if let url = resource.url {
                Link(destination: URL(string: url)!) {
                    Text(url)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct MockPromptCard: View {
    let number: Int
    let prompt: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(prompt)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    PrepView()
        .environmentObject(AppState())
}

