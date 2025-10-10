//
//  APIClient.swift
//  InterviewPrepApp
//
//  Core networking layer with retry, timeout, and error handling
//

import Foundation

/// Protocol for URLSession to enable testing
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// Main API client for backend communication
actor APIClient {
    private let session: URLSessionProtocol
    private let baseURL: URL
    private let timeout: TimeInterval
    
    init(
        session: URLSessionProtocol = URLSession.shared,
        baseURL: URL = APIConfig.baseURL,
        timeout: TimeInterval = APIConfig.requestTimeout
    ) {
        self.session = session
        self.baseURL = baseURL
        self.timeout = timeout
    }
    
    // MARK: - Public API
    
    /// Health check endpoint
    func health() async -> Bool {
        do {
            let url = baseURL.appendingPathComponent("/health")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 5.0 // Shorter timeout for health check
            
            let (_, response) = try await session.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    /// Generate routine plan
    func generateRoutine(profile: APIProfile) async throws -> APIPlan {
        let body = ["profile": profile]
        let response: RoutineResponse = try await request(
            path: "/generate/routine",
            method: "POST",
            body: body,
            retryable: true
        )
        return response.plan
    }
    
    /// Generate prep pack
    func generatePrep(profile: APIProfile) async throws -> APIPrep {
        let body = ["profile": profile]
        let response: PrepResponse = try await request(
            path: "/generate/prep",
            method: "POST",
            body: body,
            retryable: true
        )
        return response.prep
    }
    
    /// Reroll a specific section
    func reroll(
        section: RerollSection,
        profile: APIProfile,
        currentPlan: APIPlan
    ) async throws -> RerollResult {
        let body: [String: Any] = [
            "profile": try encodableToDict(profile),
            "plan": try encodableToDict(currentPlan)
        ]
        
        let path = "/reroll/\(section.rawValue)"
        
        switch section {
        case .timeBlocks:
            let response: TimeBlocksRerollResponse = try await request(
                path: path,
                method: "POST",
                body: body,
                retryable: true
            )
            return .timeBlocks(response.timeBlocks)
            
        case .resources:
            let response: ResourcesRerollResponse = try await request(
                path: path,
                method: "POST",
                body: body,
                retryable: true
            )
            return .resources(response.resources)
            
        case .dailyTasks:
            let response: DailyTasksRerollResponse = try await request(
                path: path,
                method: "POST",
                body: body,
                retryable: true
            )
            return .dailyTasks(response.dailyTasks)
        }
    }
    
    // MARK: - Internal Request Handler
    
    /// Generic request with retry logic
    private func request<T: Decodable>(
        path: String,
        method: String,
        body: Any? = nil,
        retryable: Bool = false
    ) async throws -> T {
        var lastError: APIError?
        let maxAttempts = retryable ? (1 + APIConfig.retryDelays.count) : 1
        
        for attempt in 0..<maxAttempts {
            do {
                return try await performRequest(
                    path: path,
                    method: method,
                    body: body
                )
            } catch let error as APIError {
                lastError = error
                
                // Check if we should retry
                if attempt < maxAttempts - 1 && shouldRetry(error: error) {
                    let delay = APIConfig.retryDelays[attempt]
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    throw error
                }
            } catch {
                throw APIError.from(error: error)
            }
        }
        
        throw lastError ?? APIError.unknown(underlying: "Unknown error")
    }
    
    /// Perform a single request with timeout
    private func performRequest<T: Decodable>(
        path: String,
        method: String,
        body: Any? = nil
    ) async throws -> T {
        // Build URL
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add body if present
        if let body = body {
            request.httpBody = try JSONSerialization.data(
                withJSONObject: body,
                options: []
            )
        }
        
        // Execute with timeout
        let (data, response) = try await withTimeout(seconds: timeout) {
            try await self.session.data(for: request)
        }
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(underlying: "Invalid response type")
        }
        
        // Handle status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode response
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding(message: error.localizedDescription)
            }
            
        case 400...599:
            // Error response - try to decode server error
            let errorMessage = try? JSONDecoder().decode(
                ServerErrorResponse.self,
                from: data
            )
            throw APIError.server(
                status: httpResponse.statusCode,
                message: errorMessage?.error
            )
            
        default:
            throw APIError.server(
                status: httpResponse.statusCode,
                message: "Unexpected status code"
            )
        }
    }
    
    // MARK: - Retry Logic
    
    /// Determine if error is retryable
    private func shouldRetry(error: APIError) -> Bool {
        switch error {
        case .server(let status, _):
            return status >= 500
        case .networkUnavailable, .timeout:
            return true
        case .cancelled, .invalidURL, .decoding, .unknown:
            return false
        }
    }
    
    // MARK: - Helpers
    
    /// Convert Encodable to Dictionary for JSONSerialization
    private func encodableToDict<T: Encodable>(_ value: T) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        guard let dict = try JSONSerialization.jsonObject(with: data) 
            as? [String: Any] else {
            throw APIError.unknown(underlying: "Failed to convert to dictionary")
        }
        return dict
    }
}

// MARK: - Timeout Helper

/// Execute async operation with timeout
private func withTimeout<T>(
    seconds: TimeInterval,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        // Add operation task
        group.addTask {
            try await operation()
        }
        
        // Add timeout task
        group.addTask {
            try await Task.sleep(
                nanoseconds: UInt64(seconds * 1_000_000_000)
            )
            throw APIError.timeout
        }
        
        // Return first to complete (cancel others)
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

// MARK: - Supporting Types

enum RerollSection: String {
    case timeBlocks
    case resources
    case dailyTasks
}

enum RerollResult {
    case timeBlocks([String: [APITimeBlock]])
    case resources([APIResource])
    case dailyTasks([String: [String]])
}

// Response wrappers
private struct RoutineResponse: Codable {
    let plan: APIPlan
}

private struct PrepResponse: Codable {
    let prep: APIPrep
}

private struct TimeBlocksRerollResponse: Codable {
    let timeBlocks: [String: [APITimeBlock]]
}

private struct ResourcesRerollResponse: Codable {
    let resources: [APIResource]
}

private struct DailyTasksRerollResponse: Codable {
    let dailyTasks: [String: [String]]
}

