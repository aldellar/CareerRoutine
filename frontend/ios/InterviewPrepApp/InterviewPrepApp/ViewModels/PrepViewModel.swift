//
//  PrepViewModel.swift
//  InterviewPrepApp
//
//  View model for prep pack generation and management
//

import Foundation
import SwiftUI

@MainActor
class PrepViewModel: ObservableObject {
    @Published var prepState: Loadable<PrepPack> = .idle
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
        
        // Load existing prep pack if available
        if let prepPack = storage.loadPrepPack() {
            prepState = .loaded(prepPack)
        }
    }
    
    deinit {
        currentTask?.cancel()
    }
    
    /// Generate a new prep pack from profile
    func generatePrep(profile: UserProfile, appState: AppState? = nil) {
        // Cancel any existing task
        currentTask?.cancel()
        
        currentTask = Task {
            prepState = .loading
            
            do {
                // Convert profile to API format
                let apiProfile = APIProfile.from(profile)
                
                // Call API
                let apiPrep = try await apiClient.generatePrep(
                    profile: apiProfile
                )
                
                // Convert to local model
                let prepPack = convertToPrepPack(apiPrep)
                
                // Check if cancelled
                guard !Task.isCancelled else { return }
                
                // Save locally
                storage.savePrepPack(prepPack)
                
                // Update AppState if provided
                appState?.savePrepPack(prepPack)
                
                // Update state
                prepState = .loaded(prepPack)
                showSaveConfirmation = true
                
                // Hide confirmation after 2 seconds
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                showSaveConfirmation = false
                
            } catch let error as APIError {
                guard !Task.isCancelled else { return }
                prepState = .failed(error)
                alertState = AlertState.error(error) { [weak self] in
                    self?.generatePrep(profile: profile, appState: appState)
                }
            } catch {
                guard !Task.isCancelled else { return }
                let apiError = APIError.from(error: error)
                prepState = .failed(apiError)
                alertState = AlertState.error(apiError)
            }
        }
    }
    
    /// Load stub prep for testing (DEBUG only)
    func loadStubPrep() {
        let stubPrep = APIPrep.stub()
        let prepPack = convertToPrepPack(stubPrep)
        storage.savePrepPack(prepPack)
        prepState = .loaded(prepPack)
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
    
    /// Convert APIPrep to PrepPack
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
            practiceCadence: buildPracticeCadence(
                from: apiPrep.weeklyDrillPlan
            ),
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

