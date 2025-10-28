//
//  NetworkService.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import Foundation
import Combine

class NetworkService {
    static let shared = NetworkService()
    
    private let apiClient: APIClient
    private let useMockData: Bool
    
    /// Initialize NetworkService
    /// - Parameters:
    ///   - apiClient: Optional APIClient instance (creates new one if nil)
    ///   - useMockData: If true, returns mock data without API calls. Set to false to use real backend.
    init(apiClient: APIClient? = nil, useMockData: Bool = false) {
        // Use provided client or create a new one
        self.apiClient = apiClient ?? APIClient()
        self.useMockData = useMockData
        
        if useMockData {
            print("⚠️ NetworkService: Running in MOCK mode (no real API calls)")
            print("   To enable real API calls, set useMockData = false")
        } else {
            print("✅ NetworkService: Running in REAL API mode")
            print("   Backend URL: \(APIConfig.baseURL)")
        }
    }
    
    // MARK: - Generate Routine
    
    func generateRoutine(profile: UserProfile) async throws -> Routine {
        print("🌐 NetworkService.generateRoutine called")
        print("   - Mock mode: \(useMockData)")
        print("   - Profile: \(profile.name), \(profile.targetRole)")
        
        // Validate input for safety
        validateUserInput(profile)
        
        if useMockData {
            // Mock mode for offline development
            print("   - Using MOCK data (8 second delay)")
            try await Task.sleep(nanoseconds: 8_000_000_000)
            return createMockRoutine(for: profile)
        }
        
        // REAL API CALL with safety handling
        print("   - Making REAL API call to backend...")
        let apiProfile = APIProfile.from(profile)
        
        do {
            let apiPlan = try await apiClient.generateRoutine(profile: apiProfile)
            
            // Validate response quality
            if apiPlan.timeBlocks.isEmpty {
                print("⚠️ Warning: Empty response from API, using fallback")
                return createMockRoutine(for: profile)
            }
            
            print("   - ✅ API response received, converting to Routine")
            return convertToRoutine(apiPlan)
            
        } catch {
            print("⚠️ API call failed: \(error.localizedDescription)")
            print("   - Using fallback routine")
            return createMockRoutine(for: profile)
        }
    }
    
    // MARK: - Generate Prep Pack
    
    func generatePrepPack(profile: UserProfile) async throws -> PrepPack {
        print("🌐 NetworkService.generatePrepPack called")
        print("   - Mock mode: \(useMockData)")
        print("   - Profile: \(profile.name), \(profile.targetRole)")
        
        // Validate input for safety
        validateUserInput(profile)
        
        if useMockData {
            // Mock mode for offline development
            print("   - Using MOCK data (8 second delay)")
            try await Task.sleep(nanoseconds: 8_000_000_000)
            return createMockPrepPack()
        }
        
        // REAL API CALL with safety handling
        print("   - Making REAL API call to backend...")
        let apiProfile = APIProfile.from(profile)
        
        do {
            let apiPrep = try await apiClient.generatePrep(profile: apiProfile)
            
            // Validate response quality
            if apiPrep.prepOutline.isEmpty {
                print("⚠️ Warning: Empty response from API, using fallback")
                return createMockPrepPack()
            }
            
            print("   - ✅ API response received, converting to PrepPack")
            return convertToPrepPack(apiPrep)
            
        } catch {
            print("⚠️ API call failed: \(error.localizedDescription)")
            print("   - Using fallback prep pack")
            return createMockPrepPack()
        }
    }
    
    // MARK: - Regenerate Resources
    
    func regenerateResources(profile: UserProfile, currentPack: PrepPack) async throws -> [Resource] {
        // TODO: Connect to backend reroll API
        // For now, return mock data
        return createMockResources()
    }
    
    // MARK: - Regenerate Mock Prompts
    
    func regenerateMockPrompts(profile: UserProfile, currentPack: PrepPack) async throws -> [String] {
        // TODO: Connect to backend reroll API
        // For now, return mock data
        return createMockPrompts()
    }
    
    // MARK: - Regenerate Time Allocations
    
