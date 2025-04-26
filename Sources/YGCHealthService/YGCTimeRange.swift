import Foundation
import HealthKit

/// 时间范围类型枚举
/// 用于定义健康数据查询的时间范围
@available(iOS 15.0, macOS 13.0, *)
public enum YGCTimeRange: Sendable {
    /// 今天
    case today
    
    /// 昨天
    case yesterday
    
    /// 最近一周
    case lastWeek
    
    /// 最近一个月
    case lastMonth
    
    /// 自定义时间范围
    /// - Parameters:
    ///   - from: 开始时间
    ///   - to: 结束时间
    case custom(from: Date, to: Date)
    
    /// 获取时间范围的开始和结束时间
    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            return (start, now)
            
        case .yesterday:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
            let start = calendar.startOfDay(for: yesterday)
            let end = calendar.startOfDay(for: now)
            return (start, end)
            
        case .lastWeek:
            let start = calendar.date(byAdding: .day, value: -7, to: now)!
            return (start, now)
            
        case .lastMonth:
            let start = calendar.date(byAdding: .month, value: -1, to: now)!
            return (start, now)
            
        case .custom(let from, let to):
            return (from, to)
        }
    }
    
    /// 生成时间范围谓词
    var predicate: NSPredicate {
        let range = dateRange
        return HKQuery.predicateForSamples(withStart: range.start, end: range.end, options: .strictStartDate)
    }
} 