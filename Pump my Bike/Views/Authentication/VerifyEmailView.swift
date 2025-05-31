//
//  VerifyEmailView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 08.06.25.
//

import SwiftUI

struct VerifyEmailView: View {
    var body: some View {
        VStack{
            HStack{
                
                Button{
                    Task{
                        try await AuthManager.shared.logout()
                    }
                }label: {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .padding(6)
                        .background(.black)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                    
                }
                
                Spacer()
                
            }
            .padding(.horizontal,20)
            .padding(.top, 10)
            Spacer()
            HStack{
                Spacer()
                Text("Please Verify your Email")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                
                Spacer()
            }
            HStack{
                CustomButton(title: "resend", action: {
                    Task{
                        try await AuthManager.shared.resendVerificationEmail()
                    }
                })
                .padding(.horizontal,10)
                
                CustomButton(title: "done", action: {
                    Task{
                        let succ = try await AuthManager.shared.verifySession()
                        if(succ){
                            UserDefaults.standard.removeObject(forKey: "verified")
                        }
                    }
                })
                .padding(.horizontal,10)
            }
            
            Spacer()
            Spacer()
        }.background(.white)
    }
}

#Preview {
    VerifyEmailView()
}
