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
        // Priority 2: DEBUG build - use localhost
        return URL(string: "http://localhost:8081")!
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
    static let requestTimeout: TimeInterval = 15.0
    
    /// Retry delays (exponential backoff)
    static let retryDelays: [TimeInterval] = [0.2, 0.5, 1.0]
}

