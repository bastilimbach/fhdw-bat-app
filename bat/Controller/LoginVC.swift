//
//  LoginVC.swift
//  bat
//
//  Created by Sebastian Limbach on 25.10.2017.
//  Copyright © 2017 Sebastian Limbach. All rights reserved.
//

import UIKit

final class LoginVC: UIViewController {

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.sizeToFit()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var logoView: UIView = {
        let logoView = UIView()
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = logoView.frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        logoView.addSubview(blurEffectView)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        return logoView
    }()

    private lazy var usernameInput: UITextField = {
        let input = UITextField()
        input.placeholder = "Username"
        input.keyboardAppearance = .dark
        input.returnKeyType = .next
        input.autocorrectionType = .no
        input.autocapitalizationType = .none
        input.layer.cornerRadius = 4.0
        input.backgroundColor = .white
        input.layer.shadowOpacity = 0.4
        input.layer.shadowOffset = CGSize(width: 0, height: 0)
        input.translatesAutoresizingMaskIntoConstraints = false
        input.tag = 1
        input.delegate = self
        return input
    }()

    private lazy var tokenInput: UITextField = {
        let input = UITextField()
        input.placeholder = "Token"
        input.keyboardAppearance = .dark
        input.returnKeyType = .go
        input.autocorrectionType = .no
        input.autocapitalizationType = .none
        input.isSecureTextEntry = true
        input.layer.cornerRadius = 4.0
        input.backgroundColor = .white
        input.layer.shadowOpacity = 0.4
        input.layer.shadowOffset = .zero
        input.translatesAutoresizingMaskIntoConstraints = false
        input.tag = 2
        input.delegate = self
        return input
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4.0
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = .zero
        button.backgroundColor = .fhdwOrange
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView  = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "loginBG")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupObservers()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func setupViews() {
        view.addSubview(backgroundImageView)
        view.sendSubview(toBack: backgroundImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(logoView)
        contentView.addSubview(usernameInput)
        contentView.addSubview(tokenInput)
        contentView.addSubview(loginButton)
    }

    private func setupConstraints() {
//        let margins = view.layoutMarginsGuide
        let padding: CGFloat = 20
        let inputHeight: CGFloat = 50

        // Username input
        NSLayoutConstraint.activate([
            // Background image
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Scrollview
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),

            // Logo view
            logoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            logoView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            logoView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            logoView.heightAnchor.constraint(equalToConstant: 200),

            // Username input
            usernameInput.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: padding * 2),
//            usernameInput.leftAnchor.constraint(equalTo: contentView.leftAnchor),
//            usernameInput.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            usernameInput.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            usernameInput.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            usernameInput.heightAnchor.constraint(equalToConstant: inputHeight),

            // Token input
            tokenInput.topAnchor.constraint(equalTo: usernameInput.bottomAnchor, constant: padding),
            tokenInput.leftAnchor.constraint(equalTo: usernameInput.leftAnchor),
            tokenInput.rightAnchor.constraint(equalTo: usernameInput.rightAnchor),
            tokenInput.heightAnchor.constraint(equalTo: usernameInput.heightAnchor, multiplier: 1),


            // Login button
            loginButton.topAnchor.constraint(equalTo: tokenInput.bottomAnchor, constant: padding),
            loginButton.leftAnchor.constraint(equalTo: usernameInput.leftAnchor),
            loginButton.rightAnchor.constraint(equalTo: usernameInput.rightAnchor),
            loginButton.heightAnchor.constraint(equalTo: tokenInput.heightAnchor, multiplier: 1.3),
            loginButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc private func loginButtonPressed(_ sender: UIButton? = nil) {
        print("Login pressed")
        guard let username = usernameInput.text, let token = tokenInput.text else { return }

        let newUser = User(username: username, token: token)
        NetworkManager.shared.authenticate(user: newUser, completion: { (result) in
            if result == .authorized {
                print("Right credentials!")
                try! newUser.makeCurrentUser()
                DispatchQueue.main.async {
                    self.present(NavigationController(rootViewController: HomeVC()), animated: true, completion: nil)
                }
            } else {
                print("Wrong credentials!")
            }
        })
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            var newContentInset = scrollView.contentInset
            newContentInset.bottom = keyboardHeight
            scrollView.contentInset = newContentInset
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textField.tag)
        switch textField.tag {
        case 1:
            textField.resignFirstResponder()
            tokenInput.becomeFirstResponder()
        case 2:
            textField.resignFirstResponder()
            loginButtonPressed()
        default:
            fatalError("No UITextField with id: \(textField.tag)")
        }
        return true
    }
}
