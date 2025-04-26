import XCTest
import HealthKit
@testable import YGCHealthService

@available(iOS 15.0, macOS 13.0, *)
final class YGCHealthServiceTests: XCTestCase {
    var healthService: YGCHealthService!
    
    override func setUpWithError() throws {
        healthService = YGCHealthService.shared
    }
    
    override func tearDownWithError() throws {
        healthService = nil
    }
    
    func testTimeRangeToday() {
        let timeRange = YGCTimeRange.today
        let range = timeRange.dateRange
        let calendar = Calendar.current
        
        XCTAssertEqual(calendar.startOfDay(for: range.start), range.start)
        XCTAssertLessThanOrEqual(range.end, Date())
    }
    
    func testTimeRangeYesterday() {
        let timeRange = YGCTimeRange.yesterday
        let range = timeRange.dateRange
        let calendar = Calendar.current
        let now = Date()
        
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        XCTAssertEqual(calendar.startOfDay(for: yesterday), range.start)
        XCTAssertEqual(calendar.startOfDay(for: now), range.end)
    }
    
    func testTimeRangeLastWeek() {
        let timeRange = YGCTimeRange.lastWeek
        let range = timeRange.dateRange
        let calendar = Calendar.current
        let now = Date()
        
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: now)!
        XCTAssertEqual(calendar.startOfDay(for: lastWeek), calendar.startOfDay(for: range.start))
        XCTAssertLessThanOrEqual(range.end, now)
    }
    
    func testTimeRangeLastMonth() {
        let timeRange = YGCTimeRange.lastMonth
        let range = timeRange.dateRange
        let calendar = Calendar.current
        let now = Date()
        
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
        XCTAssertEqual(calendar.startOfDay(for: lastMonth), calendar.startOfDay(for: range.start))
        XCTAssertLessThanOrEqual(range.end, now)
    }
    
    func testTimeRangeCustom() {
        let start = Date()
        let end = Date().addingTimeInterval(3600) // 1 hour later
        let timeRange = YGCTimeRange.custom(from: start, to: end)
        let range = timeRange.dateRange
        
        XCTAssertEqual(start, range.start)
        XCTAssertEqual(end, range.end)
    }
} 