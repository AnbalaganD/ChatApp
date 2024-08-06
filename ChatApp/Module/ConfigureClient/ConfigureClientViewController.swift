//
//  ConfigureClientViewController.swift
//  ChatApp
//
//  Created by Admin on 26/03/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ConfigureClientViewController: UIViewController {
    
    private let mqttManager = MQTTManager.shared
    
    private lazy var hostTextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Ex: 172.0.0.1"
        return textField
    }()
    
    private lazy var portTextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Ex: 1883"
        return textField
    }()
    
    private lazy var topicTextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "topic/sample"
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        title = "Configuration"
        view.backgroundColor = .systemBackground
        
        let hostLabel = UILabel(frame: .zero)
        hostLabel.translatesAutoresizingMaskIntoConstraints = false
        hostLabel.text = "Host Address:"
        hostLabel.font = .boldSystemFont(ofSize: 15)
        view.addSubview(hostLabel)
        
        view.addSubview(hostTextField)
        
        let portLabel = UILabel(frame: .zero)
        portLabel.translatesAutoresizingMaskIntoConstraints = false
        portLabel.font = .boldSystemFont(ofSize: 15)
        portLabel.text = "Port:"
        view.addSubview(portLabel)
        
        view.addSubview(portTextField)
        
        let topicLabel = UILabel(frame: .zero)
        topicLabel.translatesAutoresizingMaskIntoConstraints = false
        topicLabel.font = .boldSystemFont(ofSize: 15)
        topicLabel.text = "Topic:"
        view.addSubview(topicLabel)
        
        view.addSubview(topicTextField)

        let finishConfigurationButton = UIButton(configuration: .filled(), primaryAction: nil)
        finishConfigurationButton.translatesAutoresizingMaskIntoConstraints = false
        finishConfigurationButton.setTitle("Finish Configuration", for: .normal)
        finishConfigurationButton.addTarget(self, action: #selector(configureMQTTManager), for: .touchUpInside)
        view.addSubview(finishConfigurationButton)
        
        NSLayoutConstraint.activate([
            hostLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hostLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            hostTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hostTextField.trailingAnchor.constraint(equalTo: portTextField.leadingAnchor, constant: -16),
            hostTextField.topAnchor.constraint(equalTo: hostLabel.bottomAnchor),
            hostTextField.heightAnchor.constraint(equalToConstant: 40),
            
            portLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            portLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            portLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            
            portTextField.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 60),
            portTextField.topAnchor.constraint(equalTo: portLabel.bottomAnchor),
            portTextField.heightAnchor.constraint(equalToConstant: 40),
            
            topicLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topicLabel.topAnchor.constraint(equalTo: hostTextField.bottomAnchor, constant: 15),
            
            topicTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topicTextField.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            topicTextField.topAnchor.constraint(equalTo: topicLabel.bottomAnchor),
            topicTextField.heightAnchor.constraint(equalToConstant: 40),
            
            finishConfigurationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            finishConfigurationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            finishConfigurationButton.topAnchor.constraint(equalTo: topicTextField.bottomAnchor, constant: 30),
            finishConfigurationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
#if DEBUG
        hostTextField.text = "192.168.31.2"
        portTextField.text = "1883"
        topicTextField.text = "topic/state"
#endif
    }
    
    @objc private func configureMQTTManager() {
        mqttManager.configure(
            host: hostTextField.text!,
            port: Int(portTextField.text!)!,
            topic: topicTextField.text!
        )
        
        navigationController?.pushViewController(
            ChatViewController(topic: "topic/state"),
            animated: true
        )
    }
}

#Preview {
    UINavigationController(rootViewController: ConfigureClientViewController())
}
