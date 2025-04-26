import Foundation
import HealthKit

/// 单位系统枚举
/// - metric: 公制单位（米、千克等）
/// - imperial: 英制单位（英寸、磅等）
@available(iOS 15.0, *)
public enum YGCUnitSystem: Sendable {
    case metric
    case imperial
}

/// 健康数据类型枚举
/// 定义了所有支持的健康数据类型及其对应的 HealthKit 标识符和单位
@available(iOS 15.0, macOS 13.0, *)
public enum YGCHealthDataType: Sendable {
    /// 身高数据
    /// - 单位：米（公制）或英寸（英制）
    /// - 标识符：HKQuantityTypeIdentifier.height
    case height
    
    /// 体重数据
    /// - 单位：千克（公制）或磅（英制）
    /// - 标识符：HKQuantityTypeIdentifier.bodyMass
    case weight
    
    /// 步数数据
    /// - 单位：步数（count）
    /// - 标识符：HKQuantityTypeIdentifier.stepCount
    case steps
    
    /// 行走/跑步距离
    /// - 单位：米（公制）或英里（英制）
    /// - 标识符：HKQuantityTypeIdentifier.distanceWalkingRunning
    case distance
    
    /// 活动能量消耗
    /// - 单位：千卡（kcal）
    /// - 标识符：HKQuantityTypeIdentifier.activeEnergyBurned
    case activeEnergy
    
    /// 运动记录
    /// - 包含各种类型的运动数据
    case workout
    
    /// 睡眠分析数据
    /// - 包含睡眠的各个阶段信息
    case sleepAnalysis
    
    /// 睡眠总时长
    /// - 单位：分钟
    case sleepDuration
    
    /// 在床上时间
    /// - 单位：分钟
    case sleepInBed
    
    /// 实际睡眠时间
    /// - 单位：分钟
    case sleepAsleep
    
    /// 清醒时间
    /// - 单位：分钟
    case sleepAwake
    
    /// 核心睡眠时间
    /// - 单位：分钟
    case sleepCore
    
    /// 深度睡眠时间
    /// - 单位：分钟
    case sleepDeep
    
    /// REM睡眠时间
    /// - 单位：分钟
    case sleepREM
    
    /// 获取 HealthKit 类型标识符
    @available(iOS 15.0, macOS 13.0, *)
    var quantityTypeIdentifier: HKQuantityTypeIdentifier? {
        switch self {
        case .height:
            return .height
        case .weight:
            return .bodyMass
        case .steps:
            return .stepCount
        case .distance:
            return .distanceWalkingRunning
        case .activeEnergy:
            return .activeEnergyBurned
        default:
            return nil
        }
    }
    
    /// 获取对应单位系统的单位
    /// - Parameter system: 单位系统（公制或英制）
    /// - Returns: 对应的 HealthKit 单位
    @available(iOS 15.0, macOS 13.0, *)
    func unit(for system: YGCUnitSystem) -> HKUnit {
        switch self {
        case .height:
            return system == .metric ? .meter() : .inch()
        case .weight:
            return system == .metric ? .gramUnit(with: .kilo) : .pound()
        case .steps:
            return .count()
        case .distance:
            return system == .metric ? .meter() : .mile()
        case .activeEnergy:
            return .kilocalorie()
        default:
            return .minute()
        }
    }
    
    /// 获取 HealthKit 对象类型
    @available(iOS 15.0, macOS 13.0, *)
    var objectType: HKObjectType {
        if let identifier = quantityTypeIdentifier {
            return HKQuantityType.quantityType(forIdentifier: identifier)!
        }
        
        switch self {
        case .workout:
            return HKObjectType.workoutType()
        case .sleepAnalysis:
            return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        case .sleepDuration:
            return HKObjectType.quantityType(forIdentifier: .appleStandTime)! // 临时使用，需要更新为正确的标识符
        case .sleepInBed:
            return HKObjectType.quantityType(forIdentifier: .appleStandTime)! // 临时使用，需要更新为正确的标识符
        case .sleepAsleep:
            return HKObjectType.quantityType(forIdentifier: .appleStandTime)! // 临时使用，需要更新为正确的标识符
        case .sleepAwake:
            return HKObjectType.quantityType(forIdentifier: .appleStandTime)! // 临时使用，需要更新为正确的标识符
        case .sleepCore:
            return HKObjectType.quantityType(forIdentifier: .appleStandTime)! // 临时使用，需要更新为正确的标识符
        case .sleepDeep:
            return HKObjectType.quantityType(forIdentifier: .appleStandTime)! // 临时使用，需要更新为正确的标识符
        case .sleepREM:
            return HKObjectType.quantityType(forIdentifier: .appleStandTime)! // 临时使用，需要更新为正确的标识符
        default:
            fatalError("Unsupported type")
        }
    }
    
    /// 所有支持的健康数据类型
    static var allTypes: [YGCHealthDataType] {
        [.height, .weight, .steps, .distance, .activeEnergy, .workout, 
         .sleepAnalysis, .sleepDuration, .sleepInBed, .sleepAsleep, 
         .sleepAwake, .sleepCore, .sleepDeep, .sleepREM]
    }
    
    /// 单位转换
    /// - Parameters:
    ///   - value: 要转换的值
    ///   - from: 源单位系统
    ///   - to: 目标单位系统
    /// - Returns: 转换后的值
    @available(iOS 15.0, macOS 13.0, *)
    func convert(_ value: Double, from: YGCUnitSystem, to: YGCUnitSystem) -> Double {
        guard from != to else { return value }
        
        let fromUnit = unit(for: from)
        let toUnit = unit(for: to)
        
        switch self {
        case .height, .weight, .distance:
            let quantity = HKQuantity(unit: fromUnit, doubleValue: value)
            return quantity.doubleValue(for: toUnit)
        default:
            return value // 其他类型不需要转换
        }
    }
} 