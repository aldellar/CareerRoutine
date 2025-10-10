//
//  PrepPack.swift
//  InterviewPrepApp
//
//  Created on 10/9/2025.
//

import Foundation

struct PrepPack: Codable, Identifiable {
    let id: UUID
    var topicLadder: [PrepTopic]
    var practiceCadence: String
    var resources: [Resource]
    var mockInterviewPrompts: [String]
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        topicLadder: [PrepTopic] = [],
        practiceCadence: String = "",
        resources: [Resource] = [],
        mockInterviewPrompts: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.topicLadder = topicLadder
        self.practiceCadence = practiceCadence
        self.resources = resources
        self.mockInterviewPrompts = mockInterviewPrompts
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct PrepTopic: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var priority: Priority
    var estimatedWeeks: Int
    var subtopics: [String]
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        priority: Priority,
        estimatedWeeks: Int,
        subtopics: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.priority = priority
        self.estimatedWeeks = estimatedWeeks
        self.subtopics = subtopics
    }
}

enum Priority: String, Codable, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}

struct Resource: Codable, Identifiable {
    let id: UUID
    var title: String
    var url: String?
    var description: String
    var type: ResourceType
    
    init(
        id: UUID = UUID(),
        title: String,
        url: String? = nil,
        description: String,
        type: ResourceType
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.description = description
        self.type = type
    }
}

enum ResourceType: String, Codable, CaseIterable {
    case article = "Article"
    case video = "Video"
    case book = "Book"
    case course = "Course"
    case practice = "Practice Platform"
    case documentation = "Documentation"
    
    var icon: String {
        switch self {
        case .article: return "doc.text"
        case .video: return "play.rectangle"
        case .book: return "book.closed"
        case .course: return "graduationcap"
        case .practice: return "terminal"
        case .documentation: return "doc.plaintext"
        }
    }
}

