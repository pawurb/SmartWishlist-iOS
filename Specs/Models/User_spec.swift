//
//  User_spec.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 03/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import KeychainAccess
import Nimble
@testable import PriceWatcher
import Quick
import Require
import Moya
import RxSwift

class UserSpec: QuickSpec {
    override func spec() {
        describe("User") {
            beforeEach {
                User.keychain.allKeys().forEach { key in
                    try! User.keychain.remove(key)
                }
            }

            describe("init") {
                var user: User!
                beforeEach {
                    user = User()
                }

                it("assigns the correct values") {
                    expect(user.authToken).notTo(beNil())
                    expect(user.deviceToken).notTo(beNil())
                    expect(user.sandbox).to(equal(true))
                    expect(user.storeCountry).to(equal("US"))
                    expect(user.timezone).to(equal("Europe/Warsaw"))
                }
            }

            describe("persist") {
                it("saves user tokens in the keychain") {
                    let user = User()
                    expect(User.savedAuthToken()).to(beNil())
                    expect(User.savedDeviceToken()).to(beNil())

                    let success = User.persist(user: user)
                    expect(success).to(equal(true))

                    expect(User.savedAuthToken()).toNot(beNil())
                    expect(User.savedDeviceToken()).toNot(beNil())
                }
            }

            describe("current") {
                context("user was not created yet") {
                    it("returns nil") {
                        expect(User.current()).to(beNil())
                    }
                }

                context("user was created and persisted before") {
                    it("returns a correct user instance") {
                        let user = User()
                        _ = User.persist(user: user)
                        expect(User.current()?.authToken).to(equal(user.authToken))
                    }
                }
            }

            describe("register") {
                it("executes the success case") {
                    var success = false
                    let user = User()
                    let apiClient = UserApiClient(stubClosure: MoyaProvider.immediatelyStub)
                    _ = apiClient.register(user: user).subscribe { event in
                        switch event {
                        case .next:
                            success = true
                        case let .error(error):
                            fatalError(error.localizedDescription)
                        default:
                            break
                        }
                    }

                    expect(success).toEventually(equal(true))
                }
            }

            describe("isPro") {
                context("user is pro") {
                    beforeEach {
                        MyIAPHelper.instance.deliverPurchaseNotificationFor(identifier: MyIAPHelper.proVersionIdentifier)
                    }

                    afterEach {
                        let defaults = UserDefaults.standard
                        defaults.removeObject(forKey: MyIAPHelper.proVersionIdentifier)
                    }

                    it("returns true") {
                        let user = User()
                        expect(user.isPro).to(equal(true))
                    }
                }
                
                context("user is not pro") {
                    it("returns false") {
                        let user = User()
                        expect(user.isPro).to(equal(false))
                    }
                }
            }
        }
    }
}
