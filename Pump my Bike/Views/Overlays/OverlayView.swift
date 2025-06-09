//
//  OverlaysView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI

enum OverlaysViewStyle {
    case none
    case addView
    case pumpDetails
    case ratingView
}

struct OverlayView: View {
    
    @Binding var overlayView: OverlaysViewStyle
    @Binding var authScreen: AuthScreen
    
    @EnvironmentObject var mapAPI: MapAPI
    
    @State var updateDescription: Bool = false
    @State var updatedDescription: String = ""
    
    
        
    var body: some View {
        if overlayView == .none {
                    AnyView(EmptyView())
        }else {
            VStack{
                ZStack{
                    
                    HStack{
                        
                        Button{
                            overlayView = .none
                        }label: {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .padding(6)
                                .background(.black)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            
                        }
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal,20)
                    .padding(.top, 10)
                    VStack{
                        if overlayView == .addView {
                            Text("Add a Pump")
                        }
                        if overlayView == .pumpDetails {
                            if let pin = mapAPI.currentPin{
                                Text(pin.name ?? "")
                            }
                        }
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 12)
                }
                if overlayView == .addView {
                    AddPumpView(overlayView: $overlayView, authScreen: $authScreen, name: mapAPI.currentPin?.name ?? "")
                }
                if overlayView == .pumpDetails {
                    if let pump = mapAPI.pumps.first(where: { $0.id == mapAPI.currentPin?.locationId }){
                        let detailViewModel = DetailViewModel(pump: pump)
                        PumpDetailView(pump: pump, ldvm: detailViewModel, overlayView: $overlayView, authScreen: $authScreen)
                    }
                    
                }
                Spacer()
            }.background(.white)
        }
        
    }
}

#Preview {
    @State var overlayView: OverlaysViewStyle = .addView
    @State var showAuthView: Bool = false
    @State var pumpName: String = "Test"
    @StateObject var mapAPI = MapAPI()
    //OverlayView(overlayView: $overlayView, showAuthView: $showAuthView, pumpName: pumpName).environmentObject(mapAPI)
}
