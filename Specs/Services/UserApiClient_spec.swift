//
//  UserApiClient_spec.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 03/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//
// swiftlint:disable function_body_length

import Foundation
import Moya
import Nimble
@testable import PriceWatcher
import Quick
import Require
import RxSwift

class UserApiClientSpec: QuickSpec {
    override func spec() {
        describe("UserApiClient") {
            var apiClient: UserApiClient!
            var request: UserApi!

            describe("create") {
                beforeEach {
                    request = .create(
                        authToken: "auth_token", deviceToken: "device_token",
                        sandbox: true, storeCountry: "US",
                        timezone: "Europe/Berlin"
                    )
                }

                context("request was successful") {
                    beforeEach {
                        apiClient = UserApiClient(stubClosure: MoyaProvider.immediatelyStub)
                    }

                    it("returns the correct api json response") {
                        var jsonResponse: [String: Any]? = nil

                        _ = apiClient.jsonRequest(request).subscribe { event in
                            switch event {
                            case let .next(data):
                               jsonResponse = (data as? [String : Any]).require(hint: "JSON parsing failed")
                            case let .error(error):
                                fatalError(error.localizedDescription)
                            default:
                                break
                            }
                        }

                        expect(jsonResponse?["status"] as? String).toEventually(equal("created"))
                    }
                }
            }

            describe("update") {
                beforeEach {
                    request = .update(
                        authToken: "auth_token",
                        deviceToken: "device_token",
                        devicePushToken: "device_push_token"
                    )
                }

                context("request was successful") {
                    beforeEach {
                        apiClient = UserApiClient(stubClosure: MoyaProvider.immediatelyStub)
                    }

                    it("returns the correct api json response") {
                        var jsonResponse: [String: Any]? = nil

                        _ = apiClient.jsonRequest(request).subscribe { event in
                            switch event {
                            case let .next(data):
                               jsonResponse = (data as? [String : Any]).require(hint: "JSON parsing failed")
                            case let .error(error):
                                fatalError(error.localizedDescription)
                            default:
                                break
                            }
                        }

                        expect(jsonResponse?["status"] as? String).toEventually(equal("updated"))
                    }
                }
            }
        }
    }
}
