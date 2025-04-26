import XCTest
import HealthKit
@testable import HomeService

@available(iOS 15.0, *)
final class HealthServiceTests: XCTestCase {
    var healthService: HealthService!
    
    override func setUp() async throws {
        healthService = HealthService()
    }
    
    func testRequestAuthorization() async throws {
        try await healthService.requestAuthorization()
        // Note: In a real test environment, you would need to mock HKHealthStore
    }
    
    func testGetHeight() async throws {
        // Note: In a real test environment, you would need to mock HKHealthStore
        // and provide sample data
        let height = try await healthService.getHeight()
        XCTAssertNotNil(height)
    }
    
    func testGetWeight() async throws {
        // Note: In a real test environment, you would need to mock HKHealthStore
        // and provide sample data
        let weight = try await healthService.getWeight()
        XCTAssertNotNil(weight)
    }
    
    func testGetSteps() async throws {
        let steps = try await healthService.getSteps(for: Date())
        XCTAssertGreaterThanOrEqual(steps, 0)
    }
    
    func testGetDistance() async throws {
        let distance = try await healthService.getDistance(for: Date())
        XCTAssertGreaterThanOrEqual(distance, 0)
    }
    
    func testGetActiveEnergy() async throws {
        let energy = try await healthService.getActiveEnergy(for: Date())
        XCTAssertGreaterThanOrEqual(energy, 0)
    }
    
    func testGetWorkouts() async throws {
        let workouts = try await healthService.getWorkouts(for: Date())
        XCTAssertNotNil(workouts)
    }
} 