//
//  messages.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 11/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Foundation

struct Messages {
    static var appWasAdded: String {
        return "App has been successfully added to Smart Wishlist. You will receive a push notification when the price drops!"
    }

    static var invalidContent: String {
        return "Failed to load app data. Make sure you only use the extension from within the AppStore app."
    }

    static var accountMissing: String {
        return "Looks like your Smart Wishlist account is not set up yet. Please open the app to fix it."
    }

    static var addingError: String {
        return "There was an error adding this app to your Smart Wishlist. Make sure you are connected to the internet. If the problem persists please contact us via the support page - we promise to fix it as quick as possible."
    }
}
