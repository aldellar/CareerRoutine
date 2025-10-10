//
//  OnboardingViewModel.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var name: String = ""
    @Published var stage: AcademicStage = .secondYear
    @Published var targetRole: String = ""
    @Published var hoursPerDay: Double = 2.0
    @Published var availableDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    @Published var preferredTools: [String] = []
    
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
        
        appState.saveProfile(profile)
        
        // Generate initial routine and prep pack with mock data
        let networkService = NetworkService()
        
        Task {
            do {
                let routine = try await networkService.generateRoutine(profile: profile)
                let prepPack = try await networkService.generatePrepPack(profile: profile)
                
                await MainActor.run {
                    appState.saveRoutine(routine)
                    appState.savePrepPack(prepPack)
                }
            } catch {
                print("Error generating initial data: \(error)")
            }
        }
    }
}

