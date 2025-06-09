//
//  LocationCardView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.09.23.
//

import SwiftUI
import CoreLocation

struct LocationCardView2: View {
    @EnvironmentObject var mapAPI:MapAPI
    //@Binding var showAddView: Bool
    @Binding var overlayView: OverlaysViewStyle
    @Binding var currentLocation: CLLocationCoordinate2D?

    var body: some View  {
        
        VStack{
            VStack{
                Text(mapAPI.pins.first(where: {$0.type == 0})?.name ?? "Error")
                    .frame(alignment: .leading)
                    .font(.system(size: 18))
                    .bold()
                if let myLocation = mapAPI.manager.location{
                    Text(String(format: "%.1f km", myLocation.dist(coordinates: mapAPI.currentPin!.coodinates)))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
            HStack{
                CustomLongButton(title: "Search near", action: {
                    Task{
                        currentLocation = mapAPI.pins.first(where: {$0.type == 0})!.coodinates
                        try await mapAPI.updatePumps(coordinates: currentLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
                    }
                })
                .padding(.horizontal, 5)
                CustomLongButton(title: "Add Pump", action: {
                    currentLocation = mapAPI.pins.first(where: {$0.type == 0})!.coodinates
                    overlayView = .addView
                })
                .padding(.horizontal, 5)
            }
        }
        .frame(maxWidth: .infinity)
        
    }
    
    var isOpen: Bool{
        let currentLoc = mapAPI.pumps.first(where: {$0.id == mapAPI.currentPin?.locationId})
        let cal = Calendar.current
        let hour = cal.component(.hour, from: Date())
        let minute = cal.component(.minute, from: Date())
        if(currentLoc == nil || currentLoc?.openingHours == nil){return false}
        let todayOpen = currentLoc?.openingHours?.getOpeningHoursOfDay(day: Date())
        if(todayOpen == nil){
            return false
        }else{
            if(todayOpen!.opening.hour == todayOpen!.closing.hour && todayOpen!.opening.minute == todayOpen!.closing.minute){ return false}
            if(hour > todayOpen!.opening.hour && hour < todayOpen!.closing.hour) {return true}
            else if(hour == todayOpen!.opening.hour && minute > todayOpen!.opening.minute){return true}
            else if(hour == todayOpen!.closing.hour && minute < todayOpen!.closing.minute){return true}
        }
        return false
    }
}
/*
struct LocationCardView_Previews: PreviewProvider {
    static var previews: some View {
        LocationCardView(showAddView: ).environmentObject(MapAPI())
    }
}*/
