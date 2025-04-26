import Foundation

/// 时间范围类型
/// 用于指定健康数据查询的时间范围
@available(iOS 15.0, macOS 13.0, *)
public enum TimeRange {
    /// 今天
    case today
    /// 昨天
    case yesterday
    /// 最近7天
    case lastWeek
    /// 最近30天
    case lastMonth
    /// 自定义时间范围
    case custom(from: Date, to: Date)
    
    /// 获取时间范围的谓词
    var predicate: NSPredicate {
        let now = Date()
        let calendar = Calendar.current
        
        switch self {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            return NSPredicate(format: "startDate >= %@ AND startDate < %@",
                             startOfDay as NSDate,
                             now as NSDate)
            
        case .yesterday:
            let startOfYesterday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: now)!)
            let startOfToday = calendar.startOfDay(for: now)
            return NSPredicate(format: "startDate >= %@ AND startDate < %@",
                             startOfYesterday as NSDate,
                             startOfToday as NSDate)
            
        case .lastWeek:
            let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
            return NSPredicate(format: "startDate >= %@ AND startDate < %@",
                             startDate as NSDate,
                             now as NSDate)
            
        case .lastMonth:
            let startDate = calendar.date(byAdding: .day, value: -30, to: now)!
            return NSPredicate(format: "startDate >= %@ AND startDate < %@",
                             startDate as NSDate,
                             now as NSDate)
            
        case .custom(let from, let to):
            return NSPredicate(format: "startDate >= %@ AND startDate < %@",
                             from as NSDate,
                             to as NSDate)
        }
    }
    
    /// 获取时间范围的日期区间
    public var dateInterval: DateInterval {
        let now = Date()
        let calendar = Calendar.current
        
        switch self {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            return DateInterval(start: startOfDay, end: now)
            
        case .yesterday:
            let startOfYesterday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: now)!)
            let startOfToday = calendar.startOfDay(for: now)
            return DateInterval(start: startOfYesterday, end: startOfToday)
            
        case .lastWeek:
            let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
            return DateInterval(start: startDate, end: now)
            
        case .lastMonth:
            let startDate = calendar.date(byAdding: .day, value: -30, to: now)!
            return DateInterval(start: startDate, end: now)
            
        case .custom(let from, let to):
            return DateInterval(start: from, end: to)
        }
    }
    
    /// 获取时间区间的开始和结束日期
    var dateRange: (start: Date, end: Date) {
        let now = Date()
        let calendar = Calendar.current
        
        switch self {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            return (startOfDay, now)
            
        case .yesterday:
            let startOfYesterday = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -1, to: now)!)
            let startOfToday = calendar.startOfDay(for: now)
            return (startOfYesterday, startOfToday)
            
        case .lastWeek:
            let startDate = calendar.date(byAdding: .day, value: -7, to: now)!
            return (startDate, now)
            
        case .lastMonth:
            let startDate = calendar.date(byAdding: .day, value: -30, to: now)!
            return (startDate, now)
            
        case .custom(let from, let to):
            return (from, to)
        }
    }
    
    /// 获取时间区间的天数
    var days: Int {
        let range = dateRange
        return Calendar.current.dateComponents([.day], from: range.start, to: range.end).day ?? 0
    }
    
    /// 获取时间区间的本地化描述
    /// - Parameter locale: 可选的区域设置，默认为当前系统区域
    /// - Returns: 本地化的时间区间描述
    public func localizedDescription(locale: Locale? = nil) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale ?? Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        switch self {
        case .today:
            return NSLocalizedString("time_range.today", bundle: .module, comment: "Today")
        case .yesterday:
            return NSLocalizedString("time_range.yesterday", bundle: .module, comment: "Yesterday")
        case .lastWeek:
            return NSLocalizedString("time_range.last_week", bundle: .module, comment: "Last Week")
        case .lastMonth:
            return NSLocalizedString("time_range.last_month", bundle: .module, comment: "Last Month")
        case .custom(let start, let end):
            let startString = formatter.string(from: start)
            let endString = formatter.string(from: end)
            return String(format: NSLocalizedString("time_range.custom", bundle: .module, comment: "Custom date range"), startString, endString)
        }
    }
    
    /// 获取时间区间的描述（兼容旧版本）
    @available(*, deprecated, message: "Use localizedDescription(locale:) instead")
    var description: String {
        return localizedDescription()
    }
} 