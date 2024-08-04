//
//  MQTTManager.swift
//  ChatApp
//
//  Created by Anbalagan on 04/08/24.
//  Copyright © 2024 Admin. All rights reserved.
//

import MQTTNIO
import Foundation

final class MQTTManager {
    private let topic = "topic/state"
    
    static let shared = MQTTManager()
    
    private lazy var mqttClient = {
        let client = MQTTClient(
            configuration: .init(
                target: .host("192.168.31.2", port: 1883)
            ),
            eventLoopGroupProvider: .createNew
        )
        client.connect()
        return client
    }()
    
    private init() {
        subscripe()
        receiveMessage()
    }
    
    private func subscripe() {
        mqttClient.subscribe(
            to: [
                MQTTSubscription(
                    topicFilter: topic,
                    qos: .exactlyOnce
                )
            ]
        )
    }
    
    func sendMessage(message: String) {
        mqttClient.publish(
            MQTTMessage(
                topic: topic,
                payload: MQTTPayload.string(message, contentType: "text"),
                qos: .exactlyOnce
            )
        )
    }
    
    func receiveMessage() {
        Task {
            for await message in mqttClient.messages {
                print(message.payload.string ?? "NO MESSAGE")
            }
        }
    }
}
