//
//  CustomLongButton.swift
//  Pump my Bike
//
//  Created by Milos Denck on 07.06.25.
//

import SwiftUI

struct CustomLongButton: View {
    let title: String
    let action: () -> Void
    var backgroundColor: Color = .black
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = CornerRadius.small
    var font: Font = .headline
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Text(title)
                .foregroundColor(.white)
                .padding(15)
                .font(font)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: cornerRadius).stroke( .black).fill(.black))
        })
    }
}

#Preview {
    //CustomLongButton()
}
