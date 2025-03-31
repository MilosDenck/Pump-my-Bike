//
//  openingHourDayView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 18.09.23.
//

import SwiftUI

struct openingHourDayView: View {
    
    @State var day: String
    var openingHour: OpeningHour?{
        if day == "monday" {return vm.openingHourAddViewModel.monday}
        if day == "tuesday" {return vm.openingHourAddViewModel.tuesday}
        if day == "wednesday" {return vm.openingHourAddViewModel.wednesday}
        if day == "thursday" {return vm.openingHourAddViewModel.thursday}
        if day == "friday" {return vm.openingHourAddViewModel.friday}
        if day == "saturday" {return vm.openingHourAddViewModel.saturday}
        if day == "sunday" {return vm.openingHourAddViewModel.sunday}
        return nil
    }
    @EnvironmentObject var vm: pumpAddViewModel
    @Binding var active: Bool
    
    
    var body: some View {
        HStack{
            Toggle(day, isOn: $active)
                .toggleStyle(CheckboxToggleStyle())
            Spacer()
            if let d = openingHour{
                HStack{
                    Text(String(format:"%02d:%02d-%02d:%02d", d.opening.hour, d.opening.minute, d.closing.hour, d.closing.minute))
                        .foregroundColor(.secondary)
                    Button(action: {vm.deleteOpeningHour(day: day)}, label: {Image(systemName: "trash").foregroundColor(.primary)})
                }
            }else{
                Text("closed")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    
}


struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
 
            Circle()
                .stroke(lineWidth: 2)
                .frame(width: 15, height: 15)
                .overlay {
                    if configuration.isOn {
                        Image(systemName: "checkmark" )
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10)
                        
                    }
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
 
            configuration.label
 
        }
    }
}

