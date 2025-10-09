//
//  StorageService.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import Foundation

class StorageService {
    private let fileManager = FileManager.default
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults keys
    private let onboardingKey = "hasCompletedOnboarding"
    
    // File names
    private let profileFileName = "user_profile.json"
    private let routineFileName = "routine.json"
    private let prepPackFileName = "prep_pack.json"
    private let dailyTasksFileName = "daily_tasks.json"
    private let streakDataFileName = "streak_data.json"
    
    // MARK: - Directory Management
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func fileURL(for fileName: String) -> URL {
        documentsDirectory.appendingPathComponent(fileName)
    }
    
    // MARK: - Generic JSON Operations
    
    private func save<T: Encodable>(_ object: T, to fileName: String) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(object)
            let url = fileURL(for: fileName)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Error saving \(fileName): \(error)")
        }
    }
    
    private func load<T: Decodable>(from fileName: String) -> T? {
        let url = fileURL(for: fileName)
        
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error loading \(fileName): \(error)")
            return nil
        }
    }
    
    private func delete(fileName: String) {
        let url = fileURL(for: fileName)
        
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Error deleting \(fileName): \(error)")
            }
        }
    }
    
    // MARK: - Onboarding
    
    func hasCompletedOnboarding() -> Bool {
        userDefaults.bool(forKey: onboardingKey)
    }
    
    func setOnboardingCompleted(_ completed: Bool) {
        userDefaults.set(completed, forKey: onboardingKey)
    }
    
    // MARK: - User Profile
    
    func saveUserProfile(_ profile: UserProfile) {
        save(profile, to: profileFileName)
    }
    
    func loadUserProfile() -> UserProfile? {
        load(from: profileFileName)
    }
    
    func deleteUserProfile() {
        delete(fileName: profileFileName)
    }
    
    // MARK: - Routine
    
    func saveRoutine(_ routine: Routine) {
        save(routine, to: routineFileName)
    }
    
    func loadRoutine() -> Routine? {
        load(from: routineFileName)
    }
    
    func deleteRoutine() {
        delete(fileName: routineFileName)
    }
    
    // MARK: - Prep Pack
    
    func savePrepPack(_ pack: PrepPack) {
        save(pack, to: prepPackFileName)
    }
    
    func loadPrepPack() -> PrepPack? {
        load(from: prepPackFileName)
    }
    
    func deletePrepPack() {
        delete(fileName: prepPackFileName)
    }
    
    // MARK: - Daily Tasks
    
    func saveDailyTasks(_ tasks: [DailyTask]) {
        save(tasks, to: dailyTasksFileName)
    }
    
    func loadDailyTasks() -> [DailyTask] {
        load(from: dailyTasksFileName) ?? []
    }
    
    func deleteDailyTasks() {
        delete(fileName: dailyTasksFileName)
    }
    
    // MARK: - Streak Data
    
    func saveStreakData(_ data: StreakData) {
        save(data, to: streakDataFileName)
    }
    
    func loadStreakData() -> StreakData {
        load(from: streakDataFileName) ?? StreakData()
    }
    
    func deleteStreakData() {
        delete(fileName: streakDataFileName)
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() {
        deleteUserProfile()
        deleteRoutine()
        deletePrepPack()
        deleteDailyTasks()
        deleteStreakData()
        setOnboardingCompleted(false)
    }
}

