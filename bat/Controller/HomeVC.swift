//
//  HomeVC.swift
//  bat
//
//  Created by Sebastian Limbach on 10.10.2017.
//  Copyright © 2017 Sebastian Limbach. All rights reserved.
//

import UIKit
import CoreLocation
import Locksmith

final class HomeVC: UIViewController {

    private let locationManager = LocationManager.shared
    private var isTracking = false

    private lazy var locationSwitch: ThreeStateSwitch = {
        let threeStateSwitch = ThreeStateSwitch()
        threeStateSwitch.leftStateIcon = UIImage(named: "currentLocationIcon")
        threeStateSwitch.rightStateIcon = UIImage(named: "destinationIcon")
        threeStateSwitch.addTarget(self, action: #selector(locationSliderMoved(sender:)), for: .valueChanged)
        threeStateSwitch.translatesAutoresizingMaskIntoConstraints = false
        return threeStateSwitch
    }()

    private lazy var logoView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "fhdwLogo")!.resizeImage(withNewHeight: 100)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var messageButton1: UIButton = {
        let btn = UIButton()
        btn.setTitle("Button 1", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.fhdwOrange, for: .highlighted)
        btn.backgroundColor = .fhdwLightBlue
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tag = 1
        btn.addTarget(self, action: #selector(quickStartButtonPressed(sender:)), for: .touchUpInside)
        return btn
    }()

    private lazy var messageButton2: UIButton = {
        let btn = UIButton()
        btn.setTitle("Button 2", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.fhdwOrange, for: .highlighted)
        btn.backgroundColor = .fhdwLightBlue
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tag = 2
        btn.addTarget(self, action: #selector(quickStartButtonPressed(sender:)), for: .touchUpInside)
        return btn
    }()

    private lazy var messageButtons: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(messageButton1)
        stackView.addArrangedSubview(messageButton2)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let destinations = [
        Destination(id: 1, name: "FHDW Paderborn"),
        Destination(id: 2, name: "FHDW Bergisch Gladbach"),
        Destination(id: 3, name: "FHDW Bielefeld"),
        Destination(id: 4, name: "FHDW Marburg"),
        Destination(id: 5, name: "FHDW Mettmann")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Boss Arrival Time"
        view.backgroundColor = .white
        locationManager.delegate = self
//        locationManager.distanceFilter = 100

//        let settingsBtn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(settingsBtnPressed))
        let settingsBtn = UIBarButtonItem(image: UIImage(named: "settingsIcon"), style: .plain, target: self, action: #selector(settingsBtnPressed))
        navigationItem.rightBarButtonItems = [settingsBtn]

        setupViews()
        setupConstraints()
        applyButtonNames()
    }

    private func applyButtonNames() {
        if let buttonSettings = UserDefaults.standard.object(forKey: "quickMessageButton1") as? [String:String] {
            if let title = buttonSettings["Title"] {
                messageButton1.setTitle(title, for: .normal)
            }
        }

        if let buttonSettings = UserDefaults.standard.object(forKey: "quickMessageButton2") as? [String:String] {
            if let title = buttonSettings["Title"] {
                messageButton2.setTitle(title, for: .normal)
            }
        }
    }

    private func setupViews() {
        view.addSubview(locationSwitch)
        view.addSubview(messageButtons)
        view.addSubview(logoView)
    }

    private func setupConstraints() {
        let margins = view.layoutMarginsGuide
        let padding: CGFloat = 20

        NSLayoutConstraint.activate([
            // Switch
            locationSwitch.leftAnchor.constraint(equalTo: margins.leftAnchor),
            locationSwitch.rightAnchor.constraint(equalTo: margins.rightAnchor),
            locationSwitch.heightAnchor.constraint(equalToConstant: 100),

            // Quickstart buttons
            messageButtons.topAnchor.constraint(equalTo: locationSwitch.bottomAnchor, constant: padding),
            messageButtons.leftAnchor.constraint(equalTo: locationSwitch.leftAnchor),
            messageButtons.rightAnchor.constraint(equalTo: locationSwitch.rightAnchor),
            messageButtons.heightAnchor.constraint(equalTo: locationSwitch.heightAnchor, multiplier: 0.5),

            // Logo
            logoView.topAnchor.constraint(lessThanOrEqualTo: messageButtons.bottomAnchor, constant: padding),
            logoView.leftAnchor.constraint(equalTo: view.leftAnchor),
            logoView.rightAnchor.constraint(equalTo: view.rightAnchor),
            logoView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            logoView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
    }

    @objc private func locationSliderMoved(sender: ThreeStateSwitch) {
        switch sender.currentState {
        case .left:
            NetworkManager.shared.update(destination: nil, completion: { (result) in
                switch result {
                case .success:
                    self.locationManager.startUpdatingLocation()
                case let .error(err):
                    print(err.localizedDescription)
                case .unauthorized:
                    DispatchQueue.main.async {
                        self.logoutUser()
                    }
                default:
                    return
                }
            })
        case .middle:
            locationManager.stopUpdatingLocation()
        case .right:
            presentDestinationChooser { action in
                guard let actionTitle = action.title, actionTitle != "Cancel" else {
                    self.locationSwitch.reset()
                    return
                }

                for destination in self.destinations where destination.name == actionTitle {
                    NetworkManager.shared.update(destination: destination, completion: { (result) in
                        switch result {
                        case .success:
                            self.locationManager.startUpdatingLocation()
                        case let .error(err):
                            print(err.localizedDescription)
                        case .unauthorized:
                            DispatchQueue.main.async {
                                self.logoutUser()
                            }
                        default:
                            return
                        }
                    })
                }
            }
        }
    }

    private func presentDestinationChooser(completion: @escaping (_ action: UIAlertAction) ->()) {
        let alertController = UIAlertController(title: nil, message: "Choose your destination", preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            completion(action)
        }
        alertController.addAction(cancelAction)

        for destination in destinations {
            let destinationBtn = UIAlertAction(title: destination.name, style: .default) { action in
                completion(action)
            }
            alertController.addAction(destinationBtn)
        }

        present(alertController, animated: true)
    }

    @objc private func quickStartButtonPressed(sender: UIButton) {
        NetworkManager.shared.sendMessage(ofButton: "quickMessageButton\(sender.tag)") { result in
            switch result {
            case let .success(data):
                print(String(data: data, encoding: String.Encoding.utf8)!)
            case let .error(err):
                print(err.localizedDescription)
            case .unauthorized:
                DispatchQueue.main.async {
                    self.logoutUser()
                }
            default:
                return
            }
        }
    }

    @objc private func settingsBtnPressed(_ sender: UIBarButtonItem) {
        present(NavigationController(rootViewController: SettingsVC(style: .grouped)), animated: true)
    }

    private func logoutUser() {
        locationManager.stopUpdatingLocation()
        guard let _ =  try? Locksmith.deleteDataForUserAccount(userAccount: "api-user") else { return }
        present(LoginVC(), animated: true)
    }

}

extension HomeVC: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
//            let howRecent = newLocation.timestamp.timeIntervalSinceNow
//            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            let coordinates = newLocation.coordinate
            print("Current latitude: \(coordinates.latitude)")
            print("Current longitude: \(coordinates.longitude)")
            print("---")

            NetworkManager.shared.update(location: (Double(coordinates.latitude), Double(coordinates.longitude)), completion: { result in
                switch result {
                case let .success(data):
                    print(String(data: data, encoding: String.Encoding.utf8)!)
                case let .error(err):
                    print(err.localizedDescription)
                case .unauthorized:
                    DispatchQueue.main.async {
                        self.logoutUser()
                    }
                default:
                    return
                }
            })


        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .notDetermined, .restricted:
            let alertController = UIAlertController(title: "😥", message: "Location services were not authorized. Please enable them in Settings to continue.", preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "Settings", style: .cancel) { (alertAction) in
                if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(settingsAction)

            present(alertController, animated: true, completion: nil)
        default:
            return
        }
    }

}

