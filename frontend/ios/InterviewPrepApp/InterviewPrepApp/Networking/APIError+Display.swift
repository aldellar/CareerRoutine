//
//  APIError+Display.swift
//  InterviewPrepApp
//
//  Humanized error messages for UI display
//

import Foundation

extension APIError {
    /// Human-readable error message for display
    var displayMessage: String {
        switch self {
        case .timeout:
            return "The request took too long. Please try again."
        case .networkUnavailable:
            return "You're offline. Check your connection."
        case .server(let status, let message):
            if status == 429 {
                return "Too many requests. Please try again shortly."
            } else if status >= 500 {
                return "Server issue. Please try again shortly."
            } else if let msg = message {
                return msg
            } else {
                return "Server error (\(status)). Please try again."
            }
        case .decoding(let message):
            return "Data error: \(message)"
        case .invalidURL:
            return "Invalid request URL."
        case .cancelled:
            return "Request was cancelled."
        case .unknown(let underlying):
            return "Something went wrong: \(underlying)"
        }
    }
    
    /// Short title for alerts
    var displayTitle: String {
        switch self {
        case .timeout:
            return "Timeout"
        case .networkUnavailable:
            return "Offline"
        case .server(let status, _):
            return "Server Error (\(status))"
        case .decoding:
            return "Data Error"
        case .invalidURL:
            return "Invalid URL"
        case .cancelled:
            return "Cancelled"
        case .unknown:
            return "Error"
        }
    }
    
    /// Should show retry option
    var isRetryable: Bool {
        switch self {
        case .timeout, .networkUnavailable, .server(let status, _):
            return status >= 500
        default:
            return false
        }
    }
}

