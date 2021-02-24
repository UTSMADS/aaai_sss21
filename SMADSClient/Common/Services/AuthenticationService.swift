//
//  AuthenticationService.swift
//  Smds_app
//
//  Created by Asha Jain on 6/24/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

public class AuthenticationService{
    func loginUser( email:String, password:String, completion: @escaping (AuthenticationResponse?) -> ()) {
        let authRequest = AuthenticationRequest(username: email, password: password, name: "")
        NetworkService.post(path: "/auth/login", body: authRequest, authenticate: false) { (authResponse: AuthenticationResponse?) in
            self.handleAuthResponse(authResponse, completion: completion)
        }
    }
    
    func signupUser(name:String, email:String, password:String, completion: @escaping (AuthenticationResponse?)->()){
        let authRequest = AuthenticationRequest(username: email, password: password, name: name)
        NetworkService.post(path: "/auth/signup", body: authRequest, authenticate: false) { (authResponse: AuthenticationResponse?) in
            self.handleAuthResponse(authResponse, completion: completion)
        }
    }
    
    func registerUser(idToken: String, completion: @escaping (AuthenticationResponse?)->())
    {
        let googleAuthRequest = GoogleAuthenticationRequest(idToken: idToken)
        NetworkService.post(path: "/auth/registerGoogleUser", body: googleAuthRequest, authenticate: false) { (googleAuthResponse: AuthenticationResponse?) in
            self.handleAuthResponse(googleAuthResponse, completion: completion)

        }
        
    }
  
    
    fileprivate func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: NetworkConstants.tokenKey)
    }
    func isTokenValid(validtoken: Bool) {
        UserDefaults.standard.bool( forKey: NetworkConstants.tokenKey)
    }
    
    fileprivate func handleAuthResponse(_ response: AuthenticationResponse?, completion: @escaping (AuthenticationResponse?)->()) {
        if let authResponse = response, let userToken = authResponse.token {
            saveToken(token: userToken)
        
            completion(authResponse)
        } else {
            completion(nil)
        }
    }
    
    func validateToken(_ completion: @escaping (ValidTokenResponse?) -> ()) {
        NetworkService.post(path: "/auth/validateToken", completion)
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: NetworkConstants.tokenKey)
        print("Logged out -- Cleared token")
    }
}
