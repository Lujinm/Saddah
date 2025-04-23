//
//  ContentView.swift
//  Saddah
//
//  Created by lujin mohammed on 23/09/1446 AH.
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
    @State private var showAlert = false
    
    private let healthStore = HealthStore()
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    if let playerId = TokenManager.shared.getPlayerId(), !playerId.isEmpty {
                        loadData()
                    } else {
                        showAlert = true
                    }
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
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("⚠️ لم يتم تسجيل الدخول"),
                        message: Text("يرجى تسجيل الدخول أولاً لربط البيانات الصحية بحساب اللاعب."),
                        dismissButton: .default(Text("حسنًا"))
                    )
                }

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
        guard let playerId = TokenManager.shared.getPlayerId() else {
            print("❌ Player ID not found. Please log in first.")
            return
        }

        guard let url = URL(string: "https://visioncoachai-staging-api.azurewebsites.net/player_metric") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let data: [String: Any] = [
                "player_id": playerId,
            "step_count": Int(stepCount),
            "heart_rate": Int(heartRate),
            "blood_oxygen_level": Int(bloodOxygen),
            "vo_max": vo2Max,
            "hrv": hrv,
            "cadence": cadence,
            "elevation_gain": elevation
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: data)

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Send error: \(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse {
                print("✅ Response status: \(response.statusCode)")
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
