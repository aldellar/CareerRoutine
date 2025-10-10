//
//  InterviewPrepAppApp.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import SwiftUI

@main
struct InterviewPrepAppApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

