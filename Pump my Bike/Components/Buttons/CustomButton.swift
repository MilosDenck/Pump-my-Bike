//
//  CustomButton.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var backgroundColor: Color = .black
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = CornerRadius.medium
    var font: Font = .headline

    var body: some View {
        Button(title) {
            action()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 30)
        .font(font)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(.black)
        )
        .foregroundStyle(.white)
    }
}

#Preview {
    @State var title = "Test"
    CustomButton(title: title, action: {print("test")})
}
