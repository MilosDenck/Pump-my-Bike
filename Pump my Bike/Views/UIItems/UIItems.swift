//
//  UItems.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.06.25.
//

import SwiftUI

enum UIItemsState: Hashable {
    case none
    case searchItems
    case menu
}

struct UIItems: View {
    @EnvironmentObject var mapAPI: MapAPI
    @State private var showSearchItems: Bool = false
    @State private var uiitemsState: UIItemsState = .none
    @Binding var authScreen: AuthScreen
    @FocusState private var searchBarActive: Bool
    
    var body: some View {
        VStack{
            SearchBar(searchBarActive: $searchBarActive ,uiitemsState: $uiitemsState).environmentObject(mapAPI)
            if(uiitemsState == .menu){
                Menu(authScreen: $authScreen)
            }
            if(uiitemsState == .searchItems){
                SearchItems(uiitemsState: $uiitemsState, searchBarActive: $searchBarActive).environmentObject(mapAPI)
            }
            
            Spacer()
        }
        .background(uiitemsState == .searchItems ? Color.white : Color.clear)
        
    }
}

#Preview {
    let mapAPI = MapAPI()
    @State var authScreen: AuthScreen = .none
    UIItems(authScreen: $authScreen).environmentObject(mapAPI)
}
