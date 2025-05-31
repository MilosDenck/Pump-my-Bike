//
//  TextField.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI

struct TextBox: View {
    var title: String
    var text: String
    
    var font: Font = .headline
    var action: () -> Void = {}

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack{
                Text(text)
                Spacer()
            }
            .padding(15)
            .background(Color.white)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .foregroundColor(.black)
            .padding(.horizontal, 10)
            Button(action: {
                action()
            }) {
                HStack{
                    Image(systemName: "pencil")
                        .padding(.trailing, -2)
                    Text(title)
                    
                    
                }
                .font(font)
                .padding(5)
                .background(.white)
                .padding(.horizontal, 25)
                .offset(y: -16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.black)
            }
            .buttonStyle(PlainButtonStyle())
            
        }.padding(.top, 20)
    }
}

#Preview {
    var test: String = "Lorem ipsum dolor sit amet consectetur adipisicing elit. Quo, voluptatem! Quasi, voluptates! Quo, voluptatem! Quo, voluptatem!"
    var title: String = "Test"
    TextBox(title: title, text: test)
}
