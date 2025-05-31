//
//  AddViewModel.swift
//  Pump my Bike
//
//  Created by Milos Denck on 20.09.23.
//

import Foundation
import MapKit


@MainActor
class pumpAddViewModel:ObservableObject{
    @Published var name: String
    @Published var description: String = ""
    @Published var photoSelectorViewModel = PhotoSelectorViewModel()
    
    
    func getData(name: String, location: CLLocationCoordinate2D) -> PumpData{
        return PumpData(name: name, lat: location.latitude, lon: location.longitude, description: self.description, openingHours:  nil)
    }
    
    init(name: String = "" , description: String = "") {
        self.name = name
        self.description = description
    }
    
}



