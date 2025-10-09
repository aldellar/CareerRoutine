# iOS App Integration Guide

This guide shows how to integrate the CareerRoutine API with your iOS app.

## 🔗 API Endpoints

**Base URL:** `http://localhost:8081` (development)

### Available Endpoints

1. **Generate Routine:** `POST /generate/routine`
2. **Generate Prep Pack:** `POST /generate/prep`
3. **Reroll Section:** `POST /reroll/{section}`
4. **Health Check:** `GET /health`

---

## 📱 Swift Integration Example

### 1. Define Models

```swift
// Profile.swift
struct Profile: Codable {
    let name: String
    let stage: String
    let targetRole: String
    let timeBudgetHoursPerDay: Double
    let availableDays: [String]
    let constraints: [String]?
}

// Plan.swift
struct Plan: Codable {
    let weekOf: String
    let timeBlocks: [String: [TimeBlock]]
    let dailyTasks: [String: [String]]
    let milestones: [String]
    let resources: [Resource]
    let version: Int
}

struct TimeBlock: Codable {
    let start: String
    let end: String
    let label: String
}

struct Resource: Codable {
    let title: String
    let url: String
}

// PrepPack.swift
struct PrepPack: Codable {
    let prepOutline: [PrepSection]
    let weeklyDrillPlan: [DrillDay]
    let starterQuestions: [String]
    let resources: [Resource]
}

struct PrepSection: Codable {
    let section: String
    let items: [String]
}

struct DrillDay: Codable {
    let day: String
    let drills: [String]
}
```

### 2. Create API Service

```swift
// APIService.swift
import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8081"
    
    private init() {}
    
    // MARK: - Generate Routine
    
    func generateRoutine(profile: Profile) async throws -> Plan {
        let url = URL(string: "\(baseURL)/generate/routine")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["profile": profile]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        let result = try JSONDecoder().decode(RoutineResponse.self, from: data)
        return result.plan
    }
    
    // MARK: - Generate Prep Pack
    
    func generatePrepPack(profile: Profile) async throws -> PrepPack {
        let url = URL(string: "\(baseURL)/generate/prep")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["profile": profile]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        let result = try JSONDecoder().decode(PrepResponse.self, from: data)
        return result.prep
    }
    
    // MARK: - Reroll Section
    
    func rerollSection(
        _ section: String,
        profile: Profile,
        currentPlan: Plan
    ) async throws -> RerollResult {
        let url = URL(string: "\(baseURL)/reroll/\(section)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "profile": try JSONEncoder().encode(profile),
            "currentPlan": try JSONEncoder().encode(currentPlan)
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        let result = try JSONDecoder().decode(RerollResult.self, from: data)
        return result
    }
}

// MARK: - Response Types

private struct RoutineResponse: Codable {
    let plan: Plan
}

private struct PrepResponse: Codable {
    let prep: PrepPack
}

struct RerollResult: Codable {
    let timeBlocks: [String: [TimeBlock]]?
    let resources: [Resource]?
    let dailyTasks: [String: [String]]?
}

// MARK: - Error Types

enum APIError: Error {
    case requestFailed
    case invalidResponse
    case decodingFailed
}
```

### 3. Usage in SwiftUI

```swift
// HomeViewModel.swift
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var currentPlan: Plan?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func generateNewRoutine(for profile: Profile) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let plan = try await APIService.shared.generateRoutine(profile: profile)
            currentPlan = plan
        } catch {
            errorMessage = "Failed to generate routine: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func rerollResources(profile: Profile) async {
        guard let currentPlan = currentPlan else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await APIService.shared.rerollSection(
                "resources",
                profile: profile,
                currentPlan: currentPlan
            )
            
            if let newResources = result.resources {
                var updatedPlan = currentPlan
                updatedPlan.resources = newResources
                self.currentPlan = updatedPlan
            }
        } catch {
            errorMessage = "Failed to reroll resources: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// HomeView.swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var userProfile: Profile
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Generating routine...")
            } else if let plan = viewModel.currentPlan {
                PlanView(plan: plan)
                
                Button("Reroll Resources") {
                    Task {
                        await viewModel.rerollResources(profile: userProfile)
                    }
                }
            } else {
                Button("Generate Routine") {
                    Task {
                        await viewModel.generateNewRoutine(for: userProfile)
                    }
                }
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
    }
}
```

---

## 🔧 Configuration

### Update NetworkService.swift

Add the API base URL to your existing `NetworkService.swift`:

```swift
class NetworkService {
    static let shared = NetworkService()
    
    #if DEBUG
    let baseURL = "http://localhost:8081"
    #else
    let baseURL = "https://api.careerroutine.com"
    #endif
    
    // ... rest of implementation
}
```

### Info.plist Configuration

Allow local network access for development:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

---

## 🧪 Testing

### Test with Sample Data

```swift
let testProfile = Profile(
    name: "Andrew",
    stage: "recent_grad",
    targetRole: "iOS Software Engineer",
    timeBudgetHoursPerDay: 3.0,
    availableDays: ["Mon", "Tue", "Wed", "Thu", "Fri"],
    constraints: ["no weekends"]
)

Task {
    do {
        let plan = try await APIService.shared.generateRoutine(profile: testProfile)
        print("Generated plan for week of: \(plan.weekOf)")
        print("Total milestones: \(plan.milestones.count)")
    } catch {
        print("Error: \(error)")
    }
}
```

---

## 🚀 Production Deployment

### Update Base URL

When deploying to production:

1. Deploy the API to a cloud provider (AWS, Heroku, Railway, etc.)
2. Get your production URL (e.g., `https://api.careerroutine.com`)
3. Update `baseURL` in your iOS app:

```swift
#if DEBUG
let baseURL = "http://localhost:8081"
#else
let baseURL = "https://api.careerroutine.com"  // Your production URL
#endif
```

### Update Info.plist

Remove local network exceptions for production builds:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

---

## 📊 Error Handling

Handle API errors gracefully:

```swift
func handleAPIError(_ error: Error) -> String {
    if let apiError = error as? APIError {
        switch apiError {
        case .requestFailed:
            return "Network request failed. Please check your connection."
        case .invalidResponse:
            return "Invalid response from server."
        case .decodingFailed:
            return "Failed to process server response."
        }
    }
    return "An unexpected error occurred: \(error.localizedDescription)"
}
```

---

## 💡 Best Practices

1. **Cache Plans Locally:** Use CoreData or UserDefaults to cache generated plans
2. **Handle Timeouts:** Set appropriate timeout intervals for API calls
3. **Retry Logic:** Implement retry logic for failed requests
4. **Loading States:** Show loading indicators during API calls
5. **Error Messages:** Display user-friendly error messages
6. **Offline Support:** Keep last generated plan available offline

---

## 🔍 Debugging

### Enable Network Logging

```swift
URLSession.shared.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

// Add to your request
#if DEBUG
print("Request URL: \(request.url?.absoluteString ?? "")")
print("Request Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
#endif
```

### Check Server Logs

Monitor the backend server logs for request tracing:

```bash
# In terminal where server is running
npm run dev

# Look for traceId in logs to correlate requests
```

---

## 📞 Support

If you encounter issues:

1. Check server is running: `curl http://localhost:8081/health`
2. Verify API key is set in backend `.env` file
3. Check iOS simulator/device can reach localhost
4. Review backend logs for error details

---

For more details, see [README_BACKEND.md](./README_BACKEND.md)

