//
//  NetworkService.swift
//  Pump my Bike
//
//  Created by Milos Denck on 25.09.23.
//

import Foundation

class NetworkService{
    
    
    public let SERVER_IP = "https://pmb-api.milosdenck.de"
    //public let SERVER_IP = "http://100.97.176.235:8000" //for Development
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
                completionBlock(nil, err)
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
    
    func getRequest(url_string: String) async throws -> (Data, HTTPURLResponse){
        
        guard let url = URL(string: url_string) else {
            throw URLError(.badServerResponse)
        }
        
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, httpResponse)
    }
    
    func postRequest(request: URLRequest, completionBlock: @escaping (Data, URLResponse?, Error?) -> Void = {_,_,_  in }){
        URLSession.shared.dataTask(with: request){ (data, response, error) in
            if let data = data{
                completionBlock(data, response, error)
            }
        }.resume()
    }
    
    func postRequest(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, httpResponse)
    }
    
    func authorizedRequest(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 401 {
            let (success, errorMessage) = try await AuthManager.shared.refreshSession()
            guard success else {
                throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            
            // Request nach erfolgreichem Refresh nochmal versuchen
            let (newData, newResponse) = try await URLSession.shared.data(for: request)
            guard let newHttpResponse = newResponse as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            return (newData, newHttpResponse)
        }
        
        return (data, httpResponse)
    }

    
    func getAccessTokenCookie() -> HTTPCookie? {
        
        guard let accessToken = TokenManager.shared.accessToken else{
            return nil
        }
        
        return HTTPCookie(properties: [
            .domain: SERVER_IP,
            .path: "/",
            .name: "sAccessToken",
            .value: accessToken
        ])!
    }
    
    func getRefreshTokenCookie() -> HTTPCookie? {
        
        guard let refreshToken = TokenManager.shared.refreshToken else{
            return nil
        }
        
        return HTTPCookie(properties: [
            .domain: SERVER_IP,
            .path: "/",
            .name: "sRefreshToken",
            .value: refreshToken
        ])!
    }
    
    func getFrontTokenCookie() -> HTTPCookie? {
        
        guard let frontToken = TokenManager.shared.frontToken else{
            return nil
        }
        
        return HTTPCookie(properties: [
            .domain: SERVER_IP,
            .path: "/",
            .name: "sFrontToken",
            .value: frontToken
        ])!
    }
    
    func getTokenCookieHeader() -> String? {
        guard let accessToken = getAccessTokenCookie() else{
            return nil
        }
        guard let refreshToken = getRefreshTokenCookie() else{
            return nil
        }
        let cookies: [HTTPCookie] = [accessToken, refreshToken]
        let cookieHeader = cookies
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")
        return cookieHeader
    }
}
