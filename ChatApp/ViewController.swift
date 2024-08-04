//
//  ViewController.swift
//  ChatApp
//
//  Created by Admin on 26/03/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        MQTTManager.shared.sendMessage(message: "Hello from iOS")
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
}
