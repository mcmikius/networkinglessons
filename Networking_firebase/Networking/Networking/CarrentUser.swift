//
//  CarrentUser.swift
//  Networking
//
//  Created by Michail Bondarenko on 3/4/19.
//  Copyright © 2019 Michail Bondarenko. All rights reserved.
//

import Foundation

struct CurrentUser {
    let uid: String
    let name: String
    let email: String
    
    init?(uid: String, data: [String: Any]) {
        guard let name = data["name"] as? String, let email = data["email"] as? String else { return nil }
        self.uid = uid
        self.name = name
        self.email = email
        
    }
}
