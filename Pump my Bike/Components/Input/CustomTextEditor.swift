//
//  CustomTextEditor.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI



struct CustomTextEditor: View {
    @State var title: String = ""
    @Binding var text: String
    @FocusState var isFocused: Bool
    let font: Font = .headline
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            TextEditor(text: $text)
                                .frame(minHeight: 100, maxHeight: 200) // passt für 5–10 Zeilen
                .padding(15)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.small)
                        .stroke(isFocused ? .indigo : Color.gray, lineWidth: 2)
                )
                .focused($isFocused)
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.bottom, 15)

            Text(title)
                .padding(5)
                .background(.white)
                .padding(.horizontal, 25)
                .offset(y: -16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(font)
        }
        .padding(.top, 20)
    }
}

#Preview {
    @State var title = "description"
    @State var text = ""
    CustomTextEditor(title: title, text: $text)
}
