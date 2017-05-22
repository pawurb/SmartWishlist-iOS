//
//  ProductsListVC_spec.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 04/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Moya
import Nimble
@testable import PriceWatcher
import Quick
import Require
import RxSwift

class ProductsListVCSpec: QuickSpec {
    override func spec() {
        describe("ProductsListVC") {
            beforeEach {
                User.keychain.allKeys().forEach { key in
                    try! User.keychain.remove(key)
                }
            }

            var controller: ProductsListVC!
            var productsApiClient: ProductsApiClient!
            var userApiClient: UserApiClient!
            beforeEach {
                productsApiClient = ProductsApiClient(stubClosure: MoyaProvider.immediatelyStub)
                userApiClient = UserApiClient(stubClosure: MoyaProvider.immediatelyStub)
                controller = ProductsListVC(
                    productsApiClient: productsApiClient,
                    userApiClient: userApiClient
                )
            }

            afterEach {
                controller = nil
            }

            describe("refreshProductData") {
                beforeEach {
                    let _ = User.persist(user: User())
                }

                it("populates the products variable with Product instances") {
                    controller.refreshProductsData(showSpinner: true)
                    expect(controller.discountedProducts).toEventuallyNot(beEmpty())
                    expect(controller.standardPriceProducts).toEventuallyNot(beEmpty())
                }
            }

            describe("registerUser") {
                it("it persists user after successful api call") {
                    expect(User.current()).to(beNil())
                    controller.registerUser()
                    expect(User.current()).toEventuallyNot(beNil())
                }
            }
        }
    }
}
