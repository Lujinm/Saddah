//
//  mainPage.swift
//  Saddah
//
//  Created by lujin mohammed on 24/09/1446 AH.
//

import SwiftUI

struct MainPage: View {
    @State private var messages: [Message] = [
        Message(text: "مرحبًا! أنا الحارس الذكي، بماذا تريدني أن أساعدك اليوم؟", isAI: true)
    ]
    @State private var userInput: String = ""

    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                Text("صدّه - ذكاء اصطناعي")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink(destination: ContentView()) {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundColor(.accentColor)
                }
            }
            .padding()

            Divider()

           
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isAI {
                                Text(message.text)
                                    .padding()
                                    .background(Color.accentColor.opacity(0.2))
                                    .cornerRadius(12)
                                    .frame(maxWidth: 250, alignment: .leading)
                                    .foregroundColor(.accentColor)
                                Spacer()
                            } else {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(12)
                                    .frame(maxWidth: 250, alignment: .trailing)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
            }

          
            HStack {
                TextField("اكتب رسالتك...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                .padding(.trailing)
            }
            .padding(.vertical)
        }
    }

    private func sendMessage() {
        guard !userInput.isEmpty else { return }

        let userText = userInput
        messages.append(Message(text: userText, isAI: false))
        userInput = ""

        let url = URL(string: "https://visioncoachai-staging-api.azurewebsites.net/coach")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonBody: [String: String] = ["message": userText]
        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if let decodedResponse = try? JSONDecoder().decode(AIResponse.self, from: data) {
                DispatchQueue.main.async {
                    messages.append(Message(text: decodedResponse.response, isAI: true))
                }
            } else {
                print("Failed to decode: \(String(data: data, encoding: .utf8) ?? "Invalid response")")
            }
        }.resume()
    }

}


struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isAI: Bool
}


struct AIResponse: Codable {
    let response: String
    let player_name: String?
    let player_report: String?
    let is_error: Bool?
    let error_message: String?
}


#Preview {
    NavigationStack {
        MainPage()
    }
}

