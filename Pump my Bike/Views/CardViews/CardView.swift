//
//  CardView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.06.25.
//

import SwiftUI
import CoreLocation


struct CardView: View {
    @EnvironmentObject var mapAPI:MapAPI
    //@Binding var showAddView: Bool
    @Binding var overlayView: OverlaysViewStyle
    @Binding var currentLocation: CLLocationCoordinate2D?
    
    var showRatingView: () -> ()
    var getRoute: () -> ()
    
    var body: some View {
        VStack{
            Spacer()
            VStack{
                if(mapAPI.currentPin?.type == 1){
                    PumpCardView(overlayView: $overlayView, showRatingView: showRatingView, getRoute: getRoute).environmentObject(mapAPI)
                }else if mapAPI.pins.first(where: {$0.type == 0}) != nil{
                    LocationCardView2(overlayView: $overlayView, currentLocation: $currentLocation).environmentObject(mapAPI)
                }
                    
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            //.background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.ultraThinMaterial))
            .background(RoundedRectangle(cornerSize: CGSize(width: 15, height: 20)).fill(.thinMaterial))
            .padding(10)
        }
        
    }
}

#Preview {
    //CardView()
}
