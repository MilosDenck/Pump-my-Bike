//
//  AuthView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.06.25.
//

import SwiftUI

enum AuthScreen {
    case none
    case loginScreen
    case signupScreen
    case resetPasswordScreen
}

struct AuthView: View {
    @Binding var authScreen: AuthScreen
    
    var body: some View {
        VStack{
            if authScreen == .loginScreen {
                LoginView(authScreen: $authScreen)
            }
            if authScreen == .signupScreen {
                SignupView(authScreen: $authScreen)
            }
            if authScreen == .resetPasswordScreen {
                ResetPasswordScreen(authScreen: $authScreen)
            }
        }.dismissKeyboardOnTap()
            
    }
}


