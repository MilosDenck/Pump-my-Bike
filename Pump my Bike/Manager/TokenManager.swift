//
//  TokenManager.swift
//  Pump my Bike
//
//  Created by Milos Denck on 04.06.25.
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    
    private init() {}

    //keys
    private let accessKey = "accessKey"
    private let refreshKey = "refreshKey"
    private let accessKeyExpires = "accessKeyExpires"
    private let refreshKeyExpires = "refreshKeyExpires"
    private let loggedInKey = "loggedIn"
    private let frontTokenKey = "frontToken"
    private let verifykey = "verified"
    
    var loggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: loggedInKey) }
        set { UserDefaults.standard.set(newValue, forKey: loggedInKey) }
    }
    
    var verified: Bool {
        get { UserDefaults.standard.bool(forKey: verifykey) }
        set { UserDefaults.standard.set(newValue, forKey: verifykey) }
    }
    
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessKey) }
        set { UserDefaults.standard.set(newValue, forKey: accessKey) }
    }
    
    var frontToken: String? {
        get { UserDefaults.standard.string(forKey: frontTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: frontTokenKey) }
    }
    
    var accessTokenExpires: Date? {
        get { UserDefaults.standard.object(forKey: accessKeyExpires) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: accessKeyExpires) }
    }

    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshKey) }
        set { UserDefaults.standard.set(newValue, forKey: refreshKey) }
    }
    
    var refreshTokenExpires: Date? {
        get { UserDefaults.standard.object(forKey: refreshKeyExpires) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: refreshKeyExpires) }
    }
    
    func setTokens(accessToken: String?, accessTokenExpires: Date?, refreshToken: String?, refreshTokenExpires: Date?){
        UserDefaults.standard.set(accessToken, forKey: accessKey)
        UserDefaults.standard.set(accessTokenExpires, forKey: accessKeyExpires)
        UserDefaults.standard.set(refreshToken, forKey: refreshKey)
        UserDefaults.standard.set(refreshTokenExpires, forKey: refreshKeyExpires)
        UserDefaults.standard.set(true, forKey: loggedInKey)
    }

    func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessKey)
        UserDefaults.standard.removeObject(forKey: refreshKey)
        UserDefaults.standard.removeObject(forKey: accessKeyExpires)
        UserDefaults.standard.removeObject(forKey: refreshKeyExpires)
        UserDefaults.standard.removeObject(forKey: frontTokenKey)
        UserDefaults.standard.removeObject(forKey: verifykey)
        UserDefaults.standard.set(false, forKey: loggedInKey)
    }
}
