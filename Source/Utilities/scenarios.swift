//
//  scenarios.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 22/10/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Foundation
import WaitForIt

struct AskForReview: ScenarioProtocol {
    static func config() {
        minEventsRequired = 1
        maxExecutionsPermitted = 1
    }
}
