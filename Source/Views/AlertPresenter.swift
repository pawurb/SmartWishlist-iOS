//
//  AlertPresenter.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 05/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import UIKit

class AlertPresenter {
    func show(in controller: UIViewController?, title: String,
              message: String, buttonText: String = "Ok", completion: (()->Void)?=nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonText, style: .default) { _ in
            completion?()
        }

        alert.addAction(okAction)
        controller?.present(alert, animated: true)
    }
}
