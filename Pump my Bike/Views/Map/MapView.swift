//
//  MapView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @EnvironmentObject var mapAPI: MapAPI
    @State private var visibleRegion: MKCoordinateRegion?
    
    @Binding var showRatingView: Bool
    @Binding var showCardView: Bool
    
    @State private var longPressLocation: CGPoint? = nil
    
    var body: some View {
        MapReader{ reader in
            
            Map(position: $mapAPI.cameraPosition){
                ForEach(mapAPI.pins, id: \.self.id){ pin in
                    if let myLocation = mapAPI.manager.location{
                        Annotation("", coordinate: myLocation){
                            Circle()
                                .fill(.blue)
                                .frame(width: 20)
                        }
                    }
                    Annotation("", coordinate: pin.coodinates){
                        VStack{
                            if(pin.type == 0){
                                selectedLocationMarkerView()
                            }
                            if(pin.type == 1){
                                LocationMarkerView()
                            }
                        }
                        .scaleEffect(mapAPI.currentPin?.id == pin.id ? 1 : 0.7)
                        .simultaneousGesture(TapGesture().onEnded{Task {
                            if !showRatingView{
                                withAnimation{
                                    mapAPI.updateRegion(coordinates: pin.coodinates, span: visibleRegion?.span)
                                    mapAPI.currentPin = pin
                                    mapAPI.dismissRoute()
                                    /*if(pin.type == 1){
                                     mapAPI.getFilenames(id: pin.locationId!)
                                     }*/
                                    showCardView = true
                                }
                            }
                        }
                        })
                                             
                    }
                }
                if let route = mapAPI.route{
                    MapPolyline(route.polyline)
                        .stroke(.blue,lineWidth: 7)
                }
            }
            .onMapCameraChange(frequency: .continuous){ context in
                visibleRegion = context.region
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onChanged { value in
                        switch value {
                        case .second(true, let drag?):
                            longPressLocation = drag.location
                        default:
                            break
                        }
                    }
                    .onEnded { _ in
                        if let point = longPressLocation,
                           let coord = reader.convert(point, from: .local) {
                            
                            mapAPI.searchPlacefromCoordinates(coordinates: coord)
                            mapAPI.dismissRoute()
                            showCardView = true
                            withAnimation{
                                mapAPI.updateRegion(coordinates: coord, span: visibleRegion?.span)
                            }
                        }
                        longPressLocation = nil
                    }
            )
        }
    }
}

#Preview {
    //MapView()
}
