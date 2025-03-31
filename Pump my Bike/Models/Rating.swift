//
//  Ratings.swift
//  Pump my Bike
//
//  Created by Milos Denck on 22.09.23.
//

import Foundation


struct Rating: Codable, Hashable{
    var rating: Int
    var comment: String
    var locationId: Int
}
