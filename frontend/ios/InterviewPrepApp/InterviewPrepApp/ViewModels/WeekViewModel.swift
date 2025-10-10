//
//  WeekViewModel.swift
//  InterviewPrepApp
//
//  View model for weekly plan generation and management
//

import Foundation
import SwiftUI

@MainActor
class WeekViewModel: ObservableObject {
    @Published var planState: Loadable<Routine> = .idle
    @Published var alertState: AlertState?
    @Published var showSaveConfirmation = false
    
    private let apiClient: APIClient
    private let storage: StorageService
    private var currentTask: Task<Void, Never>?
    
    init(
        apiClient: APIClient = APIClient(),
        storage: StorageService = StorageService()
    ) {
        self.apiClient = apiClient
        self.storage = storage
        
        // Load existing routine if available
        if let routine = storage.loadRoutine() {
            planState = .loaded(routine)
        }
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    /// Generate a new weekly plan from profile
    func generatePlan(profile: UserProfile, appState: AppState? = nil) {
        // Cancel any existing task
        currentTask?.cancel()
        
        currentTask = Task {
            planState = .loading
            
            do {
                // Convert profile to API format
                let apiProfile = APIProfile.from(profile)
                
                // Call API
                let apiPlan = try await apiClient.generateRoutine(
                    profile: apiProfile
                )
                
                // Convert to local model
                let routine = convertToRoutine(apiPlan)
                
                // Check if cancelled
                guard !Task.isCancelled else { return }
                
                // Save locally
                storage.saveRoutine(routine)
                
                // Update AppState if provided
                appState?.saveRoutine(routine)
                
                // Update state
                planState = .loaded(routine)
                showSaveConfirmation = true
                
                // Hide confirmation after 2 seconds
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                showSaveConfirmation = false
                
            } catch let error as APIError {
                guard !Task.isCancelled else { return }
                planState = .failed(error)
                alertState = AlertState.error(error) { [weak self] in
                    self?.generatePlan(profile: profile, appState: appState)
                }
            } catch {
                guard !Task.isCancelled else { return }
                let apiError = APIError.from(error: error)
                planState = .failed(apiError)
                alertState = AlertState.error(apiError)
            }
        }
    }
    
    /// Load stub plan for testing (DEBUG only)
    func loadStubPlan() {
        let stubPlan = APIPlan.stub()
        let routine = convertToRoutine(stubPlan)
        storage.saveRoutine(routine)
        planState = .loaded(routine)
        showSaveConfirmation = true
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showSaveConfirmation = false
        }
    }
    
    /// Dismiss alert
    func dismissAlert() {
        alertState = nil
    }
    
    // MARK: - Private Helpers
    
    /// Convert APIPlan to Routine
    private func convertToRoutine(_ apiPlan: APIPlan) -> Routine {
        var weeklySchedule: [Weekday: [TimeBlock]] = [:]
        
        // Map time blocks
        for (dayStr, apiBlocks) in apiPlan.timeBlocks {
            guard let weekday = weekdayFrom(dayStr) else { continue }
            weeklySchedule[weekday] = apiBlocks.map { block in
                TimeBlock(
                    title: block.label,
                    description: extractDescription(from: block.label),
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
    
    private func extractDescription(from label: String) -> String {
        // Simple heuristic: use label as description
        return label
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
}

