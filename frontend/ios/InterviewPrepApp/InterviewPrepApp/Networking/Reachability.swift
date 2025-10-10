//
//  Reachability.swift
//  InterviewPrepApp
//
//  Network connectivity monitoring using NWPathMonitor
//

import Foundation
import Network
import Combine

/// Monitors network connectivity status
@MainActor
class Reachability: ObservableObject {
    @Published private(set) var isOnline: Bool = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.interviewprep.reachability")
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
}

