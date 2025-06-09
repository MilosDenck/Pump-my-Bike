//
//  SignupView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.06.25.
//

import SwiftUI

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordValidation: String = ""
    @State private var username: String = ""
    
    @State private var errorMessage: String = ""
    @State private var showErrorMessage: Bool = false
        
    @Binding var authScreen: AuthScreen
    
    @EnvironmentObject var handler: ErrorHandler2
    
    var body: some View {
        VStack{
            Spacer()
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
            VStack{
                CustomTextField(title: "email", text: $email)
                CustomTextField(title: "username", text: $username)
                CustomSecureField(title: "password", text: $passwordValidation)
                CustomSecureField(title: "repeat password", text: $password)

                HStack{
                    Spacer()
                    
                    CustomButton(title: "sign up", action: {
                        Task{
                            guard password == passwordValidation else {
                                handler.showError(message: "Passwords do not match", title: "Sign Up Error")
                                return
                            }
                            guard isValidEmail(email) else{
                                handler.showError(message: "Invalid email format", title: "Sign Up Error")
                                return
                            }
                            guard isValidUsername(username) else{
                                handler.showError(message: "Username is not valid", title: "Sign Up Error")
                                return
                            }
                            let (succ, error) = try await AuthManager.shared.singUp(email: email, password: password, username: username)
                            guard succ else {
                                handler.showError(message: error, title: "Sign Up Error")
                                TokenManager.shared.clearTokens()
                                return
                            }
                            let succ2 = try await AuthManager.shared.verifyMail()
                            guard succ2 else {
                                TokenManager.shared.clearTokens()
                                authScreen = AuthScreen.loginScreen
                                return
                            }
                            let succ3 = try await AuthManager.shared.verifyMailToken()
                            guard succ3 else {
                                TokenManager.shared.clearTokens()
                                authScreen = AuthScreen.loginScreen
                                return
                            }
                            authScreen = AuthScreen.loginScreen
                        }
                        
                    })
                    .padding(.trailing, 10)
                }
                .padding(.top, 20)
            }.padding(10)
            
            Spacer()
            Button("back to login screen") {
                authScreen = AuthScreen.loginScreen
            }
            .font(.footnote)
        }
            .foregroundColor(.black)
            .background(Color.white)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    func isValidUsername(_ username: String) -> Bool {
        let pattern = #"^[a-zA-Z][a-zA-Z0-9_]{2,14}$"#
        return username.range(of: pattern, options: .regularExpression) != nil
    }
}
