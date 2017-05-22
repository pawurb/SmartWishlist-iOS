//
//  LoadingViewPresenter.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 05/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import SnapKit
import UIKit

class LoadingViewPresenter {
    var isShowing = false
    
    private lazy var controller: UIViewController = {
        let controller = UIViewController()
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overCurrentContext
        return controller
    }()

    init() {
        controller.view.backgroundColor = .clear
        let cover = UIView(frame: controller.view.frame)
        cover.backgroundColor = .black
        cover.alpha = 0.8

        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

        cover.addSubview(spinner)
        controller.view.addSubview(cover)
        cover.layer.cornerRadius = 8.0

        cover.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.centerX.centerY.equalToSuperview()
        }

        spinner.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        spinner.startAnimating()
    }

    func show(in target: UIViewController, completion: (() -> Void)? = nil) {
        if !isShowing {
            isShowing = true
            target.present(self.controller, animated: true, completion: completion)
        }
    }

    func hide(completion: (() -> Void)? = nil) {
        if isShowing {
            isShowing = false
            controller.dismiss(animated: true, completion: completion)
        }
    }
}
