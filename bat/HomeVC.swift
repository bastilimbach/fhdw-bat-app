//
//  HomeVC.swift
//  bat
//
//  Created by Sebastian Limbach on 10.10.2017.
//  Copyright © 2017 Sebastian Limbach. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    let startBtn = StartTrackingButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"

        setupViews()
        setupConstraints()
    }

    func setupViews() {
        view.addSubview(startBtn)
        startBtn.addTarget(self, action: #selector(startTracking), for: .touchUpInside)
    }

    func setupConstraints() {
        startBtn.translatesAutoresizingMaskIntoConstraints = false
        startBtn.heightAnchor.constraint(equalToConstant: 100).isActive = true
        startBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        startBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    @objc func startTracking(sender: UIButton) {
        print("Clickerd")
    }

}

