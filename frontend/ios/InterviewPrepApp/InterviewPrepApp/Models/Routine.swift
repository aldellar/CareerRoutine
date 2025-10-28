//
//  Routine.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import Foundation

struct Routine: Codable, Identifiable {
    let id: UUID
    var version: Int
    var weeklySchedule: [Weekday: [TimeBlock]]
    var weeklyMilestones: [String]
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        version: Int = 1,
        weeklySchedule: [Weekday: [TimeBlock]] = [:],
        weeklyMilestones: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.version = version
        self.weeklySchedule = weeklySchedule
        self.weeklyMilestones = weeklyMilestones
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func tasksForDay(_ day: Weekday) -> [TimeBlock] {
        weeklySchedule[day] ?? []
    }
}

struct TimeBlock: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var durationHours: Double // Duration in hours (e.g., 1.5)
    var category: TaskCategory
    var resources: [String]
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        durationHours: Double,
        category: TaskCategory,
        resources: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.durationHours = durationHours
        self.category = category
        self.resources = resources
    }
    
    var durationDisplay: String {
        if durationHours == 1.0 {
            return "1 hour"
        } else if durationHours == Double(Int(durationHours)) {
            return "\(Int(durationHours)) hours"
        } else if durationHours < 1.0 {
            let minutes = Int(durationHours * 60)
            return "\(minutes) min"
        } else {
            let hours = Int(durationHours)
            let minutes = Int((durationHours - Double(hours)) * 60)
            if minutes == 0 {
                return "\(hours) hours"
            } else {
                return "\(hours)h \(minutes)m"
            }
        }
    }
}

enum TaskCategory: String, Codable, CaseIterable {
    case dataStructures = "Data Structures & Algorithms"
    case systemDesign = "System Design"
    case coding = "Coding Practice"
    case behavioral = "Behavioral Prep"
    case projectWork = "Project Work"
    case reading = "Reading/Learning"
    case mockInterview = "Mock Interview"
    case review = "Review & Reflection"
    
    var icon: String {
        switch self {
        case .dataStructures: return "function"
        case .systemDesign: return "square.grid.3x3"
        case .coding: return "chevron.left.forwardslash.chevron.right"
        case .behavioral: return "person.2"
        case .projectWork: return "hammer"
        case .reading: return "book"
        case .mockInterview: return "mic"
        case .review: return "checkmark.circle"
        }
    }
    
    var color: String {
        switch self {
        case .dataStructures: return "blue"
        case .systemDesign: return "purple"
        case .coding: return "green"
        case .behavioral: return "orange"
        case .projectWork: return "pink"
        case .reading: return "indigo"
        case .mockInterview: return "red"
        case .review: return "teal"
        }
    }
}

