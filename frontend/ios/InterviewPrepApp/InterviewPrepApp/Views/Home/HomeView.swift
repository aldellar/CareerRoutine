//
//  HomeView.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .today
    
    enum Tab {
        case week
        case today
        case prep
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Bar
                HStack(spacing: 0) {
                    TabButton(
                        icon: "calendar",
                        title: "Week",
                        isSelected: selectedTab == .week
                    ) {
                        selectedTab = .week
                    }
                    
                    TabButton(
                        icon: "checkmark.circle",
                        title: "Today",
                        isSelected: selectedTab == .today
                    ) {
                        selectedTab = .today
                    }
                    
                    TabButton(
                        icon: "book",
                        title: "Prep",
                        isSelected: selectedTab == .prep
                    ) {
                        selectedTab = .prep
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Content
                TabView(selection: $selectedTab) {
                    WeekView()
                        .tag(Tab.week)
                    
                    TodayView()
                        .tag(Tab.today)
                    
                    PrepView()
                        .tag(Tab.prep)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    private var navigationTitle: String {
        switch selectedTab {
        case .week: return "Weekly Plan"
        case .today: return "Today"
        case .prep: return "Interview Prep"
        }
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .symbolVariant(isSelected ? .fill : .none)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .blue : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}

