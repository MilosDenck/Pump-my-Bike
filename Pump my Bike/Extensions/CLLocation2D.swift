//
//  CLLocation2D.swift
//  Pump my Bike
//
//  Created by Milos Denck on 20.09.23.
//

import Foundation
import CoreLocation
import PhotosUI

extension CLLocationCoordinate2D{
    func dist(coordinates: CLLocationCoordinate2D) -> Double{
        let lat = self.latitude + coordinates.latitude / 2 * 0.01745
        let dx = 111.3  * cos(lat.toRadian()) * (self.longitude - coordinates.longitude)
        let dy = 111.3 * (self.latitude - coordinates.latitude)
        return sqrt(dx*dx + dy*dy)
    }
    
    
}

extension Double{
    func toRadian() -> (Double){
        Double.pi / 180 * self
    }
}

extension Data{
    mutating public func append(_ string: String) {
        if let data = string.data(using: .utf8){
            self.append(data)
        }
    }
}

