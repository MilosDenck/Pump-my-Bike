//
//  DetailViewModel.swift
//  Pump my Bike
//
//  Created by Milos Denck on 26.09.23.
//

import Foundation

class DetailViewModel: ObservableObject{
    @Published var filenames: [String]? = nil
    @Published var ratings: [Rating]? = nil
    private var pump: PumpData
    private var networkService = NetworkService()
    
    
    init(pump: PumpData) {
        self.pump = pump
        if let id = pump.id{
            getFilenames(id: id)
            getRatings(id: id)
        }
        
    }
    
    func getFilenames(id: Int){
        let url_string = "\(networkService.SERVER_IP)/images?id=\(id)"
        networkService.getRequest(url_string: url_string){ data, error in
            if error != nil{
                return
            }
            guard let data = data else{
                return
            }
            guard let files = try? JSONDecoder().decode([String].self, from: data) else {
                return
            }
            self.filenames = files
        }
    }
    
    
    
    func getRatings(id: Int){
        let url_string = "\(networkService.SERVER_IP)/ratings?id=\(id)"
        networkService.getRequest(url_string: url_string){ data, error in
            if error != nil{
                return
            }
            guard let data = data else{
                return
            }
            guard let files = try? JSONDecoder().decode([Rating].self, from: data) else {
                print("decode gone wrong")
                return
            }
            self.ratings = files
        }
    }
    
    func postDescription(id: Int, description: String){
        guard let data = try? JSONEncoder().encode(description) else{
            return
        }
        let url_string = "\(networkService.SERVER_IP)/description?id=\(id)"
        guard let url = URL(string: url_string) else{
            return
        }
        let request = networkService.generateRequest(httpBody: data, url: url, headerValues: ["application/json":"Content-Type"])
        networkService.postRequest(request: request)
    }
    
    
}
