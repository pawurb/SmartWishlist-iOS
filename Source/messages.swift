//
//  messages.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 05/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

struct Messages {
    static var registrationError: String {
        return "There was an error when trying to set up your account. Make sure you are connected to the internet and refresh to try again. If the problem persists please contact us via the help page and we will fix it as quick as possible."
    }

    static var userRegistered: String {
        return "Your account was successfully set up. Please allow push notifications. We promise to send you no spam, only info about discounts of apps you have chosen yourself."
    }

    static var productsFetchError: String {
        return "There was a problem fetching your product data. Make sure you are connected to the internet and pull to refresh to try again. If the problem persists please contact us via the help page and we will fix it as quick as possible."
    }

    static var productRemoved: String {
        return "The product was successfully removed from your wish list."
    }

    static var productRemoveError: String {
        return "There was a problem removing product data. Make sure you are connected to the internet. If the problem persists please contact us via the help page and we will fix it as quick as possible."
    }

    static var useExtension: String {
        return "You can add apps to your Smart Wishlist directly from within the AppStore using the share extension. Visit the help page for video tutorial on how to use it."
    }

    static var emailSendError: String {
        return "Your device could not send e-mail. Please check your e-mail configuration and try again."
    }

    static var setupTitle: String {
        return "AppStore share extension"
    }

    static var purchasesLoadingError: String {
        return "There was a problem loading in app purchases data. Please try again in a moment."
    }
}
