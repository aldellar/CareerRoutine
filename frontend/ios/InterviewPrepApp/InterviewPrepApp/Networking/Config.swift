//
//  Config.swift
//  InterviewPrepApp
//
//  API configuration with environment-specific base URLs
//

import Foundation

struct APIConfig {
    /// Base URL for API requests
    static var baseURL: URL {
        // Priority 1: UserDefaults override (for developer testing)
        if let overrideString = UserDefaults.standard
            .string(forKey: "api_base"),
           !overrideString.isEmpty,
           let overrideURL = URL(string: overrideString) {
            return overrideURL
        }
        
        #if DEBUG
        // Priority 2: DEBUG build
        // Note: localhost only works on simulator
        // For physical devices, you need to use your Mac's local IP
        // Example: http://192.168.1.100:8081
        #if targetEnvironment(simulator)
        return URL(string: "http://localhost:8081")!
        #else
        // Running on physical device - need local IP
        // This will fail unless you set it in Settings
        if let localIP = UserDefaults.standard.string(forKey: "api_base"),
           !localIP.isEmpty,
           let url = URL(string: localIP) {
            return url
        }
        // Fallback to localhost (will likely fail on device)
        print("⚠️ WARNING: Using localhost on physical device. Set your Mac's IP in Settings!")
        print("⚠️ Find your Mac's IP: System Preferences -> Network")
        print("⚠️ Example: http://192.168.1.100:8081")
        return URL(string: "http://localhost:8081")!
        #endif
        #else
        // Priority 3: RELEASE build - read from Info.plist
        if let urlString = Bundle.main
            .object(forInfoDictionaryKey: "API_BASE_URL") as? String,
           let url = URL(string: urlString) {
            return url
        }
        
        // Fallback (should not happen in production)
        fatalError("API_BASE_URL not configured in Info.plist")
        #endif
    }
    
    /// Request timeout in seconds
    static let requestTimeout: TimeInterval = 30.0  // Increased for OpenAI calls
    
    /// Retry delays (exponential backoff)
    static let retryDelays: [TimeInterval] = [0.5, 1.0, 2.0]
    
    /// Get instructions for configuring API on physical device
    static func getSetupInstructions() -> String {
        #if targetEnvironment(simulator)
        return "Simulator: Using localhost:8081"
        #else
        return """
        Physical Device Setup:
        1. Find your Mac's local IP:
           • Open System Settings/Preferences
           • Go to Network
           • Your IP is shown (e.g., 192.168.1.100)
        2. Go to Settings in the app
        3. Set API URL to: http://YOUR_IP:8081
        4. Make sure your Mac and iPhone are on the same WiFi
        """
        #endif
    }
}

