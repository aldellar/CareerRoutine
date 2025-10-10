//
//  APIPrep.swift
//  InterviewPrepApp
//
//  API-compatible prep model matching backend schema
//

import Foundation

/// Prep pack model from API (matches backend schema)
struct APIPrep: Codable {
    let prepOutline: [OutlineSection]
    let weeklyDrillPlan: [DrillDay]
    let starterQuestions: [String]
    let resources: [APIResource]
    
    /// Stub for testing
    static func stub() -> APIPrep {
        return APIPrep(
            prepOutline: [
                OutlineSection(
                    section: "Data Structures & Algorithms",
                    items: [
                        "Arrays and strings - fundamental operations",
                        "Linked lists - reversal, cycle detection",
                        "Trees and graphs - traversals, BFS/DFS",
                        "Dynamic programming - memoization patterns"
                    ]
                ),
                OutlineSection(
                    section: "iOS & Swift",
                    items: [
                        "Swift fundamentals - optionals, closures, protocols",
                        "SwiftUI - state management, data flow",
                        "Concurrency - async/await, actors",
                        "Memory management - ARC, weak/strong references"
                    ]
                ),
                OutlineSection(
                    section: "System Design",
                    items: [
                        "Mobile architecture - MVVM, Clean Architecture",
                        "Networking - URLSession, error handling",
                        "Data persistence - CoreData, FileManager",
                        "Performance - profiling, optimization"
                    ]
                )
            ],
            weeklyDrillPlan: [
                DrillDay(
                    day: "Mon",
                    drills: [
                        "Solve 2 array problems on LeetCode",
                        "Review Swift optionals and error handling"
                    ]
                ),
                DrillDay(
                    day: "Tue",
                    drills: [
                        "Practice linked list problems",
                        "Study SwiftUI state management"
                    ]
                ),
                DrillDay(
                    day: "Wed",
                    drills: [
                        "Tree traversal exercises",
                        "Review iOS concurrency patterns"
                    ]
                ),
                DrillDay(
                    day: "Thu",
                    drills: [
                        "Dynamic programming problems",
                        "Practice system design question"
                    ]
                ),
                DrillDay(
                    day: "Fri",
                    drills: [
                        "Weekly review and mock interview",
                        "Prepare behavioral STAR stories"
                    ]
                )
            ],
            starterQuestions: [
                "Reverse a linked list iteratively and recursively",
                "Find the longest substring without repeating characters",
                "Design a cache with LRU eviction policy",
                "Explain the iOS app lifecycle",
                "How does Swift's ARC work?"
            ],
            resources: [
                APIResource(
                    title: "LeetCode",
                    url: "https://leetcode.com"
                ),
                APIResource(
                    title: "Swift Documentation",
                    url: "https://docs.swift.org"
                ),
                APIResource(
                    title: "iOS Interview Questions",
                    url: "https://github.com/onthecodepath/iOS-Interview-Questions"
                )
            ]
        )
    }
}

/// Outline section model (matches backend schema)
struct OutlineSection: Codable {
    let section: String
    let items: [String]
}

/// Drill day model (matches backend schema)
struct DrillDay: Codable {
    let day: String  // Mon, Tue, Wed, Thu, Fri
    let drills: [String]
}

