//
//  NetworkService.swift
//  Pump my Bike
//
//  Created by Milos Denck on 25.09.23.
//

import Foundation

class NetworkService{
    
    public let SERVER_IP = "http://192.168.178.36:8000"
    
    func generateRequest(httpBody: Data, url: URL, headerValues: [String:String]) -> URLRequest{
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        for keyValuePair in headerValues{
            request.setValue(keyValuePair.key, forHTTPHeaderField: keyValuePair.value)
        }
        request.httpBody = httpBody
        return request
    }
    
    func getRequest(url_string: String,  completionBlock: @escaping (Data?, Error?) -> Void = {_,_  in }){
        
        guard let url = URL(string: url_string) else {
            print("invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url){ (data, response, error) in
            
            if let err = error{
                completionBlock(nil, error)
                return
            }
            
            guard let data = data else {
                print(error!.localizedDescription)
                return
            }

                        
            DispatchQueue.main.async {
                completionBlock(data, nil)
            }
        }.resume()
        
    }
    
    func postRequest(request: URLRequest, completionBlock: @escaping (Data) -> Void = {_ in }){
        URLSession.shared.dataTask(with: request){ (data, response, error) in
            if let data = data{
                completionBlock(data)
            }
        }.resume()
    }
    
}
