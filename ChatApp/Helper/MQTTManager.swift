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
    static let shared = MQTTManager()
    
    private var mqttClient: MQTTClient!
    
    func configure(
        host: String,
        port: Int,
        topic: String
    ) {
        mqttClient = MQTTClient(
            configuration: .init(
                target: .host(host, port: port)
            ),
            eventLoopGroupProvider: .createNew
        )
        mqttClient.connect()
        subscripe(topic: topic)
    }
    
    private func subscripe(topic: String) {
        mqttClient.subscribe(
            to: [
                MQTTSubscription(
                    topicFilter: topic,
                    qos: .exactlyOnce,
                    options: .init(noLocalMessages: true)
                )
            ]
        )
    }
    
    func sendMessage(
        topic: String,
        message: String
    ) {
        mqttClient.publish(
            MQTTMessage(
                topic: topic,
                payload: MQTTPayload.string(message, contentType: "text"),
                qos: .exactlyOnce
            )
        )
    }
    
    func getMessage() -> AsyncStream<MQTTMessage> {
        return mqttClient.messages
    }
}
