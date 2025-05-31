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
                                showErrorMessage = true
                                errorMessage = "Passwords do not match"
                                return
                            }
                            guard isValidEmail(email) else{
                                showErrorMessage = true
                                errorMessage = "Invalid email format"
                                return
                            }
                            guard isValidUsername(username) else{
                                showErrorMessage = true
                                errorMessage = "Invalid username format"
                                return
                            }
                            let (succ, error) = try await AuthManager.shared.singUp(email: email, password: password, username: username)
                            guard succ else {
                                showErrorMessage = true
                                errorMessage = error
                                TokenManager.shared.clearTokens()
                                return
                            }
                            let succ2 = try await AuthManager.shared.verifyMail()
                            guard succ2 else {
                                TokenManager.shared.clearTokens()
                                return
                            }
                            let succ3 = try await AuthManager.shared.verifyMailToken()
                            guard succ3 else {
                                TokenManager.shared.clearTokens()
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
            .alert("Registration Error", isPresented: $showErrorMessage, actions: {
                        
            Button("Cancel", role: .cancel) {
                showErrorMessage = false
            }
                
        }, message: {
            Text(errorMessage)
        })
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
