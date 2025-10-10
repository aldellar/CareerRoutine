//
//  NetworkService.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import Foundation
import Combine

class NetworkService {
    private let baseURL: String
    private let session: URLSession
    
    init(baseURL: String = "http://localhost:3000/api", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    // MARK: - Generate Routine
    
    func generateRoutine(profile: UserProfile) async throws -> Routine {
        // TODO: Connect to backend API
        // For now, return mock data
        return createMockRoutine()
    }
    
    // MARK: - Generate Prep Pack
    
    func generatePrepPack(profile: UserProfile) async throws -> PrepPack {
        // TODO: Connect to backend API
        // For now, return mock data
        return createMockPrepPack()
    }
    
    // MARK: - Regenerate Resources
    
    func regenerateResources(profile: UserProfile, currentPack: PrepPack) async throws -> [Resource] {
        // TODO: Connect to backend API
        // For now, return mock data
        return createMockResources()
    }
    
    // MARK: - Regenerate Mock Prompts
    
    func regenerateMockPrompts(profile: UserProfile, currentPack: PrepPack) async throws -> [String] {
        // TODO: Connect to backend API
        // For now, return mock data
        return createMockPrompts()
    }
    
    // MARK: - Regenerate Time Allocations
    
    func regenerateTimeAllocations(profile: UserProfile, currentRoutine: Routine) async throws -> Routine {
        // TODO: Connect to backend API
        // For now, return mock data
        return createMockRoutine()
    }
    
    // MARK: - Mock Data Generators (for frontend-only development)
    
    private func createMockRoutine() -> Routine {
        let mondayBlocks = [
            TimeBlock(
                title: "Arrays & Strings Review",
                description: "Review fundamental array and string manipulation techniques",
                startTime: "09:00",
                endTime: "10:30",
                category: .dataStructures,
                resources: ["LeetCode Easy problems", "Cracking the Coding Interview Ch. 1"]
            ),
            TimeBlock(
                title: "Coding Practice",
                description: "Solve 2-3 easy problems on LeetCode",
                startTime: "14:00",
                endTime: "15:30",
                category: .coding,
                resources: ["LeetCode", "HackerRank"]
            )
        ]
        
        let tuesdayBlocks = [
            TimeBlock(
                title: "Linked Lists",
                description: "Study linked list operations and common patterns",
                startTime: "09:00",
                endTime: "10:30",
                category: .dataStructures,
                resources: ["Visualgo.net", "LeetCode patterns"]
            ),
            TimeBlock(
                title: "Behavioral Prep",
                description: "Prepare STAR stories for common behavioral questions",
                startTime: "19:00",
                endTime: "20:00",
                category: .behavioral,
                resources: ["Amazon Leadership Principles", "Google's hiring guide"]
            )
        ]
        
        let wednesdayBlocks = [
            TimeBlock(
                title: "Stack & Queue",
                description: "Learn stack and queue implementations and applications",
                startTime: "09:00",
                endTime: "10:30",
                category: .dataStructures,
                resources: ["GeeksforGeeks", "YouTube tutorials"]
            ),
            TimeBlock(
                title: "Project Work",
                description: "Work on personal iOS project for portfolio",
                startTime: "15:00",
                endTime: "17:00",
                category: .projectWork,
                resources: ["Swift documentation", "SwiftUI tutorials"]
            )
        ]
        
        let thursdayBlocks = [
            TimeBlock(
                title: "Trees & Graphs",
                description: "Study tree traversals and basic graph algorithms",
                startTime: "09:00",
                endTime: "11:00",
                category: .dataStructures,
                resources: ["Binary tree visualizer", "Graph theory basics"]
            ),
            TimeBlock(
                title: "Mock Interview",
                description: "Practice with a peer or use Pramp",
                startTime: "18:00",
                endTime: "19:00",
                category: .mockInterview,
                resources: ["Pramp", "Interviewing.io"]
            )
        ]
        
        let fridayBlocks = [
            TimeBlock(
                title: "Weekly Review",
                description: "Review all problems solved this week and identify patterns",
                startTime: "09:00",
                endTime: "10:30",
                category: .review,
                resources: ["Personal notes", "Anki flashcards"]
            ),
            TimeBlock(
                title: "System Design Reading",
                description: "Read about scalable system design concepts",
                startTime: "14:00",
                endTime: "15:30",
                category: .systemDesign,
                resources: ["System Design Primer", "Grokking System Design"]
            )
        ]
        
        return Routine(
            weeklySchedule: [
                .monday: mondayBlocks,
                .tuesday: tuesdayBlocks,
                .wednesday: wednesdayBlocks,
                .thursday: thursdayBlocks,
                .friday: fridayBlocks
            ],
            weeklyMilestones: [
                "Complete 10 LeetCode easy problems",
                "Finish 2 STAR stories",
                "Implement one data structure from scratch",
                "Complete one mock interview"
            ]
        )
    }
    
    private func createMockPrepPack() -> PrepPack {
        return PrepPack(
            topicLadder: [
                PrepTopic(
                    name: "Data Structures & Algorithms",
                    description: "Core CS fundamentals for technical interviews",
                    priority: .high,
                    estimatedWeeks: 8,
                    subtopics: ["Arrays & Strings", "Linked Lists", "Stacks & Queues", "Trees & Graphs", "Sorting & Searching", "Dynamic Programming"]
                ),
                PrepTopic(
                    name: "Swift & iOS Development",
                    description: "Language-specific and platform knowledge",
                    priority: .high,
                    estimatedWeeks: 6,
                    subtopics: ["Swift fundamentals", "SwiftUI", "UIKit", "Concurrency", "Memory management", "iOS frameworks"]
                ),
                PrepTopic(
                    name: "System Design",
                    description: "Designing scalable systems and mobile architecture",
                    priority: .medium,
                    estimatedWeeks: 4,
                    subtopics: ["Mobile architecture patterns", "API design", "Caching strategies", "Offline-first design"]
                ),
                PrepTopic(
                    name: "Behavioral Interview",
                    description: "Communication and leadership stories",
                    priority: .high,
                    estimatedWeeks: 2,
                    subtopics: ["STAR method", "Leadership principles", "Conflict resolution", "Project examples"]
                )
            ],
            practiceCadence: "Week 1-4: Focus on DS&A fundamentals (2hrs/day). Week 5-8: Mix DS&A practice with iOS-specific questions (1.5hrs/day). Week 9-12: System design + mock interviews (1hr/day).",
            resources: createMockResources(),
            mockInterviewPrompts: createMockPrompts()
        )
    }
    
    private func createMockResources() -> [Resource] {
        return [
            Resource(
                title: "LeetCode",
                url: "https://leetcode.com",
                description: "Practice coding problems with a focus on patterns",
                type: .practice
            ),
            Resource(
                title: "Cracking the Coding Interview",
                url: nil,
                description: "Essential book covering DS&A and interview strategies",
                type: .book
            ),
            Resource(
                title: "Swift Documentation",
                url: "https://docs.swift.org",
                description: "Official Swift language documentation",
                type: .documentation
            ),
            Resource(
                title: "iOS Interview Questions",
                url: "https://github.com/onthecodepath/iOS-Interview-Questions",
                description: "Curated list of iOS-specific interview questions",
                type: .article
            ),
            Resource(
                title: "System Design Primer",
                url: "https://github.com/donnemartin/system-design-primer",
                description: "Learn how to design large-scale systems",
                type: .course
            )
        ]
    }
    
    private func createMockPrompts() -> [String] {
        return [
            "Implement a function to reverse a linked list. Explain your approach and time complexity.",
            "Design a simple cache with LRU eviction policy. How would you implement this in Swift?",
            "Tell me about a time you had to debug a difficult issue in your code.",
            "How would you design the architecture for an offline-first iOS app?",
            "Implement a binary search tree and write a method to validate if a tree is a valid BST."
        ]
    }
}

