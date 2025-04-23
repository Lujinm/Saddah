//
//  Project: HealthKitExample
//  File: ContentView.swift
//  Created by Noah Carpenter
//  🐱 Follow me on YouTube! 🎥
//  https://www.youtube.com/@NoahDoesCoding97
//  Like and Subscribe for coding tutorials and fun! 💻✨
//  Fun Fact: Cats have five toes on their front paws, but only four on their back paws! 🐾
//  Dream Big, Code Bigger
//

import SwiftUI

struct ContentView: View {
    @State private var stepCount: Double = 0
    @State private var heartRate: Double = 0
    @State private var bloodOxygen: Double = 0
    @State private var hrv: Double = 0
    @State private var vo2Max: Double = 0
    @State private var cadence: Double = 0
    @State private var elevation: Double = 0
    
    private let healthStore = HealthStore()
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    loadData()
                }) {
                    Text("📲 تحميل البيانات")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                List {
                    Section(header: Text("Today's Stats")) {
                        HealthRow(title: "🚶‍♂️ Steps", value: "\(Int(stepCount)) steps")
                        HealthRow(title: "❤️ Heart Rate", value: "\(Int(heartRate)) bpm")
                        HealthRow(title: "🩸 Blood Oxygen", value: String(format: "%.1f%%", bloodOxygen))
                        HealthRow(title: "📈 HRV", value: String(format: "%.0f ms", hrv))
                        HealthRow(title: "🫁 VO₂ Max", value: String(format: "%.2f L/min", vo2Max))
                        HealthRow(title: "👣 Step Length", value: String(format: "%.2f m", cadence))
                        HealthRow(title: "🗻 Elevation", value: "\(Int(elevation)) floors")
                    }
                }
            }
            .navigationTitle("Health Stats")
        }
    }
    
    func loadData() {
        healthStore.requestAuthorization { success, _ in
            if success {
                let group = DispatchGroup()
                
                group.enter()
                healthStore.fetchStepCount { self.stepCount = $0; group.leave() }
                
                group.enter()
                healthStore.fetchHeartRate { self.heartRate = $0; group.leave() }
                
                group.enter()
                healthStore.fetchBloodOxygen { self.bloodOxygen = $0; group.leave() }
                
                group.enter()
                healthStore.fetchHRV { self.hrv = $0; group.leave() }
                
                group.enter()
                healthStore.fetchVO2Max { self.vo2Max = $0; group.leave() }
                
                group.enter()
                healthStore.fetchCadence { self.cadence = $0; group.leave() }
                
                group.enter()
                healthStore.fetchElevationGain { self.elevation = $0; group.leave() }

                group.notify(queue: .main) {
                    sendData()
                }
            }
        }
    }
    
    func sendData() {
        guard let url = URL(string: "https://visioncoachai-staging-api.azurewebsites.net/player_metric") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let data: [String: Any] = [
            "player_id": 1, // غيّر المعرف حسب اللاعب المطلوب
            "step_count": Int(stepCount),
            "heart_rate": Int(heartRate),
            "blood_oxygen_level": Int(bloodOxygen),
            "heart_rate_variability": Int(hrv),
            "vo_max": vo2Max,
            "step_length": cadence,
            "flights_climbed": Int(elevation),
            "device": "Apple Watch"
        ]
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API error: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ API status: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}

struct HealthRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}

