//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Anbalagan on 04/08/24.
//  Copyright © 2024 Admin. All rights reserved.
//

import UIKit

enum ChatSection: CaseIterable {
    case all
}

final class ChatViewController: UIViewController {
    private var chatTableView: UITableView!
    private var chatTextViewPlaceholderLabel: UILabel!
    private var chatTextView: UITextView!
    
    private let lock = NSLock()
    private let mqttManager = MQTTManager.shared
    private var messages = [ChatMessage]()
    private lazy var diffableDataSource = makeDataSource()
    
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
        chatTableView.dataSource = diffableDataSource
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
                    updateDataSource(message: messages)
                }
            }
        }
    }
    
    @objc private func sendMessage() {
        if let message = chatTextView.text, !message.isEmpty {
            mqttManager.sendMessage(
                topic: topic,
                message: message
            )
            
            lock.withLock {
                messages.append(
                    ChatMessage(messageType: .outgoing, message: message)
                )
                updateDataSource(message: messages)
            }
            
            chatTextView.text = ""
        }
    }
}

private extension ChatViewController {
    func setupView() {
        title = "Chat"
        view.backgroundColor = .chatBackground
        
        chatTableView = UITableView(frame: .zero)
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        chatTableView.backgroundColor = .clear
        chatTableView.separatorStyle = .none
        chatTableView.estimatedRowHeight = 120
        chatTableView.rowHeight = UITableView.automaticDimension
        let tableViewInset = chatTableView.contentInset
        chatTableView.contentInset = .init(
            top: tableViewInset.top,
            left: tableViewInset.left,
            bottom: 10,
            right: tableViewInset.right
        )
        view.addSubview(chatTableView)

        let chatBottomControlContainer = UIView(frame: .zero)
        chatBottomControlContainer.translatesAutoresizingMaskIntoConstraints = false
        chatBottomControlContainer.backgroundColor = .systemBackground
        chatBottomControlContainer.layer.cornerRadius = 22.5
        chatBottomControlContainer.layer.masksToBounds = true
        view.addSubview(chatBottomControlContainer)
        
        var emojiButtonConfiguration = UIButton.Configuration.plain()
        emojiButtonConfiguration.image = UIImage(named: "emoji")
        let emojiButton = UIButton(configuration: emojiButtonConfiguration)
        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        chatBottomControlContainer.addSubview(emojiButton)
        
        chatTextView = UITextView(frame: .zero)
        chatTextView.translatesAutoresizingMaskIntoConstraints = false
        chatTextView.font = .systemFont(ofSize: 15)
        chatTextView.autocapitalizationType = .none
        chatTextView.delegate = self
        chatBottomControlContainer.addSubview(chatTextView)
        
        chatTextViewPlaceholderLabel = UILabel(frame: .zero)
        chatTextViewPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        chatTextViewPlaceholderLabel.text = "Type your message here"
        chatTextViewPlaceholderLabel.textColor = .lightGray
        chatBottomControlContainer.addSubview(chatTextViewPlaceholderLabel)
        
        let attachmentButton = UIButton(frame: .zero)
        attachmentButton.translatesAutoresizingMaskIntoConstraints = false
        attachmentButton.setImage(.attachment, for: .normal)
        chatBottomControlContainer.addSubview(attachmentButton)
        
        let paymentButton = UIButton(frame: .zero)
        paymentButton.translatesAutoresizingMaskIntoConstraints = false
        paymentButton.setImage(.currency, for: .normal)
        chatBottomControlContainer.addSubview(paymentButton)
        
        let cameraButton = UIButton(frame: .zero)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setImage(.cameraFilled, for: .normal)
        chatBottomControlContainer.addSubview(cameraButton)
        
        var sendButtonConfiguration = UIButton.Configuration.plain()
        sendButtonConfiguration.image = UIImage(
            systemName: "paperplane.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30))
        )
        let sendButton = UIButton(configuration: sendButtonConfiguration)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            chatTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            chatTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            chatTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatTableView.bottomAnchor.constraint(equalTo: chatBottomControlContainer.topAnchor),
            
            chatBottomControlContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            chatBottomControlContainer.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -4),
            chatBottomControlContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            emojiButton.leadingAnchor.constraint(equalTo: chatBottomControlContainer.leadingAnchor, constant: 8),
            emojiButton.centerYAnchor.constraint(equalTo: chatBottomControlContainer.centerYAnchor),
            emojiButton.heightAnchor.constraint(equalToConstant: 35),
            emojiButton.widthAnchor.constraint(equalToConstant: 35),
            
