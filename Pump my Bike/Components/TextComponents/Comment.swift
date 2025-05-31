//
//  Rating.swift
//  Pump my Bike
//
//  Created by Milos Denck on 07.06.25.
//

import SwiftUI

struct Comment: View {
    var rating: RatingData
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading){
                if let inputDate = parseDate(from: rating.createdAt) {
                    Text(formatDate(inputDate))
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                HStack{
                    ForEach(0..<rating.rating, id: \.self){_ in
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(.yellow)
                    }
                    ForEach(0..<5-rating.rating, id: \.self){_ in
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                if(rating.comment != ""){
                        Text(rating.comment)
                            .padding(.top, 10)
                }
                
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

            HStack{
                Text(rating.username)
            }
            .font(.headline)
            .padding(5)
            .background(.white)
            .padding(.horizontal, 25)
            .offset(y: -16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.black)
            
        }.padding(.top, 20)
    }
    
    func parseDate(from string: String) -> Date? {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
        parser.locale = Locale(identifier: "en_US_POSIX")
        return parser.date(from: string)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    //Rating()
}
