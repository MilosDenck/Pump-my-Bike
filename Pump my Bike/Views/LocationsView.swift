//
//  LocationView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.09.23.
//

import SwiftUI
import MapKit
import PhotosUI



struct LocationsView: View {
    
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    @StateObject private var mapAPI = MapAPI()
    @State private var text = ""
    @ObservedObject private var locationManager = LocationManager()
    
    @State private var showCardView: Bool = false
    @State private var showAddView: Bool = false
    
    @State private var currentLocation: CLLocationCoordinate2D?
    
    @State var userID: String?
    
    @State var showRatingView = false
    
    @ObservedObject var userData = UserData()
    
    
    @State private var longPressLocation: CGPoint? = nil
    
    
    //@State private var tapLocation: CLLocationCoordinate2D?
    @State var recording = false
    @State var tapped = false

    var body: some View {
        NavigationStack{
            ZStack{
                MapView
                UIItems
                if (showRatingView && !searchBarActive){
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
            }
            .alert(isPresented: $mapAPI.errorHandler.showError) {
                Alert(title: Text(mapAPI.errorHandler.errorMessage?.name ?? ""), message: Text(mapAPI.errorHandler.errorMessage?.massage ?? ""), dismissButton: .default(Text("OK")))
                    }
            .sheet(isPresented: $showAddView, content: {addView(name: mapAPI.currentPin?.name ?? "", showAddView: $showAddView).environmentObject(mapAPI)})
            .navigationBarHidden(true)
            
        }
        
    }
    
    var routeCard: some View{
        GeometryReader{ geometry in
            VStack{
                Spacer()
                VStack{
                    if let route = mapAPI.route{
                        Text("Route")
                            .frame(alignment: .leading)
                            .font(.system(size: 18))
                            .bold()
                        Rectangle().fill(.secondary)
                            .frame(width: geometry.size.width*0.85, height: 1)
                        Text("\(route.name) - \(mapAPI.currentPin!.name ?? "")")
                            .font(.system(size: 12))
                        Text(String(format: "%.1f km",route.distance/1000))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).fill(.ultraThinMaterial))
                .padding(10)
            }
        }
    }
    
    var UIItems: some View{
        VStack{
            if !mapAPI.showRoute{
                SearchBar
            }
            Spacer(minLength: 0)
            if(showCardView){
                LocationCardView(showAddView: $showAddView, currentLocation: $currentLocation, showRatingView: {
                    showRatingView = true
                    showCardView = false
                }, getRoute: {showCardView = false}).environmentObject(mapAPI)
            }
            if(mapAPI.showRoute){
                routeCard
            }
        }
    }
    
    @State private var visibleRegion: MKCoordinateRegion?
    
    var MapView: some View{

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
                            print("Tap 0")
                            if !showRatingView{
                                withAnimation{
                                    print("Tap 1")
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
    @FocusState private var searchBarActive: Bool

    var SearchBar: some View{
        
        VStack{
            HStack{
                if searchBarActive{
                    Button(action: {searchBarActive = false}, label: {
                        Image(systemName: "arrowshape.backward.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 3)
                    })
                }else{
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 3)
                }
                TextField("Search Location", text: $text)
                .focused($searchBarActive)
                .submitLabel(.search)
                .foregroundColor(.black)
                .onSubmit {
                    /*
                     mapAPI.getLocation(address: text, delta: 0.5)
                     showCardView = true*/
                    withAnimation{
                        mapAPI.searchPlace(name:text)
                        
                        if mapAPI.currentPin != nil{
                            showCardView = true
                        }
                    }
                }
                .onChange(of: text){
                    Task{
                        await mapAPI.getSeachPlaces(name: text)
                    }
                }
                Button(action: {
                    if(!searchBarActive){
                        if(locationManager.location != nil){
                            withAnimation{
                                mapAPI.searchPlacefromCoordinates(coordinates: locationManager.location!)
                            }
                        }
                    }
                }, label: {
                    Image(systemName: "location")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(.black)
                        .padding(.trailing,8)
                })
            }
            
            .padding(9)
            .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(.white).stroke(.gray, lineWidth: 1))
            .shadow(radius: 10)
            .padding()
            .onTapGesture {
                showCardView = false
            }
            if searchBarActive{
                ScrollView{
                    ForEach(mapAPI.searchItemList, id: \.placemark){ item in
                    
                        HStack{
                            Image(systemName: "mappin.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25)
                                .foregroundColor(.black)
                                .padding(.horizontal, 3)
                            VStack(alignment: .leading){
                                Text(item.name ?? "")
                                    .foregroundStyle(.black)
                                    .bold()
                                Text(item.placemark.title ?? "")
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                        }
                        .onTapGesture {
                            withAnimation{
                                mapAPI.updateSearchItem(item: item)
                                showCardView = true
                                searchBarActive = false
                            }
                        }
                            .padding(.leading, 15)
                        Rectangle().fill(.gray).frame(height: 1).frame(maxWidth: .infinity).padding(.horizontal, 10).padding(5)
                    }
                }
            }
        }
            .ignoresSafeArea(.keyboard)
            .background(searchBarActive ? .white : .clear)
    }
}




struct LocationsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsView()
    }
}
