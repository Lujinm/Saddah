//
//  signIn1.swift
//  Saddah
//
//  Created by lujin mohammed on 23/09/1446 AH.
//

import SwiftUI

struct SignIn: View {
    @State private var backgroundIndex = 0
    @State private var showAuthSheet = false
    @State private var isSignUp = false
    private let backgroundImages = ["signIn1", "signIn2", "signIn3"]

    var body: some View {
        ZStack {
            Image(backgroundImages[backgroundIndex])
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                VStack(spacing: 15) {
                    Button(action: {
                        isSignUp = false
                        showAuthSheet.toggle()
                    }) {
                        Text("تسجيل الدخول")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        isSignUp = true
                        showAuthSheet.toggle()
                    }) {
                        Text("إنشاء حساب")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 300)
            }
        }
        .onAppear {
            startBackground()
        }
        .sheet(isPresented: $showAuthSheet) {
            AuthSheet(isSignUp: $isSignUp)
        }
    }

    private func startBackground() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            backgroundIndex = (backgroundIndex + 1) % backgroundImages.count
        }
    }
}

struct AuthSheet: View {
    @Binding var isSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    @State private var showResetPasswordAlert = false
    @State private var resetEmail = ""
    @State private var showResetConfirmation = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isSignUp {
                        CustomTextField(title: "الاسم الكامل", text: $fullName)
                        CustomTextField(title: "رقم الجوال", text: $phoneNumber, keyboardType: .numberPad)
                    }

                    CustomTextField(title: "البريد الإلكتروني", text: $email)
                    CustomSecureField(title: "كلمة المرور", text: $password)

                    if !isSignUp {
                        Button(action: {
                            showResetPasswordAlert = true
                        }) {
                            Text("نسيت كلمة المرور؟")
                                .font(.footnote)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    if isSignUp {
                        CustomSecureField(title: "تأكيد كلمة المرور", text: $confirmPassword)
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }

                    Button(action: {
                        isLoading = true
                        Task {
                            let success: Bool
                            if isSignUp {
                                success = await AuthManager.shared.registerUser(fullName: fullName, phoneNumber: phoneNumber, email: email, password: password, confirmPassword: confirmPassword)
                            } else {
                                success = await AuthManager.shared.loginUser(email: email, password: password)
                            }
                            isLoading = false
                            if success {
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                errorMessage = "فشل العملية. تحقق من بياناتك وحاول مرة أخرى."
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text(isSignUp ? "إنشاء حساب" : "تسجيل الدخول")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    if isSignUp {
                        Button(action: {
                            fullName = ""
                            phoneNumber = ""
                            email = ""
                            password = ""
                            confirmPassword = ""
                        }) {
                            Text("إعادة تعيين")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }

                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                        }
                    }) {
                        Text(isSignUp ? "لدي حساب بالفعل؟ تسجيل الدخول" : "إنشاء حساب جديد")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .navigationTitle(isSignUp ? "إنشاء حساب" : "تسجيل الدخول")
            .navigationBarTitleDisplayMode(.inline)
            .alert("إعادة تعيين كلمة المرور", isPresented: $showResetPasswordAlert, actions: {
                TextField("أدخل بريدك الإلكتروني", text: $resetEmail)
                Button("إرسال") {
                    Task {
                        let result = await AuthManager.shared.resetPassword(email: resetEmail)
                        showResetConfirmation = result
                    }
                }
                Button("إلغاء", role: .cancel) {}
            }, message: {
                Text("سنرسل لك رابطًا لإعادة تعيين كلمة المرور.")
            })
            .alert("تم الإرسال", isPresented: $showResetConfirmation) {
                Button("تم") {}
            } message: {
                Text("تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك.")
            }
        }
    }
}

class AuthManager {
    static let shared = AuthManager()
    private init() {}

    let apiURL = "https://visioncoachai-staging-api.azurewebsites.net"


    func loginUser(email: String, password: String) async -> Bool {
        let loginData = ["username": email, "password": password]
        return await sendRequest(endpoint: "/login", data: loginData)
    }

    func registerUser(fullName: String, phoneNumber: String, email: String, password: String, confirmPassword: String) async -> Bool {
        guard password == confirmPassword else { return false }
        let registerData: [String: Any] = [
            "fullname": fullName,
            "phone": phoneNumber,
            "username": email,
            "email": email,
            "password": password
        ]
        return await sendRequest(endpoint: "/register", data: registerData)
    }

    func resetPassword(email: String) async -> Bool {
        let resetData = ["email": email]
        return await sendRequest(endpoint: "/reset-password", data: resetData)
    }

    private func sendRequest(endpoint: String, data: [String: Any]) async -> Bool {
        guard let url = URL(string: apiURL + endpoint) else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)

        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            // Debugging
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            print("Response: \(String(data: responseData, encoding: .utf8) ?? "Invalid response")")
            
            let decodedResponse = try JSONDecoder().decode(AuthResponse.self, from: responseData)
            return decodedResponse.success
        } catch {
            print("Error: \(error.localizedDescription)")
            return false
        }
    }
}

struct AuthResponse: Codable {
    let success: Bool
}

struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(title, text: $text)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .keyboardType(keyboardType)
    }
}

struct CustomSecureField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
    }
}

#Preview {
    SignIn()
}
