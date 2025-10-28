//
//  TodayView.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var appState: AppState
    
    var todayTasks: [(task: DailyTask, block: TimeBlock)] {
        appState.getTasksForToday()
    }
    
    var completedCount: Int {
        todayTasks.filter { $0.task.status == .done }.count
    }
    
    var totalCount: Int {
        todayTasks.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Streak Card
                StreakCard(streakData: appState.streakData)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Progress Card
                if totalCount > 0 {
                    ProgressCard(completed: completedCount, total: totalCount)
                        .padding(.horizontal)
                }
                
                // Task List
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's Tasks")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if todayTasks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.green)
                            
                            Text("No tasks for today")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Enjoy your free time or work on personal projects!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                        .frame(maxWidth: .infinity)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(todayTasks, id: \.task.id) { taskPair in
                                TaskCard(
                                    task: taskPair.task,
                                    block: taskPair.block,
                                    onStatusChange: { newStatus in
                                        appState.updateTaskStatus(taskPair.task.id, status: newStatus)
                                    },
                                    onAddNote: { note in
                                        appState.addTaskNote(taskPair.task.id, note: note)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 32)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct StreakCard: View {
    let streakData: StreakData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(streakData.currentStreak)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("days")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
            }
            
            Divider()
            
            HStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Longest Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(streakData.longestStreak) days")
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(streakData.totalTasksCompleted)")
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct ProgressCard: View {
    let completed: Int
    let total: Int
    
    var progress: Double {
        total > 0 ? Double(completed) / Double(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                
                Spacer()
                
                Text("\(completed)/\(total)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: 12)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 12)
            
            if completed == total && total > 0 {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("Great job! All tasks completed!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct TaskCard: View {
    let task: DailyTask
    let block: TimeBlock
    let onStatusChange: (TaskStatus) -> Void
    let onAddNote: (String) -> Void
    
    @State private var isExpanded: Bool = false
    @State private var showingNoteSheet: Bool = false
    @State private var noteText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Status button
                Button(action: {
                    cycleStatus()
                }) {
                    Image(systemName: task.status.icon)
                        .font(.title2)
                        .foregroundColor(statusColor)
                }
                
                // Duration
                VStack(alignment: .leading, spacing: 2) {
                    Text(block.durationDisplay)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .frame(width: 60)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(block.title)
                            .font(.headline)
                            .strikethrough(task.status == .done)
                        
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
                        Image(systemName: block.category.icon)
                            .font(.caption)
                        
                        Text(block.category.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    if isExpanded {
                        Text(block.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
                        if !block.resources.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Resources:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.top, 8)
                                
                                ForEach(block.resources, id: \.self) { resource in
                                    HStack(spacing: 4) {
                                        Image(systemName: "link")
                                            .font(.caption2)
                                        Text(resource)
                                            .font(.caption)
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        if let notes = task.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notes:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.top, 8)
                                
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                        
                        Button(action: {
                            noteText = task.notes ?? ""
                            showingNoteSheet = true
                        }) {
                            HStack {
                                Image(systemName: "note.text")
                                    .font(.caption)
                                Text(task.notes == nil ? "Add Note" : "Edit Note")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingNoteSheet) {
            NoteSheet(noteText: $noteText, onSave: {
                onAddNote(noteText)
                showingNoteSheet = false
            })
        }
    }
    
    private var statusColor: Color {
        switch task.status {
        case .pending: return .gray
        case .done: return .green
        case .skipped: return .orange
        }
    }
    
    private var backgroundColor: Color {
        switch task.status {
        case .pending: return Color(.systemBackground)
        case .done: return Color.green.opacity(0.05)
        case .skipped: return Color.orange.opacity(0.05)
        }
    }
    
    private func cycleStatus() {
        switch task.status {
        case .pending:
            onStatusChange(.done)
        case .done:
            onStatusChange(.skipped)
        case .skipped:
            onStatusChange(.pending)
        }
    }
}

struct NoteSheet: View {
    @Binding var noteText: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $noteText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
        }
    }
}

#Preview {
    TodayView()
        .environmentObject(AppState())
}

