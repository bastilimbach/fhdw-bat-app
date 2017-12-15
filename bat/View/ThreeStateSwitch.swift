//
//  ThreeStateSwitch.swift
//  bat
//
//  Created by Sebastian Limbach on 31.10.2017.
//  Copyright © 2017 Sebastian Limbach. All rights reserved.
//

import UIKit

final class ThreeStateSwitch: UIControl {

    enum SliderPosition {
        case left(icon: UIImage?)
        case middle
        case right(icon: UIImage?)
    }

    var leftStateIcon: UIImage? {
        didSet {
            leftStateImageView.image = leftStateIcon
        }
    }

    var rightStateIcon: UIImage? {
        didSet {
            rightStateImageView.image = rightStateIcon
        }
    }

    private(set) var currentState: SliderPosition = .middle
    private let sliderWidth: CGFloat = 100

    private lazy var leftStateImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var rightStateImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var backgroundView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .fhdwOrange
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()

    private lazy var sliderView: UIImageView = {
        let view = UIImageView()
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panDetected(sender:)))
        view.isUserInteractionEnabled = true
        view.contentMode = .center
        view.tintColor = .white
        view.backgroundColor = .fhdwBlue
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addGestureRecognizer(panGestureRecognizer)
        return view
    }()

    private var sliderViewXConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds

        let imagePadding: CGFloat = 30

        switch currentState {
        case .left:
            sliderViewXConstraint = sliderView.centerXAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: sliderWidth / 2)
        case .middle:
            sliderViewXConstraint = sliderView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor)
        case .right:
            sliderViewXConstraint = sliderView.centerXAnchor.constraint(equalTo: backgroundView.rightAnchor)
        }

        NSLayoutConstraint.activate([
            sliderViewXConstraint!,
            sliderView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            sliderView.widthAnchor.constraint(equalToConstant: sliderWidth),
            sliderView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor, multiplier: 1),

            leftStateImageView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor, constant: imagePadding),
            leftStateImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            leftStateImageView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor, multiplier: 1),
            leftStateImageView.widthAnchor.constraint(lessThanOrEqualToConstant: sliderWidth - imagePadding),

            rightStateImageView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor, constant: -imagePadding),
            rightStateImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            rightStateImageView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor, multiplier: 1),
            rightStateImageView.widthAnchor.constraint(lessThanOrEqualToConstant: sliderWidth - imagePadding)
        ])
    }

    private func setupViews() {
        addSubview(backgroundView)
        backgroundView.addSubview(sliderView)
        backgroundView.bringSubview(toFront: sliderView)
        backgroundView.addSubview(leftStateImageView)
        backgroundView.sendSubview(toBack: leftStateImageView)
        backgroundView.addSubview(rightStateImageView)
        backgroundView.sendSubview(toBack: rightStateImageView)
    }

    @objc private func panDetected(sender: UIPanGestureRecognizer) {
        let background = backgroundView
        guard let slider = sender.view as? UIImageView else { return }
        var translatedPoint = sender.translation(in: background)
        translatedPoint = CGPoint(x: translatedPoint.x, y: frame.size.height / 2)

        slider.center.x = slider.center.x + translatedPoint.x
        sender.setTranslation(.zero, in: background)

        if sender.state == .ended {
            let velocityX = sender.velocity(in: background).x * 0.2
            var finalX = slider.center.x + velocityX
            let origionalState = currentState

            switch finalX {
            case _ where finalX <= background.frame.width / 3:
                currentState = .left(icon: leftStateIcon)
                finalX = background.frame.minX + slider.frame.width / 2
            case _ where finalX >= (background.frame.width / 3) * 2:
                currentState = .right(icon: rightStateIcon)
                finalX = background.frame.maxX - slider.frame.width / 2
            default: // (80)..<(160)
                currentState = .middle
                finalX = background.frame.width / 2
            }

            let animationDuration: Double = abs(Double(velocityX) * 0.0002) + 0.2

            UIView.animate(withDuration: animationDuration, delay: 0, options: [.allowUserInteraction], animations: {
                slider.center.x = finalX
            }, completion: { finished in
                if finished {
                    switch self.currentState {
                    case .left(let icon):
                        self.sliderView.image = icon
                    case .right(let icon):
                        self.sliderView.image = icon
                    case .middle:
                        self.sliderView.image = nil
                    }
                    UISelectionFeedbackGenerator().selectionChanged()
                    self.sendActions(for: .valueChanged)
                }
            })

        }
    }

    func reset() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.sliderView.image = nil
            self.sliderView.center.x = self.backgroundView.frame.width / 2
        }, completion: { finished in
            if finished {
                self.currentState = .middle
                UISelectionFeedbackGenerator().selectionChanged()
                self.sendActions(for: .valueChanged)
            }
        })
    }

}
