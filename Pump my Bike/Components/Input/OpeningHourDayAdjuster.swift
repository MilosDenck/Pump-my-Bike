//
//  openingHourDayView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 18.09.23.
//

import SwiftUI

struct OpeningHourDayAdjuster: View {
    
    @State var day: String
    var openingHour: OpeningHour?{
        if day == "monday" {return vm.monday}
        if day == "tuesday" {return vm.tuesday}
        if day == "wednesday" {return vm.wednesday}
        if day == "thursday" {return vm.thursday}
        if day == "friday" {return vm.friday}
        if day == "saturday" {return vm.saturday}
        if day == "sunday" {return vm.sunday}
        return nil
    }
    @EnvironmentObject var vm: OpeningHourAddViewModel
    @Binding var active: Bool
    
    
    var body: some View {
        HStack{
            Toggle(day, isOn: $active)
            .toggleStyle(.switch) // optional, um sicherzustellen, dass es wie ein UISwitch aussieht
            .labelsHidden()
            .scaleEffect(0.8)
            Text(day)
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
 
            Rectangle()
                .stroke(lineWidth: 2)
                .frame(width: 15, height: 15)
                .overlay {
                    if configuration.isOn {
                        Image(systemName: "xmark" )
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

