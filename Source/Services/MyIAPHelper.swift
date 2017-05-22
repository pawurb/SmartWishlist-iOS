//
//  MyIAPHelper.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 25/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Foundation

class MyIAPHelper: IAPHelper {
    static var instance: MyIAPHelper = {
        let identifiers: Set = [proVersionIdentifier]
        return MyIAPHelper(productIds: identifiers)
    }()

    static let proVersionIdentifier = "net.pabloweb.pricewatcher.proVersion30"

    static func hasProVersion() -> Bool {
        return UserDefaults.standard.bool(forKey: proVersionIdentifier)
    }
}
