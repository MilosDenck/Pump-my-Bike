//
//  LocationCardView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.09.23.
//

import SwiftUI
import CoreLocation

struct LocationCardView: View {
    @EnvironmentObject var mapAPI:MapAPI
    @Binding var showAddView: Bool
    @Binding var currentLocation: CLLocationCoordinate2D?
    var showRatingView: () -> ()

    
    var getRoute: () -> ()

    
    var body: some View {
        VStack{
            if(mapAPI.currentPin?.type == 1){
                PumpCard
            }else{
                let clPin = mapAPI.pins.first(where: {$0.type == 0})
                if(clPin != nil){
                    LocationCard
                }
            }
        }
            .frame(maxWidth: .infinity)
            .padding(10)
            .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.ultraThinMaterial))
            .padding(10)
    }
    
    var PumpCard: some View {
        HStack{
            let currentLoc = mapAPI.pumps.first(where: {$0.id == mapAPI.currentPin?.locationId})
            VStack{
                if let image = currentLoc?.thumbnail {
                    let url = "\(mapAPI.networkService.SERVER_IP)/Images/\(currentLoc!.id!)/\(image)"
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
                }else{
                    Image(systemName: "camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                }
                
                HStack{
                    if let rounded = currentLoc!.rating {
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
                Button(action: {
                    showRatingView()
                }, label: {
                    Text("add Review")
                })
                
            }
            VStack{
                let currentLoc = mapAPI.pumps.first(where: {$0.id == mapAPI.currentPin?.locationId})
                Text(currentLoc?.name ?? "Error")
                    .font(.system(size: 18))
                    .bold()
                HStack{
                    if(mapAPI.manager.location != nil){
                        Text(String(format: "%.1f km" , mapAPI.manager.location?.dist(coordinates: CLLocationCoordinate2D(latitude: currentLoc!.lat , longitude: currentLoc!.lon )) ?? 0))
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        
                    }
                    
                    if(currentLoc?.openingHours != nil){
                        if(currentLoc?.openingHours?.alwaysOpen ?? false || isOpen){
                            Text("open")
                                .foregroundColor(.green)
                        }else{
                            Text("closed")
                                .foregroundColor(.red)
                        }
                    }
                }
                Text(currentLoc?.description ?? "")
                    .font(.system(size:15))
                    .padding(.top, 5)
                HStack(alignment: .bottom){
                    Button(action: {
                        mapAPI.fetchRoute()
                        getRoute()
                    }, label: {
                        Text("get Route")
                            .foregroundColor(.white)
                            .padding(7)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.blue.opacity(0.5)).shadow(radius: 7))
                        
                            .padding(5)
                            
                    })
                    NavigationLink(destination: LocationDetailView(pump: currentLoc!, ldvm: DetailViewModel(pump: currentLoc!)).environmentObject(mapAPI)){
                        Text("Details")
                            .foregroundColor(.white)
                            .padding(7)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.blue.opacity(0.5)).shadow(radius: 7))
                        
                            .padding(5)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    var LocationCard: some View  {
        
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
            HStack{
                Button(action: {
                    Task{
                        currentLocation = mapAPI.pins.first(where: {$0.type == 0})!.coodinates
                        await mapAPI.updatePumps(coordinates: currentLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
                    }
                }, label: {
                    Text("Search near")
                        .foregroundColor(.white)
                        .padding(7)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.blue.opacity(0.5)).shadow(radius: 7))
                        .padding(5)
                })
                Button(action: {
                    currentLocation = mapAPI.pins.first(where: {$0.type == 0})!.coodinates
                    showAddView = true
                }, label: {
                    Text("Add Pump")
                        .foregroundColor(.white)
                        .padding(7)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.blue.opacity(0.5)).shadow(radius: 7))
                        
                        .padding(5)
                })
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
