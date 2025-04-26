# HomeService

一个基于 HealthKit 的 Swift 框架，提供简单易用的健康数据访问接口，支持现代 Swift 特性如 async/await。

## 功能特点

- 支持公制和英制单位系统
- 提供健康数据读写权限管理
- 支持多种健康数据类型：
  - 基础数据：身高、体重
  - 运动数据：步数、距离、活动能量
  - 睡眠数据：睡眠分析、睡眠时长、各阶段睡眠时间
  - 运动记录：各类运动数据
- 使用现代 Swift 特性：
  - async/await 异步编程
  - actor 模型保证线程安全
  - 类型安全的数据访问
- 支持单位系统转换

## 系统要求

- iOS 15.0+
- Xcode 13.0+
- Swift 5.9+

## 安装方法

### Swift Package Manager

在 `Package.swift` 中添加以下依赖：

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/HomeService.git", from: "1.0.0")
]
```

或者在 Xcode 中：
1. 选择 File > Add Packages...
2. 输入包地址
3. 选择目标并点击 "Add Package"

## 使用说明

### 初始化

```swift
import HomeService

// 使用默认公制单位
let healthService = HealthService()

// 或指定英制单位
let healthService = HealthService(unitSystem: .imperial)
```

### 请求权限

```swift
do {
    try await healthService.requestAuthorization()
} catch {
    print("请求权限失败: \(error)")
}
```

### 获取基础健康数据

```swift
// 获取身高
if let height = try await healthService.getHeight() {
    print("身高: \(height) 米") // 或英寸（取决于单位系统）
}

// 获取体重
if let weight = try await healthService.getWeight() {
    print("体重: \(weight) 千克") // 或磅（取决于单位系统）
}
```

### 获取运动数据

```swift
// 获取今日步数
let steps = try await healthService.getSteps(for: Date())
print("今日步数: \(steps)")

// 获取今日行走距离
let distance = try await healthService.getDistance(for: Date())
print("今日距离: \(distance) 米") // 或英里（取决于单位系统）

// 获取今日活动能量
let energy = try await healthService.getActiveEnergy(for: Date())
print("今日活动能量: \(energy) 千卡")
```

### 获取睡眠数据

```swift
// 获取睡眠分析数据
let sleepAnalysis = try await healthService.getSleepAnalysis(for: Date())
for sample in sleepAnalysis {
    if let categorySample = sample as? HKCategorySample {
        print("睡眠阶段: \(categorySample.value)")
    }
}

// 获取睡眠时长
let sleepDuration = try await healthService.getSleepDuration(for: Date())
print("睡眠时长: \(sleepDuration) 分钟")

// 获取床上时间
let sleepInBed = try await healthService.getSleepInBed(for: Date())
print("床上时间: \(sleepInBed) 分钟")

// 获取实际睡眠时间
let sleepAsleep = try await healthService.getSleepAsleep(for: Date())
print("实际睡眠时间: \(sleepAsleep) 分钟")

// 获取清醒时间
let sleepAwake = try await healthService.getSleepAwake(for: Date())
print("清醒时间: \(sleepAwake) 分钟")

// 获取核心睡眠时间
let sleepCore = try await healthService.getSleepCore(for: Date())
print("核心睡眠时间: \(sleepCore) 分钟")

// 获取深度睡眠时间
let sleepDeep = try await healthService.getSleepDeep(for: Date())
print("深度睡眠时间: \(sleepDeep) 分钟")

// 获取REM睡眠时间
let sleepREM = try await healthService.getSleepREM(for: Date())
print("REM睡眠时间: \(sleepREM) 分钟")
```

### 获取运动记录

```swift
// 获取今日运动记录
let workouts = try await healthService.getWorkouts(for: Date())
for workout in workouts {
    print("运动类型: \(workout.workoutActivityType), 时长: \(workout.duration) 秒")
}
```

### 单位系统转换

```swift
// 切换单位系统
healthService.setUnitSystem(.imperial) // 切换到英制
healthService.setUnitSystem(.metric)   // 切换回公制

// 获取当前单位系统
let currentSystem = healthService.getUnitSystem()

// 手动转换单位
let heightInMeters = healthService.convert(70, for: .height, from: .imperial, to: .metric)
print("70英寸 = \(heightInMeters)米")
```

## 注意事项

1. 使用前需要确保在 Info.plist 中添加必要的隐私权限描述：
   - NSHealthShareUsageDescription
   - NSHealthUpdateUsageDescription

2. 首次使用需要用户授权访问健康数据

3. 某些健康数据可能不可用，取决于：
   - 用户是否允许访问
   - 设备是否支持
   - 用户是否记录了相关数据

## 许可证

本项目采用 MIT 许可证 - 详见 LICENSE 文件。 