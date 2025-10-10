//
//  APIClientTests.swift
//  InterviewPrepAppTests
//
//  Unit tests for APIClient with mock URLSession
//

import XCTest
@testable import InterviewPrepApp

final class APIClientTests: XCTestCase {
    
    var mockSession: MockURLSession!
    var apiClient: APIClient!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        apiClient = APIClient(
            session: mockSession,
            baseURL: URL(string: "http://test.com")!,
            timeout: 5.0
        )
    }
    
    override func tearDown() {
        mockSession = nil
        apiClient = nil
        super.tearDown()
    }
    
    // MARK: - Health Tests
    
    func testHealthCheckSuccess() async {
        // Given
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "http://test.com/health")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        mockSession.mockData = Data()
        
        // When
        let isHealthy = await apiClient.health()
        
        // Then
        XCTAssertTrue(isHealthy)
    }
    
    func testHealthCheckFailure() async {
        // Given
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "http://test.com/health")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        mockSession.mockData = Data()
        
        // When
        let isHealthy = await apiClient.health()
        
        // Then
        XCTAssertFalse(isHealthy)
    }
    
    // MARK: - Generate Routine Tests
    
    func testGenerateRoutineSuccess() async throws {
        // Given
        let profile = APIProfile.stub()
        let plan = APIPlan.stub()
        let responseData = try JSONEncoder().encode(
            ["plan": plan]
        )
        
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "http://test.com/generate/routine")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        mockSession.mockData = responseData
        
        // When
        let result = try await apiClient.generateRoutine(
            profile: profile
        )
        
        // Then
        XCTAssertEqual(result.weekOf, plan.weekOf)
        XCTAssertEqual(result.version, plan.version)
    }
    
    func testGenerateRoutine400Error() async {
        // Given
        let profile = APIProfile.stub()
        let errorResponse = ServerErrorResponse(
            error: "Invalid profile",
            details: "Missing required field",
            traceId: "123"
        )
        let responseData = try! JSONEncoder().encode(errorResponse)
        
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "http://test.com/generate/routine")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        mockSession.mockData = responseData
        
        // When/Then
        do {
            _ = try await apiClient.generateRoutine(profile: profile)
            XCTFail("Should have thrown error")
        } catch let error as APIError {
            if case .server(let status, let message) = error {
                XCTAssertEqual(status, 400)
                XCTAssertEqual(message, "Invalid profile")
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    func testGenerateRoutine500Error() async {
        // Given
        let profile = APIProfile.stub()
        let errorResponse = ServerErrorResponse(
            error: "Internal server error",
            details: nil,
            traceId: "456"
        )
        let responseData = try! JSONEncoder().encode(errorResponse)
        
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "http://test.com/generate/routine")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        mockSession.mockData = responseData
        
        // When/Then
        do {
            _ = try await apiClient.generateRoutine(profile: profile)
            XCTFail("Should have thrown error")
        } catch let error as APIError {
            if case .server(let status, _) = error {
                XCTAssertEqual(status, 500)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
    
    // MARK: - Error Mapping Tests
    
    func testTimeoutErrorMapping() async {
        // Given
        let profile = APIProfile.stub()
        mockSession.mockError = URLError(.timedOut)
        
        // When/Then
        do {
            _ = try await apiClient.generateRoutine(profile: profile)
            XCTFail("Should have thrown timeout error")
        } catch let error as APIError {
            XCTAssertEqual(error, .timeout)
        }
    }
    
    func testNetworkUnavailableMapping() async {
        // Given
        let profile = APIProfile.stub()
        mockSession.mockError = URLError(.notConnectedToInternet)
        
        // When/Then
        do {
            _ = try await apiClient.generateRoutine(profile: profile)
            XCTFail("Should have thrown network unavailable error")
        } catch let error as APIError {
            XCTAssertEqual(error, .networkUnavailable)
        }
    }
    
    func testDecodingError() async {
        // Given
        let profile = APIProfile.stub()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "http://test.com/generate/routine")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        mockSession.mockData = Data("invalid json".utf8)
        
        // When/Then
        do {
            _ = try await apiClient.generateRoutine(profile: profile)
            XCTFail("Should have thrown decoding error")
        } catch let error as APIError {
            if case .decoding = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Wrong error type: \(error)")
            }
        }
    }
}

// MARK: - Mock URLSession

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw URLError(.unknown)
        }
        
        return (data, response)
    }
}

// MARK: - Helper Extensions

extension APIPlan: Equatable {
    public static func == (lhs: APIPlan, rhs: APIPlan) -> Bool {
        return lhs.weekOf == rhs.weekOf && 
               lhs.version == rhs.version
    }
}

