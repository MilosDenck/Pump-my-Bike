//
//  SearchItems.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.06.25.
//

import SwiftUI

struct SearchItems: View {
    @EnvironmentObject var mapAPI: MapAPI
    @Binding var uiitemsState: UIItemsState
    @FocusState.Binding var searchBarActive: Bool
    var body: some View {
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
                        uiitemsState = .none
                        searchBarActive = false
                        mapAPI.updateSearchItem(item: item)
                        guard let coordinate = item.placemark.location?.coordinate else { return
                        }
                        mapAPI.updateRegion(coordinates: coordinate, span: mapAPI.region.span)
                        //showCardView = true
                        //searchBarActive = false
                    }
                }
                    .padding(.leading, 15)
                Rectangle().fill(.gray).frame(height: 1).frame(maxWidth: .infinity).padding(.horizontal, 10).padding(5)
            }
        }

    }
}

#Preview {
    let mapAPI = MapAPI()
   // SearchItems().environmentObject(mapAPI)
}
