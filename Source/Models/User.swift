//
//  User.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 03/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Foundation
import KeychainAccess
import Require
import Security

struct User {
    static let kUserAuthToken = "kUserAuthToken"
    static let kUserDeviceToken = "kUserDeviceToken"
    static let kUserProVersion = MyIAPHelper.proVersionIdentifier
    static var keychain: Keychain = {
        var namespace: String!
        let accessGroup = "K2TJ3T5LZE.net.pabloweb.pricewatcher"

        if isTestRunning() {
            namespace = "net.pabloweb.pricewatcher.userData-TEST"
//UNCOMMENT TO CLEAN DEBUG DEVICE KEYCHAIN DATA
//            namespace = "net.pabloweb.pricewatcher.userData-DEBUG"
        } else {
            switch configName() {
            case .debug:
                namespace = "net.pabloweb.pricewatcher.userData-DEBUG"
            case .staging:
                namespace = "net.pabloweb.pricewatcher.userData-STAGING"
            case .release:
                namespace = "net.pabloweb.pricewatcher.userData"
            }
        }

        return Keychain(service: namespace, accessGroup: accessGroup)
    }()

    let authToken: String
    let deviceToken: String
    let sandbox: Bool
    let storeCountry: String
    let timezone: String
    let isPro: Bool
}

extension User {
    static func randomToken() -> String {
        let bytesCount = 32
        var randomBytes = [UInt8](repeating: 0, count: bytesCount)

        _ = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
       return randomBytes.map({String(format: "%02hhx", $0)}).joined(separator: "")
    }

    static func deviceTokenValue() -> String {
        return UUID().uuidString
    }

    static func persist(user: User) -> Bool {
        print(user)
        do {
            try keychain.set(user.authToken, key: kUserAuthToken)
            try keychain.set(user.deviceToken, key: kUserDeviceToken)
            return true
        } catch let error {
            print("\(error.localizedDescription)")
            return false
        }
    }

    static func savedAuthToken() -> String? {
        return (try? keychain.get(kUserAuthToken)) as? String
    }

    static func savedDeviceToken() -> String? {
        return (try? keychain.get(kUserDeviceToken)) as? String
    }

    static func setHasProVersion() {
        do {
            try keychain.set("true", key: kUserProVersion)
        } catch let error {
            print("\(error.localizedDescription)")
        }
    }

    static func hasProVersion() -> Bool {
        return ((try? keychain.get(kUserProVersion)) as? String) != nil
    }

    static func current() -> User? {
        guard let authToken = savedAuthToken() else {
            return nil
        }

        guard let deviceToken = savedDeviceToken() else {
            return nil
        }

        return User(
            authToken: authToken,
            deviceToken: deviceToken,
            sandbox: isItSandbox(),
            storeCountry: Locale.current.regionCode!.uppercased(),
            timezone: TimeZone.current.identifier,
            isPro: User.hasProVersion()
        )
    }

    init() {
        self.init(
            authToken: User.randomToken(),
            deviceToken: User.deviceTokenValue(),
            sandbox: isItSandbox(),
            storeCountry: Locale.current.regionCode!.uppercased(),
            timezone: TimeZone.current.identifier,
            isPro: User.hasProVersion()
        )
    }
}
