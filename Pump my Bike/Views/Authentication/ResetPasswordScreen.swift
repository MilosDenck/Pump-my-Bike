//
//  ResetPasswordScreen.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.06.25.
//

import SwiftUI

struct ResetPasswordScreen: View {
    @State private var email: String = ""
    
    @State private var errorMessage: String = ""
    @State private var showErrorMessage: Bool = false
        
    @Binding var authScreen: AuthScreen
    
    @EnvironmentObject var handler: ErrorHandler2
    
    var body: some View {
        VStack{
            Spacer()
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.bold)
            VStack{
                CustomTextField(title: "email", text: $email)
                HStack{
                    Spacer()
                    CustomButton(title: "Send"){
                        Task{
                            guard isValidEmail(email) else{
                                handler.showError(message: "Invalid email format", title: "Sign Up Error")
                                return
                            }
                            let (succ, error) = try await AuthManager.shared.resetPassword(email: email)
                            if !succ{
                                handler.showError(message: error, title: "Error")
                                return
                            }
                        }
                        authScreen = .loginScreen
                    }
                    .padding(.trailing, 10)
                    
                }
                .padding(.top, 20)
            }.padding(.horizontal, 10)
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
}
