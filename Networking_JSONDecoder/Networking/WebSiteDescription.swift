//
//  WebSiteDescription.swift
//  Networking
//
//  Created by Michail Bondarenko on 2/25/19.
//  Copyright © 2019 Michail Bondarenko. All rights reserved.
//

import Foundation

struct WebSiteDescription: Decodable {
    let websiteDescription: String?
    let websiteName: String?
    let courses: [Course]
}
