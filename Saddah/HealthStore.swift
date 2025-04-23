//
//  HealthStore.swift
//  Saddah
//
//  Created by lujin mohammed on 23/10/1446 AH.
//
import HealthKit


class HealthStore {
    let healthStore = HKHealthStore()
    
    // MARK: - Request Permissions for HealthKit
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        
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
   
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    // MARK: - Fetch Step Count Data
    
    
    func fetchStepCount(completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
      
        let startDate = Calendar.current.startOfDay(for: Date())
        
     
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
       
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let stepCount = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            
        
            DispatchQueue.main.async {
                completion(stepCount)
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Heart Rate Data
    
    func fetchHeartRate(completion: @escaping (Double) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
       
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        
       
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            let heartRate = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())) ?? 0
            
            
            DispatchQueue.main.async {
                completion(heartRate)
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchBloodOxygen(completion: @escaping (Double) -> Void) {
        let type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        let startDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            let value = result?.averageQuantity()?.doubleValue(for: HKUnit.percent()) ?? 0
            DispatchQueue.main.async {
                completion(value * 100)
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

