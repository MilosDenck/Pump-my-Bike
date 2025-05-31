//
//  Pump_my_BikeApp.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.09.23.
//

import SwiftUI

@main
struct Pump_my_BikeApp: App {
    
    @AppStorage("UserID") private var userIDString: String?
    
    init() {
        if(userIDString == nil){
            self.userIDString = UUID().uuidString
        }
    }
    

    var body: some Scene {
        WindowGroup {
            MainView(userID: userIDString)//.environmentObject(vm)
        }
    }
}