    func regenerateTimeAllocations(profile: UserProfile, currentRoutine: Routine) async throws -> Routine {
        // TODO: Connect to backend reroll API
        // For now, return mock data
        return createMockRoutine(for: profile)
    }
    
    // MARK: - API Response Conversion
    
    private func convertToRoutine(_ apiPlan: APIPlan) -> Routine {
        print("📋 convertToRoutine() called")
        var weeklySchedule: [Weekday: [TimeBlock]] = [:]
        
        for (dayStr, apiBlocks) in apiPlan.timeBlocks {
            guard let weekday = weekdayFrom(dayStr) else { 
                print("⚠️ Could not convert day string: \(dayStr)")
                continue 
            }
            
            print("📅 Processing \(dayStr): \(apiBlocks.count) blocks")
            
            weeklySchedule[weekday] = apiBlocks.map { block in
                print("   - Block: '\(block.label)' - \(block.durationHours) hours")
                return TimeBlock(
                    title: block.label,
                    description: block.label,
                    durationHours: block.durationHours,
                    category: inferCategory(from: block.label),
                    resources: []
                )
            }
        }
        
        return Routine(
            version: apiPlan.version,
            weeklySchedule: weeklySchedule,
            weeklyMilestones: apiPlan.milestones
        )
    }
    
    private func convertToPrepPack(_ apiPrep: APIPrep) -> PrepPack {
        let topicLadder = apiPrep.prepOutline.map { section in
            PrepTopic(
                name: section.section,
                description: section.items.joined(separator: ". "),
                priority: .high,
                estimatedWeeks: 4,
                subtopics: section.items
            )
        }
        
        let resources = apiPrep.resources.map { apiResource in
            Resource(
                title: apiResource.title,
                url: apiResource.url,
                description: "",
                type: inferResourceType(from: apiResource.title)
            )
        }
        
        return PrepPack(
            topicLadder: topicLadder,
            practiceCadence: buildPracticeCadence(from: apiPrep.weeklyDrillPlan),
            resources: resources,
            mockInterviewPrompts: apiPrep.starterQuestions
        )
    }
    
    private func buildPracticeCadence(from drillPlan: [DrillDay]) -> String {
        let daysDescription = drillPlan.map { day in
            "\(day.day): \(day.drills.count) drills"
        }.joined(separator: ", ")
        return "Weekly drill plan: \(daysDescription)"
    }
    
    private func weekdayFrom(_ str: String) -> Weekday? {
        switch str {
        case "Mon": return .monday
        case "Tue": return .tuesday
        case "Wed": return .wednesday
        case "Thu": return .thursday
        case "Fri": return .friday
        case "Sat": return .saturday
        case "Sun": return .sunday
        default: return nil
        }
    }
    
    private func inferCategory(from label: String) -> TaskCategory {
        let lower = label.lowercased()
        if lower.contains("array") || lower.contains("string") 
            || lower.contains("linked") || lower.contains("tree") 
            || lower.contains("graph") {
            return .dataStructures
        } else if lower.contains("system design") {
            return .systemDesign
        } else if lower.contains("coding") || lower.contains("leetcode") 
            || lower.contains("practice") {
            return .coding
        } else if lower.contains("behavioral") || lower.contains("star") {
            return .behavioral
        } else if lower.contains("project") {
            return .projectWork
        } else if lower.contains("reading") || lower.contains("study") {
            return .reading
        } else if lower.contains("mock") || lower.contains("interview") {
            return .mockInterview
        } else if lower.contains("review") {
            return .review
        } else {
            return .coding
        }
    }
    
    private func inferResourceType(from title: String) -> ResourceType {
        let lower = title.lowercased()
        if lower.contains("video") || lower.contains("youtube") {
            return .video
        } else if lower.contains("book") {
            return .book
        } else if lower.contains("course") {
            return .course
        } else if lower.contains("leetcode") || lower.contains("hackerrank") {
            return .practice
        } else if lower.contains("doc") || lower.contains("documentation") {
            return .documentation
        } else {
            return .article
        }
    }
    
    // MARK: - Mock Data Generators (for frontend-only development)
    