            chatTextView.leadingAnchor.constraint(equalTo: emojiButton.trailingAnchor, constant: 4),
            chatTextView.topAnchor.constraint(equalTo: chatBottomControlContainer.topAnchor, constant: 5),
            chatTextView.bottomAnchor.constraint(equalTo: chatBottomControlContainer.bottomAnchor, constant: -5),
            chatTextView.heightAnchor.constraint(equalToConstant: 35),
            
            chatTextViewPlaceholderLabel.leadingAnchor.constraint(equalTo: emojiButton.trailingAnchor, constant: 4),
            chatTextViewPlaceholderLabel.trailingAnchor.constraint(equalTo: chatTextView.trailingAnchor),
            chatTextViewPlaceholderLabel.centerYAnchor.constraint(equalTo: chatBottomControlContainer.centerYAnchor),
            
            attachmentButton.leadingAnchor.constraint(equalTo: chatTextView.trailingAnchor, constant: 4),
            attachmentButton.centerYAnchor.constraint(equalTo: chatBottomControlContainer.centerYAnchor),
            attachmentButton.heightAnchor.constraint(equalToConstant: 35),
            attachmentButton.widthAnchor.constraint(equalToConstant: 35),
            
            paymentButton.leadingAnchor.constraint(equalTo: attachmentButton.trailingAnchor, constant: 4),
            paymentButton.centerYAnchor.constraint(equalTo: chatBottomControlContainer.centerYAnchor),
            paymentButton.heightAnchor.constraint(equalToConstant: 35),
            paymentButton.widthAnchor.constraint(equalToConstant: 35),
            
            cameraButton.leadingAnchor.constraint(equalTo: paymentButton.trailingAnchor, constant: 4),
            cameraButton.trailingAnchor.constraint(equalTo: chatBottomControlContainer.trailingAnchor, constant: -4),
            cameraButton.centerYAnchor.constraint(equalTo: chatBottomControlContainer.centerYAnchor),
            cameraButton.heightAnchor.constraint(equalToConstant: 35),
            cameraButton.widthAnchor.constraint(equalToConstant: 35),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            sendButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 45),
            sendButton.widthAnchor.constraint(equalToConstant: 45),
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

    func makeDataSource() -> UITableViewDiffableDataSource<ChatSection, ChatMessage> {
        UITableViewDiffableDataSource<ChatSection, ChatMessage>(tableView: chatTableView) { tableView, indexPath, itemIdentifier in
            switch itemIdentifier.messageType {
            case .incoming:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: IncomingMessageCell.cellIdentifier,
                    for: indexPath
                ) as! IncomingMessageCell
                cell.setupData(itemIdentifier.message)
                return cell
            case .outgoing:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: OutgoingMessageCell.cellIdentifier,
                    for: indexPath
                ) as! OutgoingMessageCell
                cell.setupData(itemIdentifier.message)
                return cell
            }
        }
    }

    func updateDataSource(message: [ChatMessage]) {
        var snapshot = NSDiffableDataSourceSnapshot<ChatSection, ChatMessage>()
        snapshot.appendSections(ChatSection.allCases)
        
        snapshot.appendItems(message, toSection: .all)
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        chatTextViewPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension ChatViewController: UITableViewDelegate {
}

#Preview {
    UINavigationController(rootViewController: ChatViewController(topic: ""))
}
