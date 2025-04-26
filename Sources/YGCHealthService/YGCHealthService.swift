import Foundation
import HealthKit

/// 健康服务错误类型
public enum YGCHealthServiceError: Error {
    /// 未授权访问健康数据
    case notAuthorized
    /// 健康数据不可用
    case dataNotAvailable
    /// 无效的数据类型
    case invalidDataType
    /// 其他错误
    case other(Error)
}

/// 健康数据服务类
/// 用于访问和管理健康数据
@available(iOS 15.0, macOS 13.0, *)
public final class YGCHealthService: @unchecked Sendable {
    /// 单例实例
    public static let shared = YGCHealthService()
    
    /// HealthKit 存储实例
    private let healthStore: HKHealthStore
    
    /// 单位系统
    private let lock = NSLock()
    private var _unitSystem: YGCUnitSystem = .metric
    
    private var unitSystem: YGCUnitSystem {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _unitSystem
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _unitSystem = newValue
        }
    }
    
    /// 私有初始化方法
    private init() {
        healthStore = HKHealthStore()
    }
    
    /// 请求访问健康数据的权限
    /// - Parameter types: 需要访问的健康数据类型数组
    /// - Returns: 是否成功获取权限
    public func requestAuthorization(for types: [YGCHealthDataType]) async throws -> Bool {
        let typesToRead = Set(types.map { $0.objectType })
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            return true
        } catch {
            throw YGCHealthServiceError.notAuthorized
        }
    }
    
    /// 查询指定时间范围内的健康数据
    /// - Parameters:
    ///   - type: 健康数据类型
    ///   - timeRange: 时间范围
    ///   - options: 查询选项
    /// - Returns: 查询结果数组
    public func queryHealthData(type: YGCHealthDataType, timeRange: YGCTimeRange, options: HKStatisticsOptions = .cumulativeSum) async throws -> [HKSample] {
        let predicate = timeRange.predicate
        
        let samples: [HKSample]
        
        switch type {
        case .workout:
            samples = try await queryWorkouts(predicate: predicate)
        case .sleepAnalysis:
            samples = try await querySleepAnalysis(predicate: predicate)
        default:
            samples = try await queryQuantityType(type: type, predicate: predicate, options: options)
        }
        
        return samples
    }
    
    /// 查询运动数据
    /// - Parameter predicate: 查询条件
    /// - Returns: 运动数据数组
    private func queryWorkouts(predicate: NSPredicate) async throws -> [HKSample] {
        let workoutType = HKObjectType.workoutType()
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: YGCHealthServiceError.other(error))
                    return
                }
                continuation.resume(returning: samples ?? [])
            }
            
            healthStore.execute(query)
        }
    }
    
    /// 查询睡眠分析数据
    /// - Parameter predicate: 查询条件
    /// - Returns: 睡眠数据数组
    private func querySleepAnalysis(predicate: NSPredicate) async throws -> [HKSample] {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw YGCHealthServiceError.invalidDataType
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: YGCHealthServiceError.other(error))
                    return
                }
                continuation.resume(returning: samples ?? [])
            }
            
            healthStore.execute(query)
        }
    }
    
    /// 查询数量类型的健康数据
    /// - Parameters:
    ///   - type: 健康数据类型
    ///   - predicate: 查询条件
    ///   - options: 查询选项
    /// - Returns: 健康数据数组
    private func queryQuantityType(type: YGCHealthDataType, predicate: NSPredicate, options: HKStatisticsOptions) async throws -> [HKSample] {
        guard let quantityType = type.quantityTypeIdentifier.flatMap({ HKQuantityType.quantityType(forIdentifier: $0) }) else {
            throw YGCHealthServiceError.invalidDataType
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: YGCHealthServiceError.other(error))
                    return
                }
                continuation.resume(returning: samples ?? [])
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Generic Health Data Access
    
    private func getLatestSample(for type: YGCHealthDataType) async throws -> Double? {
        guard type != .workout else { return nil }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type.objectType as! HKQuantityType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: YGCHealthServiceError.other(error))
                    return
                }
                if let sample = samples?.first as? HKQuantitySample {
                    continuation.resume(returning: sample.quantity.doubleValue(for: type.unit(for: self.unitSystem)))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    private func getStatistics(for type: YGCHealthDataType, timeRange: YGCTimeRange) async throws -> Double {
        guard type != .workout else { return 0 }
        guard let quantityType = type.objectType as? HKQuantityType else {
            throw YGCHealthServiceError.invalidDataType
        }
        
        let range = timeRange.dateRange
        let predicate = HKQuery.predicateForSamples(withStart: range.start, end: range.end, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error = error {
                    continuation.resume(throwing: YGCHealthServiceError.other(error))
                    return
                }
                let value = statistics?.sumQuantity()?.doubleValue(for: type.unit(for: self.unitSystem)) ?? 0
                continuation.resume(returning: value)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Height
    
    public func getHeight() async throws -> Double? {
        try await getLatestSample(for: .height)
    }
    
    // MARK: - Weight
    
    public func getWeight() async throws -> Double? {
        try await getLatestSample(for: .weight)
    }
    
    // MARK: - Steps
    
    public func getSteps(for timeRange: YGCTimeRange) async throws -> Double {
        try await getStatistics(for: .steps, timeRange: timeRange)
    }
    
    // MARK: - Distance
    
    public func getDistance(for timeRange: YGCTimeRange) async throws -> Double {
        try await getStatistics(for: .distance, timeRange: timeRange)
    }
    
    // MARK: - Active Energy
    
    public func getActiveEnergy(for timeRange: YGCTimeRange) async throws -> Double {
        try await getStatistics(for: .activeEnergy, timeRange: timeRange)
    }
    
    // MARK: - Workouts
    
    public func getWorkouts(for timeRange: YGCTimeRange) async throws -> [HKWorkout] {
        let range = timeRange.dateRange
        let predicate = HKQuery.predicateForSamples(withStart: range.start, end: range.end, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: YGCHealthServiceError.other(error))
                    return
                }
                continuation.resume(returning: samples as? [HKWorkout] ?? [])
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Sleep
    
    public func getSleepAnalysis(for timeRange: YGCTimeRange) async throws -> [HKSample] {
        let range = timeRange.dateRange
        let predicate = HKQuery.predicateForSamples(withStart: range.start, end: range.end, options: .strictStartDate)
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw YGCHealthServiceError.invalidDataType
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: YGCHealthServiceError.other(error))
                    return
                }
                continuation.resume(returning: samples ?? [])
            }
            
            healthStore.execute(query)
        }
    }
    
    public func getSleepDuration(for timeRange: YGCTimeRange) async throws -> Double {
        try await getStatistics(for: .sleepDuration, timeRange: timeRange)
    }
    
    public func getSleepInBed(for timeRange: YGCTimeRange) async throws -> Double {
        try await getStatistics(for: .sleepInBed, timeRange: timeRange)
    }
    
    public func getSleepAsleep(for timeRange: YGCTimeRange) async throws -> Double {
        try await getStatistics(for: .sleepAsleep, timeRange: timeRange)
    }
    
    public func getSleepAwake(for timeRange: YGCTimeRange) async throws -> Double {
        try await getStatistics(for: .sleepAwake, timeRange: timeRange)
    }
    
    public func getSleepCore(for timeRange: YGCTimeRange) async throws -> Double {
        try await getStatistics(for: .sleepCore, timeRange: timeRange)
    }
    
    public func getSleepDeep(for timeRange: YGCTimeRange) async throws -> Double {
        try await getStatistics(for: .sleepDeep, timeRange: timeRange)
    }
    
    public func getSleepREM(for timeRange: YGCTimeRange) async throws -> Double {
        try await getStatistics(for: .sleepREM, timeRange: timeRange)
    }
    
    // MARK: - Unit Conversion
    
    public func convert(_ value: Double, for type: YGCHealthDataType, from: YGCUnitSystem, to: YGCUnitSystem) -> Double {
        return type.convert(value, from: from, to: to)
    }
} 