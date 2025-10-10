//
//  RerollViewModel.swift
//  InterviewPrepApp
//
//  View model for rerolling specific sections of a plan
//

import Foundation
import SwiftUI

@MainActor
class RerollViewModel: ObservableObject {
    @Published var isRerolling = false
    @Published var alertState: AlertState?
    @Published var showSaveConfirmation = false
    
    private let apiClient: APIClient
    private let storage: StorageService
    
    init(
        apiClient: APIClient = APIClient(),
        storage: StorageService = StorageService()
    ) {
        self.apiClient = apiClient
        self.storage = storage
    }
    
    /// Reroll resources in current plan
    func rerollResources(
        profile: UserProfile,
        currentPlan: Routine
    ) async -> Routine? {
        isRerolling = true
        defer { isRerolling = false }
        
        do {
            let apiProfile = APIProfile.from(profile)
            let apiPlan = convertToAPIPlan(currentPlan)
            
            let result = try await apiClient.reroll(
                section: .resources,
                profile: apiProfile,
                currentPlan: apiPlan
            )
            
            guard case .resources(let newResources) = result else {
                throw APIError.unknown(
                    underlying: "Unexpected reroll result type"
                )
            }
            
            // Update plan with new resources
            let updatedPlan = applyResourcesUpdate(
                to: currentPlan,
                resources: newResources
            )
            
            // Save
            storage.saveRoutine(updatedPlan)
            showSaveConfirmation = true
            
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                showSaveConfirmation = false
            }
            
            return updatedPlan
            
        } catch let error as APIError {
            alertState = AlertState.error(error)
            return nil
        } catch {
            let apiError = APIError.from(error: error)
            alertState = AlertState.error(apiError)
            return nil
        }
    }
    
    /// Reroll time blocks in current plan
    func rerollTimeBlocks(
        profile: UserProfile,
        currentPlan: Routine
    ) async -> Routine? {
        isRerolling = true
        defer { isRerolling = false }
        
        do {
            let apiProfile = APIProfile.from(profile)
            let apiPlan = convertToAPIPlan(currentPlan)
            
            let result = try await apiClient.reroll(
                section: .timeBlocks,
                profile: apiProfile,
                currentPlan: apiPlan
            )
            
            guard case .timeBlocks(let newTimeBlocks) = result else {
                throw APIError.unknown(
                    underlying: "Unexpected reroll result type"
                )
            }
            
            // Update plan with new time blocks
            let updatedPlan = applyTimeBlocksUpdate(
                to: currentPlan,
                timeBlocks: newTimeBlocks
            )
            
            // Save
            storage.saveRoutine(updatedPlan)
            showSaveConfirmation = true
            
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                showSaveConfirmation = false
            }
            
            return updatedPlan
            
        } catch let error as APIError {
            alertState = AlertState.error(error)
            return nil
        } catch {
            let apiError = APIError.from(error: error)
            alertState = AlertState.error(apiError)
            return nil
        }
    }
    
    /// Reroll daily tasks in current plan
    func rerollDailyTasks(
        profile: UserProfile,
        currentPlan: Routine
    ) async -> Routine? {
        isRerolling = true
        defer { isRerolling = false }
        
        do {
            let apiProfile = APIProfile.from(profile)
            let apiPlan = convertToAPIPlan(currentPlan)
            
            let result = try await apiClient.reroll(
                section: .dailyTasks,
                profile: apiProfile,
                currentPlan: apiPlan
            )
            
            guard case .dailyTasks(_) = result else {
                throw APIError.unknown(
                    underlying: "Unexpected reroll result type"
                )
            }
            
            // For now, return current plan as dailyTasks
            // are not directly stored in Routine model
            // This can be extended based on your needs
            storage.saveRoutine(currentPlan)
            showSaveConfirmation = true
            
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                showSaveConfirmation = false
            }
            
            return currentPlan
            
        } catch let error as APIError {
            alertState = AlertState.error(error)
            return nil
        } catch {
            let apiError = APIError.from(error: error)
            alertState = AlertState.error(apiError)
            return nil
        }
    }
    
    /// Dismiss alert
    func dismissAlert() {
        alertState = nil
    }
    
    // MARK: - Private Helpers
    
    private func convertToAPIPlan(_ routine: Routine) -> APIPlan {
        var timeBlocks: [String: [APITimeBlock]] = [:]
        
        for (weekday, blocks) in routine.weeklySchedule {
            let dayKey = shortNameFor(weekday)
            timeBlocks[dayKey] = blocks.map { block in
                APITimeBlock(
                    start: block.startTime,
                    end: block.endTime,
                    label: block.title
                )
            }
        }
        
        // Ensure all days are present
        for day in ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"] {
            if timeBlocks[day] == nil {
                timeBlocks[day] = []
            }
        }
        
        return APIPlan(
            weekOf: ISO8601DateFormatter().string(from: Date()),
            timeBlocks: timeBlocks,
            dailyTasks: [:],
            milestones: routine.weeklyMilestones,
            resources: [],
            version: routine.version
        )
    }
    
    private func applyResourcesUpdate(
        to routine: Routine,
        resources: [APIResource]
    ) -> Routine {
        // Update resources in time blocks
        var updatedSchedule = routine.weeklySchedule
        
        for (day, blocks) in updatedSchedule {
            updatedSchedule[day] = blocks.map { block in
                var newBlock = block
                newBlock.resources = resources.map { $0.title }
                return newBlock
            }
        }
        
        return Routine(
            id: routine.id,
            version: routine.version + 1,
            weeklySchedule: updatedSchedule,
            weeklyMilestones: routine.weeklyMilestones,
            createdAt: routine.createdAt,
            updatedAt: Date()
        )
    }
    
    private func applyTimeBlocksUpdate(
        to routine: Routine,
        timeBlocks: [String: [APITimeBlock]]
    ) -> Routine {
        var updatedSchedule: [Weekday: [TimeBlock]] = [:]
        
        for (dayStr, apiBlocks) in timeBlocks {
            guard let weekday = weekdayFrom(dayStr) else { continue }
            updatedSchedule[weekday] = apiBlocks.map { block in
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
            id: routine.id,
            version: routine.version + 1,
            weeklySchedule: updatedSchedule,
            weeklyMilestones: routine.weeklyMilestones,
            createdAt: routine.createdAt,
            updatedAt: Date()
        )
    }
    
    private func shortNameFor(_ weekday: Weekday) -> String {
        switch weekday {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
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
            || lower.contains("linked") || lower.contains("tree") {
            return .dataStructures
        } else if lower.contains("system") {
            return .systemDesign
        } else if lower.contains("coding") || lower.contains("practice") {
            return .coding
        } else if lower.contains("behavioral") {
            return .behavioral
        } else if lower.contains("project") {
            return .projectWork
        } else if lower.contains("reading") {
            return .reading
        } else if lower.contains("mock") {
            return .mockInterview
        } else if lower.contains("review") {
            return .review
        } else {
            return .coding
        }
    }
}

