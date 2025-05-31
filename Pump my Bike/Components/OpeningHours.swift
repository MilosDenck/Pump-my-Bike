//
//  OpeningHours.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI

struct OpeningHours2: View {
    @State var pump: PumpData
    @EnvironmentObject var mapAPI:MapAPI
    @StateObject var ldvm: DetailViewModel
    var font:Font = .headline
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack{
                if let openingHour = pump.openingHours{
                    if !openingHour.alwaysOpen{
                        VStack{
                            Opening(openingHour: $pump.openingHours, dayString: "monday", dayInt: 2)
                            Opening(openingHour: $pump.openingHours, dayString: "tuesday", dayInt: 3)
                            Opening(openingHour: $pump.openingHours, dayString: "wednesday", dayInt: 4)
                            Opening(openingHour: $pump.openingHours, dayString: "thursday", dayInt: 5)
                            Opening(openingHour: $pump.openingHours, dayString: "friday", dayInt: 6)
                            Opening(openingHour: $pump.openingHours, dayString: "saturday", dayInt: 7)
                            Opening(openingHour: $pump.openingHours, dayString: "sunday", dayInt: 1)
                        }
                    }else{
                        Text("always Open")
                    }
                }else{
                    Text("No opening hours available")
                }
                
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
            Text("Opening Hours")
                .padding(5)
                .font(font)
                .background(.white)
                .padding(.horizontal, 25)
                .offset(y: -16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.black)
        }
        
    }
}

#Preview {
    //OpeningHours()
}
