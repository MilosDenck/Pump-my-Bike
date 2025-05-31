//
//  OpeningHourUploadView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 07.06.25.
//

import SwiftUI


struct OpeningHourUploadView: View{
    @EnvironmentObject var openingHourAddViewModel: OpeningHourAddViewModel
    @State var id: Int
    @State var openingTime: Date = Date()
    @State var closingTime: Date = Date()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        Form{
            Toggle(isOn: $openingHourAddViewModel.alwaysOpen, label: {Text("always Open")})
                .toggleStyle(.switch)
            if(openingHourAddViewModel.activeDay && !openingHourAddViewModel.alwaysOpen){
                HStack{
                    DatePicker( "opening:" ,selection: $openingTime, displayedComponents: .hourAndMinute)
                        .onChange(of: openingTime){
                            openingHourAddViewModel.setOpeningHour(openingHour: OpeningHour(opening: Time(date: openingTime), closing: Time(date: closingTime)))
                        }
                    Spacer()
                    DatePicker("closing:" ,selection: $closingTime, displayedComponents: .hourAndMinute)
                        .onChange(of: closingTime){
                            openingHourAddViewModel.setOpeningHour(openingHour: OpeningHour(opening: Time(date: openingTime), closing: Time(date: closingTime)))
                        }
                }
            }
            if(!openingHourAddViewModel.alwaysOpen){
                OpeningHourDayAdjuster(day: "monday", active: $openingHourAddViewModel.mondayActive).environmentObject(openingHourAddViewModel)
                OpeningHourDayAdjuster(day: "tuesday", active: $openingHourAddViewModel.tuesdayActive).environmentObject(openingHourAddViewModel)
                OpeningHourDayAdjuster(day: "wednesday", active: $openingHourAddViewModel.wednesdayActive).environmentObject(openingHourAddViewModel)
                OpeningHourDayAdjuster(day: "thursday", active: $openingHourAddViewModel.thursdayActive).environmentObject(openingHourAddViewModel)
                OpeningHourDayAdjuster(day: "friday", active: $openingHourAddViewModel.fridayActive).environmentObject(openingHourAddViewModel)
                OpeningHourDayAdjuster(day: "saturday", active: $openingHourAddViewModel.saturdayActive).environmentObject(openingHourAddViewModel)
                OpeningHourDayAdjuster(day: "sunday", active: $openingHourAddViewModel.sundayActive).environmentObject(openingHourAddViewModel)
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button{
                    
                    openingHourAddViewModel.postOpeningHours(id: id)
                    presentationMode.wrappedValue.dismiss()
                    //print("Test")
                    
                }label: {
                    Image(systemName: "plus")
                        .padding(6)
                        .background(.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                
            }
            ToolbarItem(placement: .navigationBarLeading){
                Text("Opening Hours")
            }
        }
    }
}

#Preview {
    //OpeningHourUploadView()
}
