//
//  ChatMessage.swift
//  ChatApp
//
//  Created by Anbalagan on 05/08/24.
//  Copyright © 2024 Admin. All rights reserved.
//

import Foundation

enum ChatMessageType {
    case incoming
    case outgoing
}

struct ChatMessage {
    let messageType: ChatMessageType
    let message: String
}
