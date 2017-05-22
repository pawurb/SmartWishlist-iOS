//
//  AppDelegate.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 22/05/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Crashlytics
import Fabric
import RxSwift
import StoreKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let userApiClient = UserApiClient.init()
    let disposeBag = DisposeBag()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if isTestRunning() {
            return true
        }

        if configName() == .release {
            Fabric.with([Crashlytics.self, Answers.self])
        }
        
        window = UIWindow(frame:  UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()

        let navVC = UINavigationController()
        let homeVC = ProductsListVC()
        navVC.viewControllers = [homeVC]
        window?.rootViewController = navVC
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }

        let token = tokenParts.joined()
        print("Token: \(token)")
        guard let user = User.current() else { return }

        _ = userApiClient.jsonRequest(.update(
            authToken: user.authToken,
            deviceToken: user.deviceToken,
            devicePushToken: token)
            ).subscribe { _ in }.disposed(by: disposeBag)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        let notifier = NotificationCenter.default
        notifier.post(name: NSNotification.Name(rawValue: "AppBecameActive"), object: nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if #available(iOS 10.3, *){
            Answers.logCustomEvent(withName: "User asked review, by notification", customAttributes: nil)
            SKStoreReviewController.requestReview()
        }
    }
}
