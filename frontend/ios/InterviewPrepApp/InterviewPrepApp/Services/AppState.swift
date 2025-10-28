//
//  AppState.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import Foundation
import Combine

class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var isGeneratingInitialContent: Bool = false
    @Published var userProfile: UserProfile?
    @Published var currentRoutine: Routine?
    @Published var prepPack: PrepPack?
    @Published var dailyTasks: [DailyTask] = []
    @Published var streakData: StreakData
    
    private let storageService: StorageService
    private var cancellables = Set<AnyCancellable>()
    
    init(storageService: StorageService = StorageService()) {
        self.storageService = storageService
        self.hasCompletedOnboarding = storageService.hasCompletedOnboarding()
        self.userProfile = storageService.loadUserProfile()
        self.currentRoutine = storageService.loadRoutine()
        self.prepPack = storageService.loadPrepPack()
        self.dailyTasks = storageService.loadDailyTasks()
        self.streakData = storageService.loadStreakData()
    }
    
    // MARK: - Profile Management
    
    func saveProfile(_ profile: UserProfile) {
        var updatedProfile = profile
        updatedProfile.updatedAt = Date()
        self.userProfile = updatedProfile
        storageService.saveUserProfile(updatedProfile)
        // Don't set onboarding as completed yet - wait for content generation
    }
    
    func completeOnboarding() {
        storageService.setOnboardingCompleted(true)
        self.hasCompletedOnboarding = true
    }
    
    func updateProfile(_ profile: UserProfile) {
        saveProfile(profile)
    }
    
    // MARK: - Routine Management
    
    func saveRoutine(_ routine: Routine) {
        var updatedRoutine = routine
        updatedRoutine.updatedAt = Date()
        self.currentRoutine = updatedRoutine
        storageService.saveRoutine(updatedRoutine)
        
        // Generate daily tasks for the current week
        generateDailyTasksFromRoutine(updatedRoutine)
    }
    
    func regenerateRoutine() {
        // This will be connected to backend later
        // For now, just increment version
        if var routine = currentRoutine {
            routine.version += 1
            routine.updatedAt = Date()
            saveRoutine(routine)
        }
    }
    
    private func generateDailyTasksFromRoutine(_ routine: Routine) {
        let calendar = Calendar.current
        let today = Date()
        
        // Generate tasks for the next 7 days
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            let weekday = getWeekday(from: date)
            
            if let timeBlocks = routine.weeklySchedule[weekday] {
                for block in timeBlocks {
                    // Check if task already exists for this date and block
                    let existingTask = dailyTasks.first { task in
                        task.timeBlockId == block.id &&
                        calendar.isDate(task.date, inSameDayAs: date)
                    }
                    
                    if existingTask == nil {
                        let newTask = DailyTask(
                            timeBlockId: block.id,
                            date: date,
                            status: .pending
                        )
                        dailyTasks.append(newTask)
                    }
                }
            }
        }
        
        storageService.saveDailyTasks(dailyTasks)
    }
    
    // MARK: - Task Management
    
    func updateTaskStatus(_ taskId: UUID, status: TaskStatus) {
        if let index = dailyTasks.firstIndex(where: { $0.id == taskId }) {
            let oldStatus = dailyTasks[index].status
            dailyTasks[index].status = status
            storageService.saveDailyTasks(dailyTasks)
            
            // Update completion count and streak based on status change
            updateCompletionCountAndStreak(oldStatus: oldStatus, newStatus: status)
        }
    }
    
    private func updateCompletionCountAndStreak(oldStatus: TaskStatus, newStatus: TaskStatus) {
        if oldStatus == .done && newStatus != .done {
            // Unmarking a task - decrement total and potentially update streak
            streakData.totalTasksCompleted = max(0, streakData.totalTasksCompleted - 1)
            updateStreakForUnmarking()
            storageService.saveStreakData(streakData)
        } else if newStatus == .done && oldStatus != .done {
            // Marking a task as done - increment total and update streak
            updateStreak()
        }
    }
    
    private func updateStreakForUnmarking() {
        let calendar = Calendar.current
        let today = Date()
        
        // Check if there are any completed tasks for today
        let todayTasks = getTasksForToday()
        let hasCompletedToday = todayTasks.contains { $0.task.status == .done }
        
        // If no tasks completed today, check if we need to adjust the streak
        if !hasCompletedToday {
            if let lastDate = streakData.lastCompletedDate {
                let todayStartOfDay = calendar.startOfDay(for: today)
                let lastDateStartOfDay = calendar.startOfDay(for: lastDate)
                
                // If last completed date was today, we need to handle the streak
                if calendar.isDate(todayStartOfDay, inSameDayAs: lastDateStartOfDay) {
                    // Check if there were any completed tasks on previous days
                    let allTasksCompleted = getTotalCompletedTasks()
                    
                    if allTasksCompleted == 0 {
                        // No tasks completed at all, reset streak
                        streakData.currentStreak = 0
                        streakData.lastCompletedDate = nil
                    } else {
                        // Find the most recent completion date
                        let recentCompletions = dailyTasks.filter { $0.status == .done }
                        if let mostRecentDate = recentCompletions.map({ $0.date }).max() {
                            streakData.lastCompletedDate = mostRecentDate
                            
                            // Recalculate streak from the most recent completion
                            recalculateStreakFrom(mostRecentDate)
                        } else {
                            streakData.lastCompletedDate = nil
                        }
                    }
                }
            }
        }
    }
    
    private func getTotalCompletedTasks() -> Int {
        return dailyTasks.filter { $0.status == .done }.count
    }
    
    private func recalculateStreakFrom(_ lastCompletedDate: Date) {
        let calendar = Calendar.current
        
        // Group completed tasks by date
        let completedTasksByDate = Dictionary(grouping: dailyTasks.filter { $0.status == .done }) { task in
            calendar.startOfDay(for: task.date)
        }
        
        // Count consecutive days going backwards from the most recent completion
        var currentStreak = 0
        var dateToCheck = calendar.startOfDay(for: lastCompletedDate)
        
        // Check up to 30 days back to find the streak
        for _ in 0..<30 {
            if let tasksForDate = completedTasksByDate[dateToCheck], !tasksForDate.isEmpty {
                currentStreak += 1
            } else {
                break
            }
            
            if let prevDay = calendar.date(byAdding: .day, value: -1, to: dateToCheck) {
                dateToCheck = prevDay
            } else {
                break
            }
        }
        
        streakData.currentStreak = max(0, currentStreak)
    }
    
    func addTaskNote(_ taskId: UUID, note: String) {
        if let index = dailyTasks.firstIndex(where: { $0.id == taskId }) {
            dailyTasks[index].notes = note
            storageService.saveDailyTasks(dailyTasks)
        }
    }
    
    func getTasksForToday() -> [(task: DailyTask, block: TimeBlock)] {
        let calendar = Calendar.current
        let today = Date()
        
        let todayTasks = dailyTasks.filter { calendar.isDate($0.date, inSameDayAs: today) }
        
        print("🔍 getTasksForToday() called")
        print("   - Found \(todayTasks.count) daily tasks for today")
        print("   - Current routine exists: \(currentRoutine != nil)")
        
        if let routine = currentRoutine {
            print("   - Routine has schedule for: \(routine.weeklySchedule.keys)")
            for (day, blocks) in routine.weeklySchedule {
                print("     \(day): \(blocks.count) blocks")
                for block in blocks {
                    print("       - '\(block.title)' - \(block.durationHours) hours")
                }
            }
        }
        
        return todayTasks.compactMap { task in
            guard let routine = currentRoutine else { return nil }
            
            // Find the corresponding time block
            for (_, blocks) in routine.weeklySchedule {
                if let block = blocks.first(where: { $0.id == task.timeBlockId }) {
                    print("   ✅ Matched task with block '\(block.title)' - \(block.durationHours) hours")
                    return (task, block)
                }
            }
            print("   ❌ Could not find block for task ID: \(task.timeBlockId)")
            return nil
        }
    }
    
    // MARK: - Streak Management
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        // Get start of day for both dates to compare days without time
        let todayStartOfDay = calendar.startOfDay(for: today)
        
        streakData.totalTasksCompleted += 1
        
        if let lastDate = streakData.lastCompletedDate {
            let lastDateStartOfDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastDateStartOfDay, to: todayStartOfDay).day ?? 0
            
            if daysDifference == 0 {
                // Same day, don't update streak but still update lastCompletedDate timestamp
                streakData.lastCompletedDate = today
                storageService.saveStreakData(streakData)
                return
            } else if daysDifference == 1 {
                // Consecutive day
                streakData.currentStreak += 1
            } else {
                // Streak broken (more than 1 day gap)
                streakData.currentStreak = 1
            }
        } else {
            // First completion
            streakData.currentStreak = 1
        }
        
        streakData.lastCompletedDate = today
        
        if streakData.currentStreak > streakData.longestStreak {
            streakData.longestStreak = streakData.currentStreak
        }
        
        storageService.saveStreakData(streakData)
    }
    
    // MARK: - Prep Pack Management
    
    func savePrepPack(_ pack: PrepPack) {
        var updatedPack = pack
        updatedPack.updatedAt = Date()
        self.prepPack = updatedPack
        storageService.savePrepPack(updatedPack)
    }
    
    func regenerateResources() {
        // This will be connected to backend later
        if var pack = prepPack {
            pack.updatedAt = Date()
            savePrepPack(pack)
        }
    }
    
    func regenerateMockPrompts() {
        // This will be connected to backend later
        if var pack = prepPack {
            pack.updatedAt = Date()
            savePrepPack(pack)
        }
    }
    
    // MARK: - Helpers
    
    private func getWeekday(from date: Date) -> Weekday {
        let calendar = Calendar.current
        let weekdayInt = calendar.component(.weekday, from: date)
        
        // Calendar.current.component(.weekday, ...) returns 1 for Sunday, 2 for Monday, etc.
        switch weekdayInt {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
    
    func resetOnboarding() {
        storageService.setOnboardingCompleted(false)
        hasCompletedOnboarding = false
        userProfile = nil
        currentRoutine = nil
        prepPack = nil
        dailyTasks = []
        streakData = StreakData()
    }
}

