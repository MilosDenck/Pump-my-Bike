//
//  Opening.swift
//  Pump my Bike
//
//  Created by Milos Denck on 07.06.25.
//

import SwiftUI

struct Opening: View {
    
    //@State var openingHour: OpeningHour?
    @Binding var openingHour: OpeningHours?
    @State var dayString: String
    @State var dayInt: Int
    
    
    var body: some View{
        HStack{
            Text("\(dayString):")
            Spacer()
            if let day = openingHour!.getOpeningHoursOfDay(day: dayInt){
                Text(String(format:"%02d:%02d-%02d:%02d", day.opening.hour, day.opening.minute, day.closing.hour, day.closing.minute))
                    .foregroundStyle(.secondary)
            }else{
                Text("closed")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    //Opening()
}
