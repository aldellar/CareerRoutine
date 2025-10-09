//
//  UserProfile.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var name: String
    var currentStage: AcademicStage
    var targetRole: String
    var timeBudgetHoursPerDay: Double
    var availableDays: Set<Weekday>
    var preferredTools: [String]
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        name: String = "",
        currentStage: AcademicStage = .secondYear,
        targetRole: String = "",
        timeBudgetHoursPerDay: Double = 2.0,
        availableDays: Set<Weekday> = Set(Weekday.allCases),
        preferredTools: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.currentStage = currentStage
        self.targetRole = targetRole
        self.timeBudgetHoursPerDay = timeBudgetHoursPerDay
        self.availableDays = availableDays
        self.preferredTools = preferredTools
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum AcademicStage: String, Codable, CaseIterable {
    case firstYear = "1st Year"
    case secondYear = "2nd Year"
    case thirdYear = "3rd Year"
    case fourthYear = "4th Year"
    case recentGrad = "Recent Grad"
    case careerChanger = "Career Changer"
}

enum Weekday: String, Codable, CaseIterable, Hashable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var shortName: String {
        String(rawValue.prefix(3))
    }
}

