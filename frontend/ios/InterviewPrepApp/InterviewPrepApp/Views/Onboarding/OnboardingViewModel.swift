//
//  OnboardingViewModel.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var name: String = ""
    @Published var stage: AcademicStage = .secondYear
    @Published var targetRole: String = ""
    @Published var hoursPerDay: Double = 2.0
    @Published var availableDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    @Published var preferredTools: [String] = []
    
    private let apiClient: APIClient
    private let storage: StorageService
    
    init(
        apiClient: APIClient = APIClient(),
        storage: StorageService = StorageService()
    ) {
        self.apiClient = apiClient
        self.storage = storage
    }
    
    var canProceed: Bool {
        switch currentStep {
        case 0:
            return true
        case 1:
            return !name.trimmingCharacters(in: .whitespaces).isEmpty
        case 2:
            return !targetRole.trimmingCharacters(in: .whitespaces).isEmpty
        case 3:
            return !availableDays.isEmpty
        case 4:
            return true // Tools are optional
        default:
            return false
        }
    }
    
    func nextStep() {
        if currentStep < 4 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func completeOnboarding(appState: AppState) {
        let profile = UserProfile(
            name: name,
            currentStage: stage,
            targetRole: targetRole,
            timeBudgetHoursPerDay: hoursPerDay,
            availableDays: availableDays,
            preferredTools: preferredTools
        )
        
        // Save profile (but don't mark onboarding as complete yet)
        appState.saveProfile(profile)
        
        // Set the flag to show loading view
        appState.isGeneratingInitialContent = true
    }
    
    // MARK: - Conversion Helpers
    
    private func convertToRoutine(_ apiPlan: APIPlan) -> Routine {
        var weeklySchedule: [Weekday: [TimeBlock]] = [:]
        
        for (dayStr, apiBlocks) in apiPlan.timeBlocks {
            guard let weekday = weekdayFrom(dayStr) else { continue }
            weeklySchedule[weekday] = apiBlocks.map { block in
                TimeBlock(
                    title: block.label,
                    description: block.label,
                    startTime: block.start,
                    endTime: block.end,
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
}

