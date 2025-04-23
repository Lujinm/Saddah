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
    @State private var isAuthenticated = false

    private let backgroundImages = ["signIn1", "signIn2", "signIn3"]

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: MainPage(), isActive: $isAuthenticated) {
                    EmptyView()
                }
                .hidden()

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
                AuthSheet(isSignUp: $isSignUp, isAuthenticated: $isAuthenticated)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func startBackground() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            backgroundIndex = (backgroundIndex + 1) % backgroundImages.count
        }
    }
}

struct AuthSheet: View {
    @Binding var isSignUp: Bool
    @Binding var isAuthenticated: Bool
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
        VStack(spacing: 0) {
            Text(isSignUp ? "إنشاء حساب" : "تسجيل الدخول")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 30)
                .padding(.bottom, 10)

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    if isSignUp {
                        CustomTextField(title: "الاسم الكامل", text: $fullName)
                        CustomTextField(title: "رقم الجوال", text: $phoneNumber, keyboardType: .numberPad)
                    }

                    CustomTextField(title: "البريد الإلكتروني", text: $email)
                    CustomSecureField(title: "كلمة المرور", text: $password)

                    if !isSignUp {
                        Button("نسيت كلمة المرور؟") {
                            showResetPasswordAlert = true
                        }
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
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
                                isAuthenticated = true
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
                        Button("إعادة تعيين") {
                            fullName = ""
                            phoneNumber = ""
                            email = ""
                            password = ""
                            confirmPassword = ""
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(10)
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
        }
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

class AuthManager {
    static let shared = AuthManager()
    private init() {}

    let apiURL = "https://visioncoachai-staging-api.azurewebsites.net"

    func loginUser(email: String, password: String) async -> Bool {
        var components = URLComponents(string: "\(apiURL)/login")
        components?.queryItems = [
            URLQueryItem(name: "username", value: email),
            URLQueryItem(name: "password", value: password)
        ]

        guard let url = components?.url else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (responseData, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(LoginResponse.self, from: responseData)

            if !decoded.is_error {
                TokenManager.shared.saveToken(decoded.token)
                if let playerID = decoded.player_id {
                    TokenManager.shared.savePlayerId(String(playerID))
                }
                return true
            } else {
                return false
            }
        } catch {
            print("Login error: \(error.localizedDescription)")
            return false
        }
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
        return await sendPostRequest(endpoint: "/register", data: registerData)
    }

    func resetPassword(email: String) async -> Bool {
        let resetData = ["email": email]
        return await sendPostRequest(endpoint: "/reset-password", data: resetData)
    }

    private func sendPostRequest(endpoint: String, data: [String: Any]) async -> Bool {
        guard let url = URL(string: apiURL + endpoint) else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)

        do {
            let (responseData, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(AuthResponse.self, from: responseData)
            return decoded.success
        } catch {
            print("Error: \(error.localizedDescription)")
            return false
        }
    }
}

struct LoginResponse: Codable {
    let token: String
    let type: String
    let expires: String
    let is_error: Bool
    let error_message: String?
    let player_id: Int?
}

struct AuthResponse: Codable {
    let success: Bool
}

class TokenManager {
    static let shared = TokenManager()
    private let tokenKey = "authToken"
    private let playerIdKey = "playerId"
    
    private init() {}
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func getToken() -> String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func savePlayerId(_ id: String) {
        UserDefaults.standard.set(id, forKey: playerIdKey)
    }
    
    func getPlayerId() -> String? {
        UserDefaults.standard.string(forKey: playerIdKey)
    }
    
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: playerIdKey)
    }
}



class PlayerManager {
    static let shared = PlayerManager()
    private let playerIDKey = "playerID"

    func savePlayerID(_ id: Int) {
        UserDefaults.standard.set(id, forKey: playerIDKey)
    }

    func getPlayerID() -> Int? {
        let id = UserDefaults.standard.integer(forKey: playerIDKey)
        return id == 0 ? nil : id
    }

    func clearPlayerID() {
        UserDefaults.standard.removeObject(forKey: playerIDKey)
    }
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
