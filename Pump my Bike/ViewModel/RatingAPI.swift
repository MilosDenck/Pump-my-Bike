//
//  RatingAPI.swift
//  Pump my Bike
//
//  Created by Milos Denck on 07.06.25.
//

import Foundation

class RatingAPI: ObservableObject {
    
    let networkService: NetworkService = NetworkService()
    var loationId: Int?
    @Published var ratings: [RatingData]
    
    init() {
        self.loationId = nil
        self.ratings = []
    }
    
    
    @MainActor
    func updateRatings() async throws{
        self.ratings = try await getRatings()
        print(self.ratings)
    }
    
    
    func getRatings() async throws -> [RatingData] {
        let (data, res) = try await networkService.getRequest(url_string: "\(networkService.SERVER_IP)/ratings?id=\(loationId ?? 0)")
        
        guard (200..<300).contains(res.statusCode) else {
            return []
        }
        
        let jsonData = data as Data

        
        do {
            let decoded = try JSONDecoder().decode([RatingData].self, from: jsonData)
            return decoded
        } catch {
            print("Fehler beim Dekodieren: \(error)")
        }
        return []
        
    }
    
    func postRating(rating: Rating) async throws -> Double?{
        guard let url = URL(string:"\(networkService.SERVER_IP)/rating" )else{
            return nil
        }
        guard let data = try? JSONEncoder().encode(rating) else {
            return nil
        }
        var request = networkService.generateRequest(httpBody: data, url: url, headerValues: ["application/json":"Content-Type"])
        
        guard let cookieHeader = networkService.getTokenCookieHeader() else {
            TokenManager.shared.clearTokens()
            return nil
        }
        
        request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        request.setValue("session", forHTTPHeaderField: "rid")
        request.httpMethod = "POST"
        
        let (recData, res) = try await networkService.authorizedRequest(request: request)
        
        print(res.statusCode)
        
        guard let avgrating = String(data: recData, encoding: .utf8) else {
            return nil
        }

        guard let rating = Double(avgrating) else {
            return nil
        }
        
        return rating
    }
    
}
