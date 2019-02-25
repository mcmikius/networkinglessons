//
//  Course.swift
//  Networking
//
//  Created by Michail Bondarenko on 2/25/19.
//  Copyright © 2019 Michail Bondarenko. All rights reserved.
//

import Foundation

struct Course: Decodable {
    let id: Int?
    let name: String?
    let link: String?
    let imageUrl: String?
    let numberOfLessons: Int?
    let numberOfTests: Int?
}
