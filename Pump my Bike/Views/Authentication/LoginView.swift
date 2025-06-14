//
//  LoginView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 03.06.25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var errorMessage: String = ""
    @State private var showErrorMessage: Bool = false
    
    @Binding var authScreen: AuthScreen
    
    @EnvironmentObject var handler: ErrorHandler2
    
    var body: some View {
        VStack{
            Spacer()
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
            HStack{
                Text("not registered yet?")
                Button("sign up"){
                    authScreen = AuthScreen.signupScreen
                }
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            }
            .padding(5)
            .font(.footnote)
            
            VStack{
                CustomTextField(title: "email", text: $email)
                CustomSecureField(title: "password", text: $password)

                HStack{
                    Button("forgot password?") {
                        authScreen = .resetPasswordScreen
                    }
                    .font(.footnote)
                    .padding(.leading, 10)
                    .foregroundStyle(.blue)
                    Spacer()
                    CustomButton(title: "Login", action: {
                        guard isValidEmail(email) else{
                            handler.showError(message: "Invalid email format", title: "Sign Up Error")
                            return
                        }
                        Task{
                            let (success, errorMsg) = try await AuthManager.shared.login(email: email, password: password)
                            if success {
                                authScreen = .none
                            } else {
                                errorMessage = errorMsg
                                handler.showError(message: "Login Error", title: errorMsg)
                            }
                        }
                    })
                    .padding(.trailing, 10)
                }
                .padding(.top, 20)
            }.padding(10)
            Spacer()
            Button("I don't want to login") {
                authScreen = .none
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
}


