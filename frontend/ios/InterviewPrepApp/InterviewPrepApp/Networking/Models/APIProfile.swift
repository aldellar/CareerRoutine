//
//  APIProfile.swift
//  InterviewPrepApp
//
//  API-compatible profile model matching backend schema
//

import Foundation

/// Profile model for API requests (matches backend schema)
struct APIProfile: Codable {
    let name: String
    let stage: String
    let targetRole: String
    let timeBudgetHoursPerDay: Double
    let availableDays: [String]
    let constraints: [String]?
    
    /// Convert from UserProfile to APIProfile
    static func from(_ profile: UserProfile) -> APIProfile {
        return APIProfile(
            name: profile.name,
            stage: profile.currentStage.rawValue,
            targetRole: profile.targetRole,
            timeBudgetHoursPerDay: profile.timeBudgetHoursPerDay,
            availableDays: profile.availableDays.map { dayToShortName($0) },
            constraints: profile.preferredTools.isEmpty ? nil : profile.preferredTools
        )
    }
    
    /// Stub for testing
    static func stub() -> APIProfile {
        return APIProfile(
            name: "Alex Chen",
            stage: "2nd Year",
            targetRole: "iOS Engineer",
            timeBudgetHoursPerDay: 2.0,
            availableDays: ["Mon", "Tue", "Wed", "Thu", "Fri"],
            constraints: ["SwiftUI", "Combine"]
        )
    }
    
    // Helper to convert Weekday to backend format
    private static func dayToShortName(_ day: Weekday) -> String {
        switch day {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
}

