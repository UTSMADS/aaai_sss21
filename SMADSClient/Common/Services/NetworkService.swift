//
//  NetworkService.swift
//  Smds_app
//
//  Created by Asha Jain on 6/24/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation

struct NetworkConstants {
//    static let baseURL = Bundle.main.infoDictionary!["BASE_URL_ENDPOINT_SERVER"] as! String
//    static let baseWebsocketURL = Bundle.main.infoDictionary!["BASE_URL_ENDPOINT_WEBSOCKET"] as! String
    static let baseURL = "https://hypnotoad.csres.utexas.edu:8443"
    static let baseWebsocketURL = "wss://hypnotoad.csres.utexas.edu:8443/client/websocket"
////        static let baseURL = "https://ut-smads.herokuapp.com"
//        static let baseWebsocketURL = "wss://ut-smads.herokuapp.com/client/websocket"
    static let tokenKey = "token"
}

class NetworkService {
    static func addTokenToRequest(request:inout URLRequest){
        if let token = UserDefaults.standard.string(forKey: NetworkConstants.tokenKey) {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    static func get<S: Codable>(path: String, _ completion: @escaping (S?) -> ()) {
        return NetworkService.get(path: path, parameters: nil, authenticate: true, completion)
    }
    
    static func get<S: Codable>(path: String, parameters: [String: String], _ completion: @escaping (S?) -> ()) {
        return NetworkService.get(path: path, parameters: parameters, authenticate: true, completion)

    }

    static func get<S: Codable>(path: String, parameters: [String: String]?, authenticate: Bool, _ completion: @escaping (S?) -> ()) {
        var pathString = path
        if let parameters = parameters {
            pathString += "?\(parameters.queryString)"
        }
        return NetworkService.execute(path: "\(pathString)", body: "", method: "GET", completion)
    }
    
    static func post<R: Codable>(path: String, _ completion: @escaping (R?) -> ()) {
        return NetworkService.post(path: path, body: nil as String?, authenticate: true, completion)
    }
    
    static func post<Q: Codable, R: Codable>(path: String, body: Q?, _ completion: @escaping (R?) -> ()) {
        return NetworkService.post(path: path, body: body, authenticate: true, completion)
    }
    
    static func post<Q: Codable, R: Codable>(path: String, body: Q?, authenticate: Bool, _ completion: @escaping (R?) -> ()) {
        return NetworkService.execute(path: path, body: body, method: "POST", authenticate: authenticate, completion)
    }
    
    static func delete<Q: Codable, R: Codable>(path: String, body: Q?, authenticate: Bool = true, _ completion: @escaping (R?) -> ()) {
        return NetworkService.execute(path: path, body: body, method: "DELETE", completion)
    }
    
    static func delete<R: Codable>(path: String, authenticate: Bool = true, _ completion: @escaping (R?) -> ()) {
        return NetworkService.execute(path: path, body: "", method: "DELETE", completion)
    }
    
    static func put<R: Codable>(path: String, authenticate: Bool = true, _ completion: @escaping (R?) -> () ){
        return NetworkService.execute(path: path, body: "",
        method: "PUT", completion)
    }
    
    static func put<Q: Codable, R: Codable>(path: String, body: Q?, _ completion: @escaping (R?) -> ()) {
          return NetworkService.execute(path: path, body: body,
          method: "PUT", completion)
      }
    
    private static func execute<R: Codable, S: Codable>(path: String, body: R?, method: String, authenticate: Bool = true, _ completion: @escaping (S?) -> ()) {
        let urlString = "\(NetworkConstants.baseURL)\(path)"
        print("\(method) - \(urlString)")
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = method
            if method != "GET" {                
                request.httpBody = try? JSONEncoder().encode(body)
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if (authenticate) {
                NetworkService.addTokenToRequest(request: &request)
            }

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error executing \(method) request to \(NetworkConstants.baseURL)\(path): \(error)")
                    completion(nil)
                } else {
                    if let data = data {
                        do {
                            let response = try JSONDecoder().decode(S.self, from: data)
                            completion(response)
                        } catch {
                            print("Error decoding JSON \(S.self) in call to \(NetworkConstants.baseURL)\(path) - \(error.localizedDescription)")
                            if let str = String(data: data, encoding: .utf8) {
                                print("Received: \(str)")
                            }
                            completion(nil)
                        }
                    } else {
                        print("Error: Data returned is null in call to \(path)")
                        completion(nil)
                    }
                }
                
            }
            task.resume()
        }
    }
}

//extension NetworkService:NSObject, URLSessionDelegate {
//    
//      func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
//
//         // Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS
//
//         if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
//             if let serverTrust = challenge.protectionSpace.serverTrust {
//                 let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
//
//                 if(isServerTrusted) {
//                     if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
//                         let serverCertificateData = SecCertificateCopyData(serverCertificate)
//                         let data = CFDataGetBytePtr(serverCertificateData);
//                         let size = CFDataGetLength(serverCertificateData);
//                         let cert1 = NSData(bytes: data, length: size)
//                         let file_der = Bundle.main.path(forResource: "certificateFile", ofType: "der")
//
//                         if let file = file_der {
//                             if let cert2 = NSData(contentsOfFile: file) {
//                                 if cert1.isEqual(to: cert2 as Data) {
//                                     completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
//                                     return
//                                 }
//                             }
//                         }
//                     }
//                 }
//             }
//         }
//
//         // Pinning failed
//         completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
//     }
//}
