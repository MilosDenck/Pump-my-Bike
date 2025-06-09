//
//  Menu.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.06.25.
//

import SwiftUI

struct Menu: View {
    @Binding var authScreen: AuthScreen
    @AppStorage("loggedIn") private var loggedIn = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if loggedIn {
                Button("Profile", systemImage: "person.fill", action: {
                    
                })
                    .padding(10)
                Button("Log Out", systemImage: "return", action: {
                    Task {
                        try await AuthManager.shared.logout()
                    }
                })
                .padding(10)
            }else{
                Button("Sign Up", systemImage: "person.crop.circle.fill.badge.plus") {
                    authScreen = .signupScreen
                }
                    .padding(10)
                Button("Login", systemImage: "arrow.turn.down.right") {
                    authScreen = .loginScreen
                }
                    .padding(10)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: CornerRadius.medium).stroke(.black, lineWidth: 2).fill(.white))
        
        //.border(.black)
        
        
    }
}

#Preview {
    @State var authScreen: AuthScreen = .none
    Menu(authScreen: $authScreen)
}
