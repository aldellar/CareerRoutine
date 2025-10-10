//
//  AlertState.swift
//  InterviewPrepApp
//
//  Alert state for presenting errors and messages
//

import Foundation

/// State for presenting alerts
struct AlertState: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let primaryButton: AlertButton?
    let secondaryButton: AlertButton?
    
    init(
        title: String,
        message: String,
        primaryButton: AlertButton? = AlertButton(title: "OK", action: {}),
        secondaryButton: AlertButton? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
    
    /// Create alert from APIError
    static func error(_ error: APIError, retry: (() -> Void)? = nil) -> AlertState {
        if error.isRetryable, let retry = retry {
            return AlertState(
                title: error.displayTitle,
                message: error.displayMessage,
                primaryButton: AlertButton(title: "Retry", action: retry),
                secondaryButton: AlertButton(title: "Cancel", action: {})
            )
        } else {
            return AlertState(
                title: error.displayTitle,
                message: error.displayMessage
            )
        }
    }
    
    /// Create success alert
    static func success(title: String, message: String) -> AlertState {
        return AlertState(title: title, message: message)
    }
}

/// Button configuration for alerts
struct AlertButton {
    let title: String
    let action: () -> Void
}

