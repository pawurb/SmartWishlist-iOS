//
//  ProductsApiClient_spec.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 04/06/2017.
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

class ProductsApiClientSpec: QuickSpec {
    override func spec() {
        describe("ProductsApiClient") {
            var apiClient: ProductsApiClient!
            var request: ProductsApi!

            describe("index") {
                beforeEach {
                    request = .index(
                        authToken: "auth_token",
                        deviceToken: "device_token"
                    )
                }

                context("request was successful") {
                    beforeEach {
                        apiClient = ProductsApiClient(stubClosure: MoyaProvider.immediatelyStub)
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

                        expect(jsonResponse?["products"] as? [AnyObject]).toNotEventually(beNil())
                    }
                }
            }

            describe("create") {
                beforeEach {
                    request = .create(
                        authToken: "auth_token",
                        deviceToken: "device_token",
                        storeId: "XYZ456"
                    )
                }

                context("request was successful") {
                    beforeEach {
                        apiClient = ProductsApiClient(stubClosure: MoyaProvider.immediatelyStub)
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
        }
    }
}
