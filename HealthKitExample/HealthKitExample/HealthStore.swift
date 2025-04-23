//
//  Project: HealthKitExample
//  File: HealthStore.swift
//  Created by Noah Carpenter
//  🐱 Follow me on YouTube! 🎥
//  https://www.youtube.com/@NoahDoesCoding97
//  Like and Subscribe for coding tutorials and fun! 💻✨
//  Fun Fact: Cats have five toes on their front paws, but only four on their back paws! 🐾
//  Dream Big, Code Bigger
//

import HealthKit

// HealthStore class to manage interactions with HealthKit
class HealthStore {
    let healthStore = HKHealthStore() // Instance of HKHealthStore to access HealthKit data
    
    // MARK: - Request Permissions for HealthKit
    
    /// Requests authorization from the user to read HealthKit data
    /// - Parameter completion: Callback function that returns success status and an optional error
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Define the data types to read from HealthKit
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let spo2Type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let vo2MaxType = HKQuantityType.quantityType(forIdentifier: .vo2Max)!
        let wristTempType = HKQuantityType.quantityType(forIdentifier: .appleWalkingSteadiness)!
        let cadenceType = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!
        let elevationType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        
        let typesToRead: Set = [
            stepCountType,
            heartRateType,
            calorieType,
            spo2Type,
            hrvType,
            vo2MaxType,
            cadenceType,
            elevationType
        ]
        // Set of requested data types
        
        // Request authorization for reading (no data writing needed)
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    // MARK: - Fetch Step Count Data
    
    /// Fetches the user's step count for today from HealthKit
    /// - Parameter completion: Callback function returning the step count as a Double
    func fetchStepCount(completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)! // Step count type
        
        // Define start date as beginning of today
        let startDate = Calendar.current.startOfDay(for: Date())
        
        // Predicate to filter data for today only
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        // Create statistics query to retrieve cumulative step count
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let stepCount = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0 // Get step count value
            
            // Ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                completion(stepCount)
            }
        }
        
        healthStore.execute(query) // Execute the query
    }
    
    // MARK: - Fetch Heart Rate Data
    
    /// Fetches the user's average heart rate from the last hour
    /// - Parameter completion: Callback function returning the average heart rate as a Double
    func fetchHeartRate(completion: @escaping (Double) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)! // Heart rate type
        
        // Define start date as one hour ago
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        
        // Predicate to filter data from the last hour
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
        // Create statistics query to retrieve the average heart rate
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            let heartRate = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) ?? 0 // Get heart rate value
            
            // Ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                completion(heartRate)
            }
        }
        
        healthStore.execute(query) // Execute the query
    }
    
    func fetchBloodOxygen(completion: @escaping (Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            let value = result?.averageQuantity()?.doubleValue(for: HKUnit.percent()) ?? 0
            DispatchQueue.main.async {
                completion(value * 100) // كنسبة مئوية
            }
        }
        healthStore.execute(query)
    }
    
    func fetchHRV(completion: @escaping (Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            let value = result?.averageQuantity()?.doubleValue(for: HKUnit.secondUnit(with: .milli)) ?? 0
            DispatchQueue.main.async {
                completion(value)
            }
        }
        healthStore.execute(query)
    }
    func fetchVO2Max(completion: @escaping (Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .vo2Max)!
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            let value = result?.averageQuantity()?.doubleValue(for: HKUnit.liter().unitDivided(by: HKUnit.minute())) ?? 0
            DispatchQueue.main.async {
                completion(value)
            }
        }
        healthStore.execute(query)
    }
    func fetchCadence(completion: @escaping (Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .walkingStepLength)!
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            let value = result?.averageQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0
            DispatchQueue.main.async {
                completion(value)
            }
        }
        healthStore.execute(query)
    }
    func fetchElevationGain(completion: @escaping (Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let value = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            DispatchQueue.main.async {
                completion(value)
            }
        }
        healthStore.execute(query)
    }
}
