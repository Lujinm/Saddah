//
//  mainPage.swift
//  Saddah
//
//  Created by lujin mohammed on 24/09/1446 AH.
//

import SwiftUI

struct MainPage: View {
    @State private var messages: [Message] = [Message(text: "مرحبًا! أنا الحارس الذكي، بماذا تريدني أن أساعدك اليوم؟", isAI: true)]
    @State private var userInput: String = ""
    
    var body: some View {
        VStack {
           HStack {
                Spacer()
                Text("صدّه - ذكاء اصطناعي")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                                   NavigationLink(destination: Profile()) {
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
        messages.append(Message(text: userInput, isAI: false))
        userInput = ""
        // the ai model
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isAI: Bool
}

#Preview {
    NavigationStack {
        MainPage()
    }
}
  
