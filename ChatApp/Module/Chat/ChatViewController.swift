//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Anbalagan on 04/08/24.
//  Copyright © 2024 Admin. All rights reserved.
//

import UIKit

final class ChatViewController: UIViewController {
    private var chatTableView: UITableView!
    private var chatTextField: UITextField!
    
    private let lock = NSLock()
    private let mqttManager = MQTTManager.shared
    private var messages = [ChatMessage]()
    
    private let topic: String
    init(topic: String) {
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        registerCell()
        chatTableView.delegate = self
        chatTableView.dataSource = self
        listenIncommingMessage()
    }
    
    private func listenIncommingMessage() {
        Task {
            for await message in mqttManager.getMessage() {
                if let textMessage = message.payload.string {
                    lock.withLock {
                        messages.append(
                            ChatMessage(messageType: .incoming, message: textMessage)
                        )
                    }
                    
                    await MainActor.run {
                        chatTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc private func sendMessage() {
        if let message = chatTextField.text, !message.isEmpty {
            mqttManager.sendMessage(
                topic: topic,
                message: message
            )
            
            lock.withLock {
                messages.append(
                    ChatMessage(messageType: .outgoing, message: message)
                )
                chatTableView.reloadData()
            }
            
            chatTextField.text = ""
        }
    }
}

private extension ChatViewController {
    func setupView() {
        title = "Chat"
        view.backgroundColor = .systemBackground
        
        chatTableView = UITableView(frame: .zero)
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        chatTableView.separatorStyle = .none
        chatTableView.estimatedRowHeight = 120
        chatTableView.rowHeight = UITableView.automaticDimension
        view.addSubview(chatTableView)

        let chatBottomControlContainer = UIView(frame: .zero)
        chatBottomControlContainer.translatesAutoresizingMaskIntoConstraints = false
        chatBottomControlContainer.backgroundColor = .red
        view.addSubview(chatBottomControlContainer)
        
        chatTextField = UITextField(frame: .zero)
        chatTextField.translatesAutoresizingMaskIntoConstraints = false
        chatTextField.placeholder = "Type your message here"
        chatTextField.font = .systemFont(ofSize: 15)
        chatTextField.borderStyle = .roundedRect
        chatBottomControlContainer.addSubview(chatTextField)
        
        var sendButtonConfiguration = UIButton.Configuration.plain()
        sendButtonConfiguration.image = UIImage(systemName: "paperplane.circle.fill")
        sendButtonConfiguration.imagePadding = 0
        sendButtonConfiguration.contentInsets = .zero
        sendButtonConfiguration.cornerStyle = .capsule
        let sendButton = UIButton(configuration: sendButtonConfiguration)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.contentMode = .scaleToFill
        sendButton.backgroundColor = .green
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        chatBottomControlContainer.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            chatTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            chatTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: chatBottomControlContainer.bottomAnchor),
            
            chatBottomControlContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatBottomControlContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatBottomControlContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.bottomAnchor),
            
            chatTextField.leadingAnchor.constraint(equalTo: chatBottomControlContainer.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            chatTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -4),
            chatTextField.topAnchor.constraint(equalTo: chatBottomControlContainer.topAnchor, constant: 4),
            chatTextField.bottomAnchor.constraint(equalTo: chatBottomControlContainer.safeAreaLayoutGuide.bottomAnchor),
            chatTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.trailingAnchor.constraint(equalTo: chatBottomControlContainer.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            sendButton.topAnchor.constraint(equalTo: chatBottomControlContainer.topAnchor, constant: 4),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
        ])
        
        let bottomConstraint = chatBottomControlContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.priority = .init(249)
        bottomConstraint.isActive = true
    }
    
    func registerCell() {
        chatTableView.register(
            IncomingMessageCell.self,
            forCellReuseIdentifier: IncomingMessageCell.cellIdentifier
        )
        
        chatTableView.register(
            OutgoingMessageCell.self,
            forCellReuseIdentifier: OutgoingMessageCell.cellIdentifier
        )
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.messageType == .incoming {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: IncomingMessageCell.cellIdentifier,
                for: indexPath
            ) as! IncomingMessageCell
            cell.setupData(messages[indexPath.row].message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: OutgoingMessageCell.cellIdentifier,
                for: indexPath
            ) as! OutgoingMessageCell
            cell.setupData(messages[indexPath.row].message)
            return cell
        }
    }
}

#Preview {
    UINavigationController(rootViewController: ChatViewController(topic: ""))
}
