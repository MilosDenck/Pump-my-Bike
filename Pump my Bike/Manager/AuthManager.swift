//
//  AuthManager.swift
//  Pump my Bike
//
//  Created by Milos Denck on 05.06.25.
//

import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    let networkService: NetworkService

    private init() {
        networkService = NetworkService()
    }
    
    func login(email: String, password: String) async throws -> (Bool, String) {
        guard let url = URL(string: "\(networkService.SERVER_IP)/auth/signin") else {
            return (false, "client error")
        }
        
        let verified = true

        let formFields: [[String: Any]] = [
            ["id": "email", "value": email],
            ["id": "password", "value": password]
        ]

        let body: [String: Any] = [
            "formFields": formFields
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            return (false, "client error")
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = data
        req.addValue("emailpassword", forHTTPHeaderField: "rid")
        req.addValue("cookie", forHTTPHeaderField: "st-auth-mode")
        
        let (resposeData, response) = try await networkService.postRequest(request: req)
        
        guard response.statusCode == 200 else {
            return (false, "server error")
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: resposeData) as? [String: Any] else {
                return (false, "client error")
            }

            guard let status = json["status"] as? String else {
                return (false, "client error")
            }
            
            if status != "OK" {
                return (false, "username or password incorrect")
            }
            
            if let user = json["user"] as? [String: Any],
            let loginMethods = user["loginMethods"] as? [[String: Any]],
            let firstLogin = loginMethods.first,
               let verified = firstLogin["verified"] {
                if verified as! Int == 0 {
                    TokenManager.shared.verified=false
                }
            }
    
        } catch {
            return (false, "client error")
        }
        
        let headers = response.allHeaderFields as NSDictionary as! [String: AnyObject] as! [String : String]
        let parsedCookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: response.url!)
        
        
        guard let accessToken = parsedCookies.first(where: { $0.name == "sAccessToken" }) else {
            return (false, "client error")
        }
        
        guard let refreshToken = parsedCookies.first(where: { $0.name == "sRefreshToken" }) else {
            return (false, "client error")
        }
        
        TokenManager.shared.setTokens(accessToken: accessToken.value, accessTokenExpires: accessToken.expiresDate, refreshToken: refreshToken.value, refreshTokenExpires: refreshToken.expiresDate)
        return (true, "success")
    }
    
    
    func refreshSession() async throws -> (Bool, String) {
        
        guard let url = URL(string: "\(networkService.SERVER_IP)/auth/session/refresh") else {
            return (false, "client error")
        }
        
        var req = URLRequest(url: url)
        
        guard let cookieHeader = networkService.getTokenCookieHeader() else {
            TokenManager.shared.clearTokens()
            return (false, "client error")
        }
        
        req.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        req.setValue("session", forHTTPHeaderField: "rid")
        req.httpMethod = "POST"
        
        let (resposeData, httpResponse) = try await URLSession.shared.data(for: req)
        guard let response = httpResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if(response.statusCode != 200){
            if(response.statusCode == 401){
                return (false, "session expired")
            }else{
                return (false, "server error")
            }
        }
        
        let headers = response.allHeaderFields as NSDictionary as! [String: AnyObject] as! [String : String]
        let parsedCookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: response.url!)
        
        guard let accessToken = parsedCookies.first(where: { $0.name == "sAccessToken" }) else {
            return (false, "client error")
        }
        
        guard let refreshToken = parsedCookies.first(where: { $0.name == "sRefreshToken" }) else {
            return (false, "client error")
        }
        
        TokenManager.shared.setTokens(accessToken: accessToken.value, accessTokenExpires: accessToken.expiresDate, refreshToken: refreshToken.value, refreshTokenExpires: refreshToken.expiresDate)
        
        return (true, "success")
        
    }
    
    
    func mailExist(mail: String) async throws -> Bool{
        
        guard let url = URL(string: "\(networkService.SERVER_IP)/auth/emailpassword/email/exists") else {
            return false
        }
        
        let queryData = URLQueryItem(name: "email", value: mail)
        let newUrl = url.appending(queryItems: [queryData])
        var req = URLRequest(url: newUrl)
        req.httpMethod = "GET"
        
        
        let (responseData, res) = try await networkService.postRequest(request: req)
        
        if res.statusCode != 200 {
            return false
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
                return false
            }

            guard let status = json["status"] as? String else {
                return false
            }
            
            if status != "OK" {
                return true
            }
    
        }
        return false
    }
    
    func singUp(email: String, password: String, username: String) async throws -> (Bool, String){
        guard let url = URL(string: "\(networkService.SERVER_IP)/auth/signup") else {
            return (false, "client error")
        }

        let formFields: [[String: Any]] = [
            ["id": "email", "value": email],
            ["id": "password", "value": password],
            ["id": "username", "value": username]
        ]

        let body: [String: Any] = [
            "formFields": formFields
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            return (false, "client error")
        }


        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = data
        req.addValue("emailverification", forHTTPHeaderField: "rid")
        req.addValue("cookie", forHTTPHeaderField: "st-auth-mode")
        let (resposeData, response) = try await networkService.postRequest(request: req)
                
        guard response.statusCode == 200 else {
            return (false, "server error")
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: resposeData) as? [String: Any] else {
                return (false, "client error")
            }
            guard let status = json["status"] as? String else {
                print("cannot get status")
                return (false, "client error")
            }
            if status == "FIELD_ERROR" {
                if let formFields = json["formFields"] as? [[String: Any]], let firstField = formFields.first,
                let errorMessage = firstField["error"] as? String {
                    return (false, errorMessage)
                }
                return (false, "server error")
            }
            
        }
                
        let headers = response.allHeaderFields as NSDictionary as! [String: AnyObject] as! [String : String]
        let parsedCookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: response.url!)
        
        
        guard let accessToken = parsedCookies.first(where: { $0.name == "sAccessToken" }) else {
            return (false, "client error")
        }
        
        guard let refreshToken = parsedCookies.first(where: { $0.name == "sRefreshToken" }) else {
            return (false, "client error")
        }
        
        guard let frontToken = headers["front-token"] else {
            return (false, "client error")
        }
        
        TokenManager.shared.accessToken = accessToken.value
        TokenManager.shared.refreshToken = refreshToken.value
        TokenManager.shared.frontToken = frontToken
        
        return (true , "success")
    }
    
    func verifyMail() async throws -> Bool {
        
        guard let url = URL(string: "\(networkService.SERVER_IP)/auth/user/email/verify") else {
            return false
        }
        
        guard let accessToken = networkService.getAccessTokenCookie(),
              let refreshToken = networkService.getRefreshTokenCookie(),
              let frontToken = networkService.getFrontTokenCookie()
        else{
            TokenManager.shared.clearTokens()
            return false
        }
    
        
        let cookies: [HTTPCookie] = [accessToken, refreshToken, frontToken]
        
        let cookieHeader = cookies
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")
        
        var req = URLRequest(url: url)
        
        req.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        req.addValue("emailverification", forHTTPHeaderField: "rid")
        req.addValue("cookie", forHTTPHeaderField: "st-auth-mode")
        req.httpMethod = "GET"
        
        let (_, httpResponse) = try await URLSession.shared.data(for: req)
        
        guard let response = httpResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if(response.statusCode != 200){
            return false
        }
                
        let headers = response.allHeaderFields as NSDictionary as! [String: AnyObject] as! [String : String]
        let parsedCookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: response.url!)
                
        guard let accessToken = parsedCookies.first(where: { $0.name == "sAccessToken" }) else {
            return false
        }
        
        guard let frontToken = headers["front-token"] else {
            return false
        }
                
        TokenManager.shared.accessToken = accessToken.value
        TokenManager.shared.frontToken = frontToken
        
        return true
    }
    
    
    func resendVerificationEmail() async throws -> Bool {
        
        guard let url = URL(string: "\(networkService.SERVER_IP)/verify/resend") else {
            return false
        }

        
        let cookieHeader = networkService.getTokenCookieHeader()!
        
        var req = URLRequest(url: url)
        
        req.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        req.addValue("emailverification", forHTTPHeaderField: "rid")
        req.addValue("cookie", forHTTPHeaderField: "st-auth-mode")
        req.httpMethod = "GET"
        
        let (_, httpResponse) = try await URLSession.shared.data(for: req)
        
        guard let response = httpResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print(response.statusCode)

        if(response.statusCode != 200){
            return false
        }
        
        return true
    }
    
    func verifySession() async throws -> Bool {
        
        guard let url = URL(string: "\(networkService.SERVER_IP)/verify/session") else {
            return false
        }

        
        let cookieHeader = networkService.getTokenCookieHeader()!
        
        var req = URLRequest(url: url)
        
        req.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        req.addValue("emailverification", forHTTPHeaderField: "rid")
        req.addValue("cookie", forHTTPHeaderField: "st-auth-mode")
        req.httpMethod = "GET"
        
        let (_, httpResponse) = try await URLSession.shared.data(for: req)
        
        guard let response = httpResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print(response.statusCode)

        if(response.statusCode != 200){
            return false
        }
        
        return true
    }
    
    func verifyMailToken() async throws -> Bool {
        
        guard let url = URL(string: "\(networkService.SERVER_IP)/auth/user/email/verify/token") else {
            return false
        }
        
        guard let accessToken = networkService.getAccessTokenCookie(),
              let frontToken = networkService.getFrontTokenCookie()
        else{
            TokenManager.shared.clearTokens()
            return false
        }
    
        
        let cookies: [HTTPCookie] = [accessToken, frontToken]
        
        let cookieHeader = cookies
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")
        
        var req = URLRequest(url: url)
        
        req.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        req.addValue("emailverification", forHTTPHeaderField: "rid")
        req.addValue("cookie", forHTTPHeaderField: "st-auth-mode")
        req.httpMethod = "POST"
        
        let (httpData, httpResponse) = try await URLSession.shared.data(for: req)
        guard let response = httpResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if(response.statusCode != 200){
            return false
        }
        
        
                
        TokenManager.shared.clearTokens()
        
        return true
    }
    
    func resetPassword(email: String) async throws -> (Bool, String) {
        guard let url = URL(string: "\(networkService.SERVER_IP)/auth/user/password/reset/token") else {
            return (false, "client error")
        }

        let formFields: [[String: Any]] = [
            ["id": "email", "value": email]
        ]

        let body: [String: Any] = [
            "formFields": formFields
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            return (false, "client error")
        }


        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = data
        let (resposeData, response) = try await networkService.postRequest(request: req)

        
        guard response.statusCode == 200 else {
            return (false, "server error")
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: resposeData) as? [String: Any] else {
                return (false, "client error")
            }

            guard let status = json["status"] as? String else {
                return (false, "client error")
            }
            
            if status != "OK" {
                if let formFields = json["formFields"] as? [[String: Any]], let firstField = formFields.first,
                let errorMessage = firstField["error"] as? String {
                    return (false, errorMessage)
                }
                return (false, "server error")
            }
    
        } catch {
            return (false, "client error")
        }

        return (false, "client error")
    }
    
    func logout() async throws {
        
        guard let url = URL(string: "\(networkService.SERVER_IP)/auth/signout") else {
            return
        }
        
        var req = URLRequest(url: url)
        
        guard let cookieHeader = networkService.getTokenCookieHeader() else {
            TokenManager.shared.clearTokens()
            return
        }
        
        req.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        req.setValue("session", forHTTPHeaderField: "rid")
        req.httpMethod = "POST"
        
        let (httpData, httpResponse) = try await URLSession.shared.data(for: req)
        guard let response = httpResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
                
        do {
            guard let json = try JSONSerialization.jsonObject(with: httpData) as? [String: Any] else {
                return
            }
        }

        if(response.statusCode != 200){
            if(response.statusCode == 401){
                TokenManager.shared.clearTokens()
                return
            }else{
                return
            }
        }
        TokenManager.shared.clearTokens()
    }
}
