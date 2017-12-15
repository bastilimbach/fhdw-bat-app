//
//  ArtefactsImage.swift
//  bat
//
//  Created by Sebastian Limbach on 02.12.2017.
//  Copyright © 2017 Sebastian Limbach. All rights reserved.
//

import UIKit

class ArtefactsImage: UIView {

    private let artefactBox1: UIView = {
        let view = UIView()
        view.backgroundColor = .fhdwOrange
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let artefactBox2: UIView = {
        let view = UIView()
        view.backgroundColor = .fhdwOrange
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .fhdwLightGray
        clipsToBounds = true
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        NSLayoutConstraint.activate([
            artefactBox1.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            artefactBox1.leftAnchor.constraint(equalTo: self.leftAnchor),
            artefactBox1.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
            artefactBox1.heightAnchor.constraint(equalToConstant: 40),

            artefactBox2.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            artefactBox2.rightAnchor.constraint(equalTo: self.rightAnchor),
            artefactBox2.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6),
            artefactBox2.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    func setupViews() {
        addSubview(artefactBox1)
        addSubview(artefactBox2)
    }

}
