//
//  CustomSecureTextField.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI

struct CustomSecureField: View {
    @State var title: String = ""
    @Binding var text: String
    @FocusState var isFocused: Bool
    let font: Font = .headline
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            SecureField("", text:  $text)
                .padding(15)
                .focused($isFocused)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.small)
                        .stroke(isFocused ? .indigo : Color.gray, lineWidth: 2)
                )
                .foregroundColor(.black)
                .padding(.horizontal, 10)
            Text(title)
                .padding(5)
                .background(.white)
                .padding(.horizontal, 25)
                .offset(y: -16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(font)
        }.padding(.top, 20)
    }
}

#Preview {
    @State var title = "description"
    @State var text = ""
    CustomSecureField(title: title, text: $text)
}
