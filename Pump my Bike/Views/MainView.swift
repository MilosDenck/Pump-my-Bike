//
//  LocationView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.09.23.
//

import SwiftUI
import MapKit
import PhotosUI



struct MainView: View {
    
    

    @ObservedObject private var locationManager = LocationManager()
        
    @State private var showCardView: Bool = false
    @State private var showAddView: Bool = false
    
    @State var overlayView: OverlaysViewStyle = .none
    
    @State private var currentLocation: CLLocationCoordinate2D?
    
    @State var userID: String?
    @State var showRatingView = false
    
    @ObservedObject var userData = UserData()
    
    @State private var authScreen: AuthScreen = .none
    @AppStorage("verified") var verfied: Bool=true
    
    @EnvironmentObject var mapAPI: MapAPI
    @EnvironmentObject var handler: ErrorHandler2

    var body: some View {
        NavigationStack{
            ZStack{
                MapView(showRatingView: $showRatingView, showCardView: $showCardView)
                if(showCardView){
                    CardView(overlayView: $overlayView, currentLocation: $currentLocation, showRatingView: {
                        showRatingView = true
                        showCardView = false
                    }, getRoute: {showCardView = false})
                }
                if(mapAPI.showRoute){
                    RouteCard()
                }
                UIItems(authScreen: $authScreen)
                if (showRatingView ){
                    if let locID = mapAPI.currentPin?.locationId{
                        RatingView(locationId: locID, showRatingView: {
                            showRatingView.toggle()
                            showCardView.toggle()
                        })
                            .padding(10)
                            .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.ultraThinMaterial))
                            .padding(10)
                    }
                }
                OverlayView(overlayView: $overlayView, authScreen: $authScreen)
                if (authScreen != .none){
                    AuthView(authScreen: $authScreen)
                }
                if(!verfied){
                    VerifyEmailView()
                }
                
            }
            .alert(isPresented: $handler.isShowingError) {
                Alert(title: Text(handler.errorTitle ?? ""), message: Text(handler.errorMessage ?? ""), dismissButton: .default(Text("OK")))
                    }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    try await initApp()
                }
            }
            
        }
        
    }
    
    func initApp() async throws{
        let (sessionValid, error) = try await AuthManager.shared.refreshSession()
        if (!sessionValid){
            handler.showError(message: error, title: "session expired")
            TokenManager.shared.clearTokens()
            authScreen = .loginScreen
        }
        try await mapAPI.loadData()
    }
}




struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
