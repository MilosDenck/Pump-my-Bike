//
//  SearchBar.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.06.25.
//

import SwiftUI

struct SearchBar: View {
    
    @FocusState.Binding var searchBarActive: Bool
    @EnvironmentObject var mapAPI: MapAPI
    private let locationManager = LocationManager()
    @State private var searchText: String = ""
    @Binding var uiitemsState: UIItemsState
    
    var body: some View {
        VStack{
            HStack{
                if uiitemsState == .searchItems || uiitemsState == .menu {
                    Button(action: {
                        uiitemsState = UIItemsState.none
                        searchBarActive = false
                    }, label: {
                        Image(systemName: "arrowshape.backward.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 3)
                    })
                }else{
                    Button(action: {
                        if(uiitemsState == .menu){
                            uiitemsState = .none
                        }else{
                            uiitemsState = .menu
                        }

                    }, label: {
                        Image(systemName: "line.horizontal.3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 3)
                    })
                    
                }
                TextField("Search Location", text: $searchText)
                    .focused($searchBarActive)
                    .onChange(of: searchBarActive) { _, focused in
                        if searchBarActive {
                            uiitemsState = .searchItems
                        } else {
                            uiitemsState = .none
                        }
                    }
                    .submitLabel(.search)
                    .foregroundColor(.black)
                    .onSubmit {
                        
                        withAnimation{
                            mapAPI.searchPlace(name: searchText)
                            searchBarActive = false
                            uiitemsState = .none
                        }
                    }
                    .onChange(of: searchText){
                        Task{
                            await mapAPI.getSeachPlaces(name: searchText)
                        }
                    }
                Button(action: {
                    
                    guard let loc = locationManager.location else {
                        return
                    }
                    withAnimation{
                        mapAPI.searchPlacefromCoordinates(coordinates: loc)
                        mapAPI.updateRegion(coordinates: loc, span: mapAPI.region.span)
                        searchBarActive = false
                        uiitemsState = .none
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
            .padding(15)
            .background(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)).fill(.white).stroke(.gray, lineWidth: 1))
            .shadow(radius: searchBarActive ? 0 : 7)
            .padding()
            .onTapGesture {
             //   showCardView = false
            }
        }
    }

}



#Preview {
    @Previewable @State var uiitemsState: UIItemsState = .searchItems
    let mapAPI = MapAPI()
    //SearchBar(uiitemsState: $uiitemsState).environmentObject(mapAPI)
}
