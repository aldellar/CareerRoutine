//
//  APIPlan.swift
//  InterviewPrepApp
//
//  API-compatible plan model matching backend schema
//

import Foundation

/// Plan model from API (matches backend schema)
struct APIPlan: Codable {
    let weekOf: String
    let timeBlocks: [String: [APITimeBlock]]
    let dailyTasks: [String: [String]]
    let milestones: [String]
    let resources: [APIResource]
    let version: Int
    
    /// Stub for testing
    static func stub() -> APIPlan {
        return APIPlan(
            weekOf: "2025-10-13",
            timeBlocks: [
                "Mon": [
                    APITimeBlock(
                        durationHours: 1.5,
                        label: "Arrays & Strings Review"
                    ),
                    APITimeBlock(
                        durationHours: 1.5,
                        label: "LeetCode Practice"
                    )
                ],
                "Tue": [
                    APITimeBlock(
                        durationHours: 1.5,
                        label: "Linked Lists"
                    )
                ],
                "Wed": [],
                "Thu": [],
                "Fri": [],
                "Sat": [],
                "Sun": []
            ],
            dailyTasks: [
                "Mon": [
                    "Complete 2 easy array problems",
                    "Review string manipulation"
                ],
                "Tue": [
                    "Implement linked list reversal",
                    "Study cycle detection"
                ],
                "Wed": [],
                "Thu": [],
                "Fri": [],
                "Sat": [],
                "Sun": []
            ],
            milestones: [
                "Complete 10 easy problems",
                "Master basic data structures",
                "Prepare 2 STAR stories"
            ],
            resources: [
                APIResource(title: "LeetCode", url: "https://leetcode.com"),
                APIResource(
                    title: "Cracking the Coding Interview",
                    url: "https://amazon.com"
                )
            ],
            version: 1
        )
    }
}

/// Time block model (matches backend schema)
struct APITimeBlock: Codable {
    let durationHours: Double  // Duration in hours (e.g., 1.5)
    let label: String
}

/// Resource model (matches backend schema)
struct APIResource: Codable {
    let title: String
    let url: String
}

