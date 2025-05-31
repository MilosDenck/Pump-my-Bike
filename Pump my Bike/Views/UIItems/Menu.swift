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
                Button("Login") {
                    authScreen = .loginScreen
                }
            }
        }
        .padding(10)
        .border(.black)
        
        
    }
}

#Preview {
    @State var authScreen: AuthScreen = .none
    Menu(authScreen: $authScreen)
}
