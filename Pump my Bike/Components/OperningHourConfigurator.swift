//
//  OperningHourConfigurator.swift
//  Pump my Bike
//
//  Created by Milos Denck on 07.06.25.
//

import SwiftUI

struct OperningHourConfigurator: View {
    
    @State private var openingTime: Date = Date()
    @State private var closingTime: Date = Date()
    
    @EnvironmentObject var openingHourViewModel: OpeningHourAddViewModel
    
    var body: some View{
        ZStack(alignment: .topLeading) {
            VStack{
                if openingHourViewModel.isActive {
                    Toggle(isOn: $openingHourViewModel.alwaysOpen, label: {Text("always Open")})
                        .toggleStyle(.switch)
                    if(!openingHourViewModel.alwaysOpen){
                        HStack{
                            DatePicker( "opening:" ,selection: $openingTime, displayedComponents: .hourAndMinute)
                            Spacer()
                            DatePicker("closing:" ,selection: $closingTime, displayedComponents: .hourAndMinute)
                                .onChange(of: closingTime){
                                    openingHourViewModel.setOpeningHour(openingHour: OpeningHour(opening: Time(date: openingTime), closing: Time(date: closingTime)))
                                }
                                .onChange(of: openingTime){
                                    openingHourViewModel.setOpeningHour(openingHour: OpeningHour(opening: Time(date: openingTime), closing: Time(date: closingTime)))
                                }
                        }
                        VStack{
                            OpeningHourDayAdjuster(day: "monday", active: $openingHourViewModel.mondayActive).environmentObject(openingHourViewModel)
                            OpeningHourDayAdjuster(day: "tuesday", active: $openingHourViewModel.tuesdayActive).environmentObject(openingHourViewModel)
                            OpeningHourDayAdjuster(day: "wednesday", active: $openingHourViewModel.wednesdayActive).environmentObject(openingHourViewModel)
                            OpeningHourDayAdjuster(day: "thursday", active: $openingHourViewModel.thursdayActive).environmentObject(openingHourViewModel)
                            OpeningHourDayAdjuster(day: "friday", active: $openingHourViewModel.fridayActive).environmentObject(openingHourViewModel)
                            OpeningHourDayAdjuster(day: "saturday", active: $openingHourViewModel.saturdayActive).environmentObject(openingHourViewModel)
                            OpeningHourDayAdjuster(day: "sunday", active: $openingHourViewModel.sundayActive).environmentObject(openingHourViewModel)
                        }
                    }
                }else{
                    Button("add opening Hours"){
                        triggerAddButton()
                    }
                }
                Spacer()
            }
            .padding(20)
            .background(Color.white)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .foregroundColor(.black)
            .padding(.horizontal, 10)
                Text("Opening Hours")
                .font(.headline)
                .padding(5)
                .background(.white)
                .padding(.horizontal, 25)
                .offset(y: -16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.black)
        }.padding(.top, 5)

        
    }
    
    func triggerAddButton(){
        openingHourViewModel.isActive = true
    }

}

#Preview {
    OperningHourConfigurator()
}
