//
//  api_related.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 04/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Foundation
import Moya

protocol CommonApi {}

extension CommonApi {
    var baseURL: URL { return URL(string: apiUrl()).require(hint: "Invalid API_URL string") }
    
    var task: Task {
        return .request
    }
}

extension String {
    var utf8Encoded: Data {
        return self.data(using: .utf8).require(hint: "Invalid utf8 data")
    }
}
