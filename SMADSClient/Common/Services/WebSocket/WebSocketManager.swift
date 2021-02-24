//
//  WebSocketManager.swift
//  Smds_app
//
//  Created by Asha Jain on 8/25/20.
//  Copyright © 2020 SMADS. All rights reserved.
//

import Foundation
import StompClientLib
import UserNotifications

let socketManager = SocketManager()

class SocketManager {
    private var sharedSocket = StompClientLib()
    private var isConnected = false
    private let baseURL = NetworkConstants.baseWebsocketURL
    private var topics = Set<String>()
    private let baseTopic = "/topic"
    private static let sessionId = UUID().description
    private let reconnectDelay = 10
    private var topicHandlers = [String: (String?) -> ()]()
    
    func connect() {
        if let socketURL = NSURL(string: baseURL), let token = UserDefaults.standard.string(forKey: NetworkConstants.tokenKey) {
            var headers = [String: String]()
            headers["Authorization"] = "Bearer \(token)"
            headers["sec-websocket-protocol"] = "v10.stomp, v11.stomp"
            headers["SessionId"] = SocketManager.sessionId.description
            sharedSocket.openSocketWithURLRequest(request: NSURLRequest(url: socketURL as URL), delegate: self, connectionHeaders: headers)
            print("SessionId: \(SocketManager.sessionId)")
            isConnected = true
        }
    }
    
    func subscribe(to topic: String, _ handler: @escaping (String?) -> ()) {
        let fullTopic = "\(baseTopic)/\(topic)"
        topics.insert(fullTopic)
        sharedSocket.subscribe(destination: fullTopic)
        print("Subscribing to topic: \(fullTopic)")
        topicHandlers[fullTopic] = handler
    }
    
    func unsubscribe(from topic: String) {
        let fullTopic = "\(baseTopic)/\(topic)"
        topics.remove(fullTopic)
        print("Unsibscribing from \(fullTopic)")
        sharedSocket.unsubscribe(destination: fullTopic)
        topicHandlers[fullTopic] = nil
    }
    
    func subscribeToSpotAlert() {
        let topic = "spotAlert"
        subscribe(to: topic) { response in
            print("Received Spot Alert")
            if let response = response {
                do {
                    if let data = response.data(using: .utf8) {
                        let missingSpot = try JSONDecoder().decode(Spot.self, from: data)
                        self.showMissingSpotNotification(spotId: missingSpot.manufacturerID, name: missingSpot.name, status: missingSpot.status)
                    }
                } catch {
                    print("Error decoding JSON \(Trip.self) in call to \(topic)")
                }
            }
        }
    }
    
    func showMissingSpotNotification(spotId: Int, name: String, status: SpotStatus) {
        let content = UNMutableNotificationContent()
        print("Spot notification: Status: \(status)")
        if status == .reconnectingToInternet || status == .outofservice {
            content.title = "Missing spot"
            content.body = "\(name) has gone missing alert 🚨⚠️🤖 - Status: \(status == .reconnectingToInternet ? "Reconnecting to the Internet (WiFi temporarily lost)" : "Out of service")"
        } else {
            content.title = "Spot back online"
            content.body = "\(name) is back online ✅🤖 - Status: \(status)"
        }
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "missingRobot-\(spotId)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

extension SocketManager: StompClientLibDelegate {
    func stompClientDidConnect(client: StompClientLib!) {
        print("Session connected!")
        for topic in topics {
            client.subscribe(destination: topic)
            print("Subscribing to topic \(topic)")
        }
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        print("Socket did disconnect --- Trying to reconnect")
        sharedSocket = StompClientLib()
        attemptReconnect()
        isConnected = false
    }

    private func attemptReconnect() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(reconnectDelay)) {
            self.connect()
        }
    }

    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        print("Received message for topic: \(destination)")
        if let handler = topicHandlers[destination] {
            handler(stringBody)
        }
    }

    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("Receipt: \(receiptId)")
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print("Socket error: \(description)")
        attemptReconnect()
    }
    
    func serverDidSendPing() {
        print("Server ping")
    }
}
