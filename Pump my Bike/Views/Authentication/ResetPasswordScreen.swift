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
                            let (succ, error) = try await AuthManager.shared.resetPassword(email: email)
                            if !succ{
                                errorMessage = error
                                showErrorMessage = true
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
            .alert("Error", isPresented: $showErrorMessage, actions: {
                        
            Button("Cancel", role: .cancel) {
                showErrorMessage = false
            }
                
        }, message: {
            Text(errorMessage)
        })
    }
}
