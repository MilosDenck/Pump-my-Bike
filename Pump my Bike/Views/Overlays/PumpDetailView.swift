//
//  PumpDetailView.swift
//  Pump my Bike
//
//  Created by Milos Denck on 06.06.25.
//

import SwiftUI
import CoreLocation

struct PumpDetailView: View {
    @State var pump: PumpData
    @EnvironmentObject var mapAPI:MapAPI
    @StateObject var ldvm: DetailViewModel
    @StateObject var photoSelectorViewModel = PhotoSelectorViewModel()
    @Binding var overlayView: OverlaysViewStyle
    
    @StateObject var ratingAPI: RatingAPI = RatingAPI()
    
    @State var updateDescription: Bool = false
    @State var updatedDescription: String = ""
    @Binding var authScreen: AuthScreen
    
    @AppStorage("loggedIn") var loggedIn: Bool = false
    
    var body: some View {
        ScrollView{
            if let id = pump.id {
                NavigationLink(destination: PhotoUploader(id: id).environmentObject(mapAPI).environmentObject(photoSelectorViewModel).environmentObject(ldvm), label: {
                    PictureCarousel(pump: pump, ldvm: ldvm).environmentObject(photoSelectorViewModel)
                })
            }
            HStack{
                if(mapAPI.manager.location != nil){
                    Text(String(format: "%.1f km" , mapAPI.manager.location?.dist(coordinates: CLLocationCoordinate2D(latitude: pump.lat, longitude: pump.lon )) ?? 0))
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                
                if let opening = pump.openingHours{
                    if(opening.alwaysOpen || opening.isOpen()){
                        Text("open")
                            .foregroundColor(.green)
                    }else{
                        Text("closed")
                            .foregroundColor(.red)
                    }
                }
            }
            HStack{
                Text("Informations:")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .padding(.leading, 10)
                    .padding(.top,20)
                Spacer()
            }
            VStack{
                if !updateDescription {
                    TextBox(title: "Description", text: pump.description, action: {
                        updatedDescription = pump.description
                        updateDescription = true
                    })
                }else{
                    CustomTextField(title: "Description", text: $updatedDescription)
                }
                //.padding(pump.description == "" ? 0 : 10)
                OpeningHours2(pump: pump, ldvm: ldvm).environmentObject(mapAPI)
                    .padding(.top, 20)
            }
            .padding(5)
            HStack{
                Text("Ratings:")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .padding(.leading, 10)
                    .padding(.top,20)
                Spacer()
            }
            VStack{
                if(loggedIn){
                    RatingAddView(locationId: pump.id ?? 0).environmentObject(ratingAPI)
                }else{
                    VStack{
                        Text("Please log in to rate this pump")
                        CustomLongButton(title: "login", action: {
                            authScreen = .loginScreen
                        })
                        .padding(10)

                    }.padding(.vertical, 10)
                }
                VStack{
                    ForEach(ratingAPI.ratings, id: \.self.id){ rating in
                        Comment(rating: rating)
                    }
                }.padding(5)
            }.padding(5)
            Spacer()
        }.dismissKeyboardOnTap()
            .onAppear{
                Task{
                    ratingAPI.loationId = pump.id
                    try await ratingAPI.updateRatings()
                }
            }
    }
    
}

#Preview {
    //PumpDetailView()
}
