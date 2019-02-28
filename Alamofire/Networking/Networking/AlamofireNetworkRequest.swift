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
    static func sendRequest(url: String, completion: @escaping (_ courses: [Course])->()) {
        guard let url = URL(string: url) else { return }
        request(url, method: .get).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                var courses = [Course]()
                courses = Course.getArray(from: value)!
                completion(courses)
            case .failure(let error):
                print(error)
            }
            
//            guard let statusCode = response.response?.statusCode else { return }
//            print("statusCode: ", statusCode)
//
//            if (200..<300).contains(statusCode) {
//                let value = response.result.value
//                print("value: ", value ?? "nil")
//            } else {
//                let error = response.result.error
//                print(error ?? "error")
//            }
        }
    }
}
