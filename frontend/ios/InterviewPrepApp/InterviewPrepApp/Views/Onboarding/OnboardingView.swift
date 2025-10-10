//
//  OnboardingView.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isGeneratingPlan {
                    // Loading view while generating plan
                    VStack(spacing: 24) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        
                        Text("Setting up your interview prep plan...")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        Text("This may take a moment as we generate your personalized weekly routine and prep materials.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        if let error = viewModel.generationError {
                            VStack(spacing: 12) {
                                Text("Error")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Text(error)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    viewModel.completeOnboarding(appState: appState)
                                }) {
                                    Text("Try Again")
                                        .fontWeight(.semibold)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    // Skip generation and go to home
                                    viewModel.isGeneratingPlan = false
                                }) {
                                    Text("Skip for Now")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 32)
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        // Progress indicator
                        ProgressView(value: Double(viewModel.currentStep), total: 5)
                            .padding()
                        
                        // Content
                        TabView(selection: $viewModel.currentStep) {
                            WelcomeStepView()
                                .tag(0)
                            
                            NameStepView(name: $viewModel.name)
                                .tag(1)
                            
                            StageAndRoleStepView(
                                stage: $viewModel.stage,
                                targetRole: $viewModel.targetRole
                            )
                            .tag(2)
                            
                            TimeBudgetStepView(
                                hoursPerDay: $viewModel.hoursPerDay,
                                availableDays: $viewModel.availableDays
                            )
                            .tag(3)
                            
                            PreferencesStepView(
                                preferredTools: $viewModel.preferredTools
                            )
                            .tag(4)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .animation(.easeInOut, value: viewModel.currentStep)
                        
                        // Navigation buttons
                        HStack(spacing: 16) {
                            if viewModel.currentStep > 0 {
                                Button(action: {
                                    withAnimation {
                                        viewModel.previousStep()
                                    }
                                }) {
                                    Text("Back")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(12)
                                }
                            }
                            
                            Button(action: {
                                if viewModel.currentStep < 4 {
                                    withAnimation {
                                        viewModel.nextStep()
                                    }
                                } else {
                                    viewModel.completeOnboarding(appState: appState)
                                }
                            }) {
                                Text(viewModel.currentStep < 4 ? "Next" : "Get Started")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(viewModel.canProceed ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(!viewModel.canProceed)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Welcome Step

struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "star.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome to Interview Prep")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Get a personalized Mon-Fri routine and interview prep plan tailored to your goals.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "calendar", title: "Weekly Schedule", description: "AI-generated time-boxed routine")
                FeatureRow(icon: "checkmark.circle", title: "Daily Tracking", description: "Mark tasks done and build streaks")
                FeatureRow(icon: "book", title: "Prep Resources", description: "Curated learning materials")
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Name Step

struct NameStepView: View {
    @Binding var name: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("What's your name?")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("We'll use this to personalize your experience")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            TextField("Enter your name", text: $name)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .padding(.horizontal, 32)
                .padding(.top, 24)
            
            Spacer()
        }
    }
}

// MARK: - Stage and Role Step

struct StageAndRoleStepView: View {
    @Binding var stage: AcademicStage
    @Binding var targetRole: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Tell us about yourself")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("This helps us tailor your prep plan")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Stage")
                        .font(.headline)
                        .padding(.horizontal, 32)
                    
                    ForEach(AcademicStage.allCases, id: \.self) { stageOption in
                        Button(action: {
                            stage = stageOption
                        }) {
                            HStack {
                                Text(stageOption.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if stage == stageOption {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(stage == stageOption ? Color.blue.opacity(0.1) : Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                    }
                }
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target Role")
                        .font(.headline)
                        .padding(.horizontal, 32)
                    
                    TextField("e.g., iOS SWE, Backend Engineer", text: $targetRole)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 24)
                
                Spacer(minLength: 32)
            }
        }
    }
}

// MARK: - Time Budget Step

struct TimeBudgetStepView: View {
    @Binding var hoursPerDay: Double
    @Binding var availableDays: Set<Weekday>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Your Schedule")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Help us fit prep into your life")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hours per day")
                        .font(.headline)
                        .padding(.horizontal, 32)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("\(hoursPerDay, specifier: "%.1f") hours")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal, 32)
                        
                        Slider(value: $hoursPerDay, in: 0.5...8, step: 0.5)
                            .padding(.horizontal, 32)
                        
                        HStack {
                            Text("30 min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("8 hours")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 32)
                    }
                }
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Available Days")
                        .font(.headline)
                        .padding(.horizontal, 32)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(Weekday.allCases, id: \.self) { day in
                            Button(action: {
                                if availableDays.contains(day) {
                                    availableDays.remove(day)
                                } else {
                                    availableDays.insert(day)
                                }
                            }) {
                                Text(day.rawValue)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(availableDays.contains(day) ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(availableDays.contains(day) ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.top, 24)
                
                Spacer(minLength: 32)
            }
        }
    }
}

// MARK: - Preferences Step

struct PreferencesStepView: View {
    @Binding var preferredTools: [String]
    @State private var newTool: String = ""
    
    let suggestedTools = ["LeetCode", "HackerRank", "Pramp", "Cracking the Coding Interview", "System Design Primer", "Swift Playgrounds"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("Preferred Tools")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Select or add your favorite learning resources")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Suggested")
                        .font(.headline)
                        .padding(.horizontal, 32)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(suggestedTools, id: \.self) { tool in
                            Button(action: {
                                if preferredTools.contains(tool) {
                                    preferredTools.removeAll { $0 == tool }
                                } else {
                                    preferredTools.append(tool)
                                }
                            }) {
                                Text(tool)
                                    .font(.body)
                                    .foregroundColor(preferredTools.contains(tool) ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(preferredTools.contains(tool) ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add Custom")
                        .font(.headline)
                        .padding(.horizontal, 32)
                    
                    HStack {
                        TextField("Add a tool or resource", text: $newTool)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: {
                            if !newTool.isEmpty && !preferredTools.contains(newTool) {
                                preferredTools.append(newTool)
                                newTool = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .disabled(newTool.isEmpty)
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.top, 24)
                
                if !preferredTools.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Selected (\(preferredTools.count))")
                            .font(.headline)
                            .padding(.horizontal, 32)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(preferredTools, id: \.self) { tool in
                                    HStack(spacing: 4) {
                                        Text(tool)
                                            .font(.caption)
                                        
                                        Button(action: {
                                            preferredTools.removeAll { $0 == tool }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                    }
                    .padding(.top, 16)
                }
                
                Spacer(minLength: 32)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}

