//
//  UserDefaults.swift
//  Pump my Bike
//
//  Created by Milos Denck on 20.09.23.
//

import Foundation

class UserData: ObservableObject{
    @Published var userId : String? {
        didSet{
            UserDefaults.standard.set(userId, forKey: "userID")
        }
    }
    
    init() {
        if(UserDefaults.standard.string(forKey: "userID") == nil){
            self.userId = UUID().uuidString
        }else{
            self.userId = UserDefaults.standard.string(forKey: "userID")
        }
    }
}


