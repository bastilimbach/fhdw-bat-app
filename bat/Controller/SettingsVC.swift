//
//  SettingsVC.swift
//  bat
//
//  Created by Sebastian Limbach on 07.11.2017.
//  Copyright © 2017 Sebastian Limbach. All rights reserved.
//

import UIKit
import Locksmith

final class SettingsVC: UITableViewController {

    let quickMessageBtn1Option: UITableViewCell = {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Button 1"
        cell.accessoryType = .disclosureIndicator
        return cell
    }()

    let quickMessageBtn2Option: UITableViewCell = {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Button 2"
        cell.accessoryType = .disclosureIndicator
        return cell
    }()

    let logoutCell: UITableViewCell = {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Logout"
        cell.textLabel?.textColor = .red
        cell.textLabel?.textAlignment = .center
        cell.accessoryType = .none
        return cell
    }()

    var tableViewCells: [[UITableViewCell]] = [[]]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadButtonLabels()
        title = "Settings"

        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        navigationItem.rightBarButtonItems = [doneBtn]

        tableViewCells = [[quickMessageBtn1Option, quickMessageBtn2Option], [logoutCell]]
    }

    override func viewDidAppear(_ animated: Bool) {
        loadButtonLabels()
    }

    private func loadButtonLabels() {
        if let buttonSettings = UserDefaults.standard.object(forKey: "quickMessageButton1") as? [String:String] {
            if let title = buttonSettings["Title"] {
                quickMessageBtn1Option.textLabel?.text = title
            }
        }

        if let buttonSettings = UserDefaults.standard.object(forKey: "quickMessageButton2") as? [String:String] {
            if let title = buttonSettings["Title"] {
                quickMessageBtn2Option.textLabel?.text = title
            }
        }
    }

    @objc private func donePressed(_ sender: UIBarButtonItem) {
        present(NavigationController(rootViewController: HomeVC()), animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int { return tableViewCells.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return tableViewCells[section].count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { return tableViewCells[indexPath.section][indexPath.row] }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Quick message buttons"
        case 1:
            return nil
        default:
            fatalError("Section unknown: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // Edit buttons
            print("Edit button")
            let editButtonVC = EditButtonVC(style: .grouped)
            editButtonVC.buttonID = indexPath.row + 1
            navigationController?.pushViewController(editButtonVC, animated: true)
        case 1:
            // Logout
            guard let _ = try? Locksmith.deleteDataForUserAccount(userAccount: "api-user") else { return }
            present(LoginVC(), animated: true)
        default:
            fatalError("Row unknown: \(indexPath.row)")
        }
    }

}
