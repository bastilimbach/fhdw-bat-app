//
//  User.swift
//  bat
//
//  Created by Sebastian Limbach on 10.10.2017.
//  Copyright © 2017 Sebastian Limbach. All rights reserved.
//

import Foundation
import Locksmith

struct User {
    let username: String
    let token: String

    func makeCurrentUser() throws {
        try Locksmith.updateData(data: ["username": self.username, "token": self.token], forUserAccount: "api-user")
    }
}
