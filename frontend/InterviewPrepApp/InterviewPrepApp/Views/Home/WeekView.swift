//
//  WeekView.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import SwiftUI

struct WeekView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDay: Weekday = WeekView.getCurrentWeekday()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Day selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach([Weekday.monday, .tuesday, .wednesday, .thursday, .friday], id: \.self) { day in
                            DayButton(
                                day: day,
                                isSelected: selectedDay == day,
                                isToday: day == WeekView.getCurrentWeekday()
                            ) {
                                selectedDay = day
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                
                // Weekly milestones
                if let milestones = appState.currentRoutine?.weeklyMilestones, !milestones.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This Week's Goals")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(milestones, id: \.self) { milestone in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                        .padding(.top, 2)
                                    
                                    Text(milestone)
                                        .font(.body)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Time blocks for selected day
                if let routine = appState.currentRoutine {
                    let blocks = routine.tasksForDay(selectedDay)
                    
                    if blocks.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text("No tasks scheduled for \(selectedDay.rawValue)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Take a break or work on personal projects!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("\(selectedDay.rawValue)'s Schedule")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ForEach(blocks) { block in
                                    TimeBlockCard(block: block)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No routine generated yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // TODO: Trigger routine generation
                        }) {
                            Text("Generate Plan")
                                .fontWeight(.semibold)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 60)
                }
                
                Spacer(minLength: 32)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
    
    private static func getCurrentWeekday() -> Weekday {
        let calendar = Calendar.current
        let weekdayInt = calendar.component(.weekday, from: Date())
        
        switch weekdayInt {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
}

struct DayButton: View {
    let day: Weekday
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(day.shortName)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Circle()
                    .fill(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.3) : Color.clear))
                    .frame(width: 8, height: 8)
            }
            .foregroundColor(isSelected ? .blue : .primary)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            )
        }
    }
}

struct TimeBlockCard: View {
    let block: TimeBlock
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Time
                VStack(alignment: .leading, spacing: 2) {
                    Text(block.startTime)
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(block.endTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(width: 50)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: block.category.icon)
                            .font(.caption)
                            .foregroundColor(categoryColor(block.category.color))
                        
                        Text(block.title)
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
                    
                    Text(block.category.rawValue)
                        .font(.caption)
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
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func categoryColor(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "pink": return .pink
        case "indigo": return .indigo
        case "red": return .red
        case "teal": return .teal
        default: return .blue
        }
    }
}

#Preview {
    WeekView()
        .environmentObject(AppState())
}

