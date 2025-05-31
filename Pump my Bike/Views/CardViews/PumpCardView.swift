//
//  PumpCardView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.06.25.
//

import SwiftUI
import CoreLocation

struct PumpCardView: View {
    @EnvironmentObject var mapAPI: MapAPI
    
    @Binding var overlayView: OverlaysViewStyle
    
    var showRatingView: () -> ()
    var getRoute: () -> ()
    
    var body: some View {
        HStack{
            VStack{
                if let currentLoc = mapAPI.pumps.first(where: {$0.id == mapAPI.currentPin?.locationId}){
                    VStack{
                        if let image = currentLoc.thumbnail {
                            let url = "\(mapAPI.networkService.SERVER_IP)/Images/\(currentLoc.id!)/\(image)"
                            AsyncImage(url: URL(string:url)!){ phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 70, height: 70)
                                        .clipShape(Circle())
                                        .clipped()
                                        .padding(10)
                                case .failure(_):
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        /*
                        else{
                            Image(systemName: "camera")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                        }*/
                    }
                    Text(currentLoc.name )
                        .font(.system(size: 18))
                        .bold()
                    HStack{
                        if(mapAPI.manager.location != nil){
                            Text(String(format: "%.1f km" , mapAPI.manager.location?.dist(coordinates: CLLocationCoordinate2D(latitude: currentLoc.lat , longitude: currentLoc.lon )) ?? 0))
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                            
                        }
                        
                        if(currentLoc.openingHours != nil){
                            if(currentLoc.openingHours?.alwaysOpen ?? false || isOpen){
                                Text("open")
                                    .foregroundColor(.green)
                            }else{
                                Text("closed")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    

                    HStack{
                        CustomLongButton(title: "Route", action: {
                            mapAPI.fetchRoute()
                            getRoute()
                        })
                        .padding(.horizontal, 5)
                        CustomLongButton(title: "Details", action: {
                            overlayView = .pumpDetails
                        })
                        .padding(.horizontal, 5)
                    }.padding(.vertical, 5)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    
    
    var Rating: some View {
        VStack{
            if let currentLoc = mapAPI.pumps.first(where: {$0.id == mapAPI.currentPin?.locationId}){
                HStack{
                    if let rounded = currentLoc.rating {
                        ForEach(0..<Int(rounded), id: \.self){_ in
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10)
                                .foregroundColor(.yellow)
                        }
                        ForEach(0..<5-Int(rounded), id: \.self){_ in
                            Image(systemName: "star.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10)
                                .foregroundColor(.secondary)
                        }
                    }else{
                        Text("No review available")
                            .font(.system(size: 10))
                    }
                }
            }
            Button(action: {
                showRatingView()
            }, label: {
                Text("add Review")
            })
        }
        
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

#Preview {
    //PumpCardView()
}
