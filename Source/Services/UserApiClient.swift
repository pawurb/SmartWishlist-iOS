//
//  ApiClient.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 03/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Foundation
import Moya
import Require
import RxSwift

enum UserApi: CommonApi {
    case create(
        authToken: String,
        deviceToken: String,
        sandbox: Bool,
        storeCountry: String,
        timezone: String
    )

    case update(
        authToken: String,
        deviceToken: String,
        devicePushToken: String
    )
}

extension UserApi: TargetType {
    var path: String {
        return "/users"
    }

    var method: Moya.Method {
        switch self {
        case .create:
            return .post
        case .update:
            return .put
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .create(let authToken, let deviceToken, let sandbox, let storeCountry, let timezone):
            return [
                "auth_token": authToken,
                "device_token": deviceToken,
                "sandbox": sandbox,
                "store_country": storeCountry,
                "timezone": timezone
            ]
        case .update(let authToken, let deviceToken, let devicePushToken):
            return [
                "auth_token": authToken,
                "device_token": deviceToken,
                "device_push_token": devicePushToken
            ]
        }
    }

    var parameterEncoding: ParameterEncoding {
        switch self {
        case .create:
            return JSONEncoding.default
        case .update:
            return URLEncoding.default
        }
    }

    var sampleData: Data {
        switch self {
        case .create:
            return "{\"status\": \"created\"}".utf8Encoded
        case .update:
            return "{\"status\": \"updated\"}".utf8Encoded
        }
    }
}

class UserApiClient: RxMoyaProvider<UserApi> {
    
    func jsonRequest(_ endpoint: UserApi) -> RxSwift.Observable<Any> {
        return request(endpoint).mapJSON(failsOnEmptyData: true)
    }

    func register(user: User) -> RxSwift.Observable<Any> {
        return jsonRequest(
            .create(
                authToken: user.authToken,
                deviceToken: user.deviceToken,
                sandbox: user.sandbox,
                storeCountry: user.storeCountry,
                timezone: user.timezone
            )
        )
    }
}
