//
//  global.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 25/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Foundation

func forceCast<T>(_ object: Any) -> T {
    guard let casted = object as? T else {
        fatalError("Expected \(object) to be of type \(T.self), got \(type(of: object)) instead")
    }

    return casted
}

func isTestRunning() -> Bool {
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
        return false
    } else {
        return true
    }
}

func isItSandbox() -> Bool {
    switch configName() {
    case .debug, .staging:
        return true
    case .release:
        return false
    }
}

func apiUrl() -> String {
    guard let apiUrlString = Bundle.main.infoDictionary?["API_URL"] as? String else {
        fatalError("Missing API_URL setting")
    }
    
    return apiUrlString
}

enum ConfigName: String {
    case debug
    case staging
    case release
}

func configName() -> ConfigName {
    guard let rawConfigName = Bundle.main.infoDictionary?["CONFIG_NAME"] as? String else {
        fatalError("Missing CONFIG_NAME setting")
    }

    return ConfigName(rawValue: rawConfigName).require(hint: "Invalid CONFIG_NAME value") 
}

@discardableResult func delay(milliseconds: Double,
                              queue: DispatchQueue = .main, completion: @escaping () -> Void) -> DispatchWorkItem {
    let task = DispatchWorkItem { completion() }
    queue.asyncAfter(deadline: .now() + (milliseconds/1000), execute: task)
    return task
}
