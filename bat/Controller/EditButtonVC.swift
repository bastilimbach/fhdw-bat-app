//
//  EditButtonVC.swift
//  bat
//
//  Created by Sebastian Limbach on 07.11.2017.
//  Copyright © 2017 Sebastian Limbach. All rights reserved.
//

import UIKit

final class EditButtonVC: UITableViewController {

    var buttonID: Int?

    private let buttonTitleCell = UITableViewCell()
    private let buttonMessageCell = UITableViewCell()
    private var buttonTitleTextField: UITextField?
    private var buttonMessageTextView: UITextView?


    private var tableViewCells: [[UITableViewCell]] = [[]]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit buttons"

        buttonTitleTextField = UITextField()
        buttonTitleTextField?.delegate = self
        buttonTitleTextField?.clearButtonMode = .always
        buttonTitleTextField?.translatesAutoresizingMaskIntoConstraints = false

        buttonMessageTextView = UITextView()
        buttonMessageTextView?.font = .systemFont(ofSize: 18)
        buttonMessageTextView?.delegate = self
        buttonMessageTextView?.translatesAutoresizingMaskIntoConstraints = false

        buttonTitleCell.addSubview(buttonTitleTextField!)
        buttonMessageCell.addSubview(buttonMessageTextView!)

        if let btnID = buttonID, let buttonSettings = UserDefaults.standard.object(forKey: "quickMessageButton\(btnID)") as? [String:String] {
            if let title = buttonSettings["Title"] {
                buttonTitleTextField?.text = title
            }
            if let message = buttonSettings["Message"] {
                buttonMessageTextView?.text = message
            }
        }

        tableViewCells = [[buttonTitleCell], [buttonMessageCell]]
        setupConstraint()
    }

    private func setupConstraint() {
        guard let buttonTitleTextField = buttonTitleTextField,
            let buttonMessageTextView = buttonMessageTextView else { return }

        NSLayoutConstraint.activate([
            buttonTitleTextField.topAnchor.constraint(equalTo: buttonTitleCell.topAnchor),
            buttonTitleTextField.leftAnchor.constraint(equalTo: buttonTitleCell.leftAnchor, constant: 15),
            buttonTitleTextField.rightAnchor.constraint(equalTo: buttonTitleCell.rightAnchor),
            buttonTitleTextField.bottomAnchor.constraint(equalTo: buttonTitleCell.bottomAnchor),
            buttonTitleTextField.heightAnchor.constraint(equalToConstant: 40),

            buttonMessageTextView.topAnchor.constraint(equalTo: buttonMessageCell.topAnchor),
            buttonMessageTextView.leftAnchor.constraint(equalTo: buttonMessageCell.leftAnchor, constant: 15),
            buttonMessageTextView.rightAnchor.constraint(equalTo: buttonMessageCell.rightAnchor),
            buttonMessageTextView.bottomAnchor.constraint(equalTo: buttonMessageCell.bottomAnchor),
            buttonMessageTextView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    override func numberOfSections(in tableView: UITableView) -> Int { return tableViewCells.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableViewCells[section].count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { return tableViewCells[indexPath.section][indexPath.row] }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Title"
        case 1:
            return "Message"
        default:
            fatalError("Section unknown: \(section)")
        }
    }

}

extension EditButtonVC: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) { saveButtonSettings() }

    func textViewDidEndEditing(_ textView: UITextView) { saveButtonSettings() }

    private func saveButtonSettings() {
        guard let btnID = buttonID else { return }
        UserDefaults.standard.set(["Title": buttonTitleTextField!.text, "Message": buttonMessageTextView!.text], forKey: "quickMessageButton\(btnID)")

    }
}

