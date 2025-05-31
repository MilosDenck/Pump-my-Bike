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
    
    @StateObject private var mapAPI = MapAPI()

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

    var body: some View {
        NavigationStack{
            ZStack{
                MapView(showRatingView: $showRatingView, showCardView: $showCardView).environmentObject(mapAPI)
                if(showCardView){
                    CardView(overlayView: $overlayView, currentLocation: $currentLocation, showRatingView: {
                        showRatingView = true
                        showCardView = false
                    }, getRoute: {showCardView = false}).environmentObject(mapAPI)
                }
                if(mapAPI.showRoute){
                    RouteCard().environmentObject(mapAPI)
                }
                UIItems(authScreen: $authScreen).environmentObject(mapAPI)
                if (showRatingView ){
                    if let locID = mapAPI.currentPin?.locationId{
                        RatingView(locationId: locID, showRatingView: {
                            showRatingView.toggle()
                            showCardView.toggle()
                        }).environmentObject(mapAPI)
                            .padding(10)
                            .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.ultraThinMaterial))
                            .padding(10)
                    }
                }
                OverlayView(overlayView: $overlayView, authScreen: $authScreen).environmentObject(mapAPI)
                if (authScreen != .none){
                    AuthView(authScreen: $authScreen)
                }
                if(!verfied){
                    VerifyEmailView()
                }
                
            }
            .alert(isPresented: $mapAPI.errorHandler.showError) {
                Alert(title: Text(mapAPI.errorHandler.errorMessage?.name ?? ""), message: Text(mapAPI.errorHandler.errorMessage?.massage ?? ""), dismissButton: .default(Text("OK")))
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
            TokenManager.shared.clearTokens()
            authScreen = .loginScreen
        }
        await mapAPI.loadData()
    }
}




struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
