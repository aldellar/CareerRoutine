//
//  Loadable.swift
//  InterviewPrepApp
//
//  State wrapper for async operations with loading/error states
//

import Foundation

/// Generic state wrapper for async operations
enum Loadable<T> {
    case idle
    case loading
    case loaded(T)
    case failed(APIError)
    
    /// Returns the loaded value if available
    var value: T? {
        if case .loaded(let value) = self {
            return value
        }
        return nil
    }
    
    /// Returns the error if in failed state
    var error: APIError? {
        if case .failed(let error) = self {
            return error
        }
        return nil
    }
    
    /// Check if currently loading
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    /// Check if has loaded value
    var hasValue: Bool {
        if case .loaded = self {
            return true
        }
        return false
    }
    
    /// Check if failed
    var hasFailed: Bool {
        if case .failed = self {
            return true
        }
        return false
    }
}

// MARK: - Equatable

extension Loadable: Equatable where T: Equatable {
    static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case let (.loaded(lValue), .loaded(rValue)):
            return lValue == rValue
        case let (.failed(lError), .failed(rError)):
            return lError == rError
        default:
            return false
        }
    }
}

