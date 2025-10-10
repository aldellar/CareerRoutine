//
//  APIError.swift
//  InterviewPrepApp
//
//  Network error types with comprehensive coverage
//

import Foundation

/// Comprehensive error type for network operations
enum APIError: Error, Equatable {
    case networkUnavailable
    case timeout
    case server(status: Int, message: String?)
    case decoding(message: String)
    case invalidURL
    case cancelled
    case unknown(underlying: String)
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.networkUnavailable, .networkUnavailable),
             (.timeout, .timeout),
             (.invalidURL, .invalidURL),
             (.cancelled, .cancelled):
            return true
        case let (.server(lStatus, lMsg), .server(rStatus, rMsg)):
            return lStatus == rStatus && lMsg == rMsg
        case let (.decoding(lMsg), .decoding(rMsg)):
            return lMsg == rMsg
        case let (.unknown(lMsg), .unknown(rMsg)):
            return lMsg == rMsg
        default:
            return false
        }
    }
}

// MARK: - Error Mapping

extension APIError {
    /// Map URLError to APIError
    static func from(urlError: URLError) -> APIError {
        switch urlError.code {
        case .timedOut:
            return .timeout
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkUnavailable
        case .cancelled:
            return .cancelled
        default:
            return .unknown(underlying: urlError.localizedDescription)
        }
    }
    
    /// Map generic Error to APIError
    static func from(error: Error) -> APIError {
        if let urlError = error as? URLError {
            return from(urlError: urlError)
        } else if let apiError = error as? APIError {
            return apiError
        } else {
            return .unknown(underlying: error.localizedDescription)
        }
    }
}

// MARK: - Server Error Response

/// Server error response structure
struct ServerErrorResponse: Codable {
    let error: String
    let details: String?
    let traceId: String?
}

