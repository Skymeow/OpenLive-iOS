//
//  Authservice.swift
//  Streaming
//
//  Created by Sky Xu on 1/23/18.
//  Copyright © 2018 Sky Xu. All rights reserved.
//

import Foundation
import Alamofire

typealias CompletionHandler = (_ username: String?, _ userId: String?) -> ()

class AuthService {
    
    static let instance = AuthService()
    
    let defaults = UserDefaults.standard
    var isLoggedIn: Bool {
        get {
            return defaults.bool(forKey: "isRegistered")
        }
        set {
            defaults.set(newValue, forKey: "isRegistered")
        }
    }
    
//    var keychainLoggedIn: Bool {
//        get {
//
//        }
//
//        set {
//
//        }
//    }
    
    var authToken: String {
        get {
            return defaults.value(forKey: "TOKEN_KEY") as! String
        }
        set {
//            keychain.set
            defaults.set(newValue, forKey: "TOKEN_KEY")
        }
    }
   
    func registerUser(username: String, email: String, password: String, completion: @escaping CompletionHandler) {
        let lowerCaseEmail = email.lowercased()
        let body: [String: Any] = [
            "username": username,
            "email": lowerCaseEmail,
            "password": password
        ]
        let BASE_URL = Config.serverUrl + "/register"
        let HEADER = [
            "Content-Type": "application/json"
        ]
       
   
        Alamofire.request(BASE_URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER).responseJSON{ (response) in
            if response.result.error == nil {
                guard let json = response.result.value as? [String: Any] else { return }
                print(json)
                guard let name = json["username"],
                    let userId = json["_id"] else { return }
                self.isLoggedIn = true
                completion(name as? String, userId as? String)
            } else {
                completion(nil, nil)
                debugPrint(response.result.error as Any)
            }
        }
    }

}


