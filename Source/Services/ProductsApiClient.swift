//
//  ProductsApiClient.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 04/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Foundation
import Moya
import Require
import RxSwift

enum ProductsApi: CommonApi {
    case index(
        authToken: String,
        deviceToken: String
    )

    case promotions

    case create(
        authToken: String,
        deviceToken: String,
        storeId: String
    )

    case destroy(
        authToken: String,
        deviceToken: String,
        storeId: String
    )
}

extension ProductsApi: TargetType {
    var path: String {
        switch self {
        case .index, .create, .destroy:
            return "/products"
        case .promotions:
            return "/promotions"
        }
    }

    var method: Moya.Method {
        switch self {
        case .index:
            return .get
        case .promotions:
            return .get
        case .create:
            return .post
        case .destroy:
            return .delete
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .index(let authToken, let deviceToken):
            return [
                "auth_token": authToken,
                "device_token": deviceToken
            ]
        case .promotions:
            return nil
        case .create(let authToken, let deviceToken, let storeId):
            return [
                "auth_token": authToken,
                "device_token": deviceToken,
                "store_id": storeId
            ]
        case .destroy(let authToken, let deviceToken, let storeId):
            return [
                "auth_token": authToken,
                "device_token": deviceToken,
                "store_id": storeId
            ]
        }
    }

    var parameterEncoding: ParameterEncoding {
        switch self {
        case .index:
            return URLEncoding.default
        case .promotions:
            return URLEncoding.default
        case .create:
            return JSONEncoding.default
        case .destroy:
            return URLEncoding.default
        }
    }

    var sampleData: Data {
        switch self {
        case .index:
            guard let path = Bundle.main.url(forResource: "products", withExtension: "json"),
                let data = try? Data(contentsOf: path) else {
                return Data()
            }

            return data
        case .promotions:
            guard let path = Bundle.main.url(forResource: "products", withExtension: "json"),
                let data = try? Data(contentsOf: path) else {
                    return Data()
            }

            return data
        case .create:
            return "{\"status\": \"created\"}".utf8Encoded
        case .destroy:
            return "{\"status\": \"removed\"}".utf8Encoded
        }
    }
}

class ProductsApiClient: RxMoyaProvider<ProductsApi> {
    func jsonRequest(_ endpoint: ProductsApi) -> RxSwift.Observable<Any> {
        return request(endpoint).mapJSON(failsOnEmptyData: true)
    }
}
