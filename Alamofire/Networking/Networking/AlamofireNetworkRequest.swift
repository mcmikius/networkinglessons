//
//  AlamofireNetworkRequest.swift
//  Networking
//
//  Created by Michail Bondarenko on 2/27/19.
//  Copyright © 2019 Michail Bondarenko. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireNetworkRequest {
    static func sendRequest(url: String) {
        guard let url = URL(string: url) else { return }
        request(url, method: .get).responseJSON { (response) in
            print(response)
        }
    }
    
}