    private func createMockRoutine(for profile: UserProfile) -> Routine {
        print("📝 createMockRoutine() called")
        print("   - Profile time budget: \(profile.timeBudgetHoursPerDay) hours")
        
        // Use profile's time budget
        let timeBudget = profile.timeBudgetHoursPerDay
        
        // Calculate durations that sum exactly to time budget
        // For 2 hours: split into 1.25h and 0.75h (or similar)
        let taskDuration1 = round(timeBudget * 0.6 * 4) / 4  // Round to 0.25h
        let taskDuration2 = timeBudget - taskDuration1  // Ensure exact sum
        
        print("   - Task duration 1: \(taskDuration1) hours")
        print("   - Task duration 2: \(taskDuration2) hours")
        print("   - Total: \(taskDuration1 + taskDuration2) hours")
        
        let mondayBlocks = [
            TimeBlock(
                title: "Arrays & Strings Review",
                description: "Review fundamental array and string manipulation techniques",
                durationHours: taskDuration1,
                category: .dataStructures,
                resources: ["LeetCode Easy problems", "Cracking the Coding Interview Ch. 1"]
            ),
            TimeBlock(
                title: "Coding Practice",
                description: "Solve 2-3 easy problems on LeetCode",
                durationHours: taskDuration2,
                category: .coding,
                resources: ["LeetCode", "HackerRank"]
            )
        ]
        
        let tuesdayBlocks = [
            TimeBlock(
                title: "Linked Lists",
                description: "Study linked list operations and common patterns",
                durationHours: taskDuration1,
                category: .dataStructures,
                resources: ["Visualgo.net", "LeetCode patterns"]
            ),
            TimeBlock(
                title: "Behavioral Prep",
                description: "Prepare STAR stories for common behavioral questions",
                durationHours: taskDuration2,
                category: .behavioral,
                resources: ["Amazon Leadership Principles", "Google's hiring guide"]
            )
        ]
        
        let wednesdayBlocks = [
            TimeBlock(
                title: "Stack & Queue",
                description: "Learn stack and queue implementations and applications",
                durationHours: taskDuration1,
                category: .dataStructures,
                resources: ["GeeksforGeeks", "YouTube tutorials"]
            ),
            TimeBlock(
                title: "Project Work",
                description: "Work on personal iOS project for portfolio",
                durationHours: taskDuration2,
                category: .projectWork,
                resources: ["Swift documentation", "SwiftUI tutorials"]
            )
        ]
        
        let thursdayBlocks = [
            TimeBlock(
                title: "Trees & Graphs",
                description: "Study tree traversals and basic graph algorithms",
                durationHours: taskDuration1,
                category: .dataStructures,
                resources: ["Binary tree visualizer", "Graph theory basics"]
            ),
            TimeBlock(
                title: "Mock Interview",
                description: "Practice with a peer or use Pramp",
                durationHours: taskDuration2,
                category: .mockInterview,
                resources: ["Pramp", "Interviewing.io"]
            )
        ]
        
        let fridayBlocks = [
            TimeBlock(
                title: "Weekly Review",
                description: "Review all problems solved this week and identify patterns",
                durationHours: taskDuration1,
                category: .review,
                resources: ["Personal notes", "Anki flashcards"]
            ),
            TimeBlock(
                title: "System Design Reading",
                description: "Read about scalable system design concepts",
                durationHours: taskDuration2,
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
    
    // MARK: - Input Validation & Safety
    
    /// Validates user input to prevent unsafe content
    private func validateUserInput(_ profile: UserProfile) {
        // Validate name
        if profile.name.count > 100 {
            print("⚠️ Warning: Profile name too long")
        }
        
        // Validate target role
        if profile.targetRole.count > 100 {
            print("⚠️ Warning: Target role name too long")
        }
        
        // Validate stage
        // currentStage is an enum, so validation is automatically handled by the type system
        print("   - Stage: \(profile.currentStage.rawValue)")
        
        // Validate time budget
        if profile.timeBudgetHoursPerDay <= 0 || profile.timeBudgetHoursPerDay > 24 {
            print("⚠️ Warning: Invalid time budget: \(profile.timeBudgetHoursPerDay) hours")
        }
    }
}

