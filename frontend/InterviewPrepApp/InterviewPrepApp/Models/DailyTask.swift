//
//  DailyTask.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import Foundation

struct DailyTask: Codable, Identifiable {
    let id: UUID
    var timeBlockId: UUID
    var date: Date
    var status: TaskStatus
    var notes: String?
    
    init(
        id: UUID = UUID(),
        timeBlockId: UUID,
        date: Date,
        status: TaskStatus = .pending,
        notes: String? = nil
    ) {
        self.id = id
        self.timeBlockId = timeBlockId
        self.date = date
        self.status = status
        self.notes = notes
    }
}

enum TaskStatus: String, Codable {
    case pending = "Pending"
    case done = "Done"
    case skipped = "Skipped"
    
    var icon: String {
        switch self {
        case .pending: return "circle"
        case .done: return "checkmark.circle.fill"
        case .skipped: return "xmark.circle"
        }
    }
}

struct StreakData: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    var totalTasksCompleted: Int
    
    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastCompletedDate: Date? = nil,
        totalTasksCompleted: Int = 0
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastCompletedDate = lastCompletedDate
        self.totalTasksCompleted = totalTasksCompleted
    }
}

