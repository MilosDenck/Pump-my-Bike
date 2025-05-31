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



struct RatingData: Decodable {
    let id: Int
    let rating: Int
    let comment: String
    let createdAt: String
    let username: String

    private enum CodingKeys: String, CodingKey {
        case id
        case rating
        case comment
        case createdAt
        case username = "user.username"
    }
}
