//
//  ProductsListVC.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 03/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
// swiftlint:disable file_length

import Crashlytics
import Fabric
import RxSwift
import StoreKit
import UIKit
import UserNotifications

enum TableSections: Int {
    case discounted = 0
    case free = 1
    case standardPrice = 2
    static var count: Int { return 3 }

    var headerTitle: String {
        switch self {
        case .discounted:
            return "Currently discounted"
        case .free:
            return "Free"
        case .standardPrice:
            return "Not discounted yet"
        }
    }
}

class ProductsListVC: UIViewController {
    private let productsApiClient: ProductsApiClient
    private let userApiClient: UserApiClient
    private let spinner = LoadingViewPresenter()
    private let alert = AlertPresenter()
    private let notifier = NotificationCenter.default
    private let kAffiliateToken = "1001lxGu"

    var currentSegment: AppsSegment {
        return productsView.currentSegment
    }

    var discountedProducts = [Product]()
    var freeProducts = [Product]()
    var standardPriceProducts = [Product]()
    var productsView: ProductsView { return forceCast(view) }
    var tableView: UITableView { return forceCast(productsView.tableView) }
    
    let disposeBag = DisposeBag()

    convenience init() {
        self.init(
            productsApiClient: ProductsApiClient(),
            userApiClient: UserApiClient()
        )
    }

    override func loadView() {
         view = ProductsView()
    }

    init(productsApiClient: ProductsApiClient, userApiClient: UserApiClient) {
        self.productsApiClient = productsApiClient
        self.userApiClient = userApiClient
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DiscountTableViewCell.self,
                           forCellReuseIdentifier: DiscountTableViewCell.reuseIdentifier)
        tableView.register(FreeProductTableViewCell.self,
                           forCellReuseIdentifier: FreeProductTableViewCell.reuseIdentifier)
        tableView.register(NoDiscountTableViewCell.self,
                           forCellReuseIdentifier: NoDiscountTableViewCell.reuseIdentifier)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "help"),
                                                           style: .plain, target: self, action: #selector(goToHelp))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self, action: #selector(displayAddHelp))
        let twitterButton = UIButton(type: .system)
        twitterButton .setImage(UIImage(named: "twitter-icon"), for: .normal)
        twitterButton.addTarget(self, action: #selector(openTwitter), for: .touchUpInside)

        navigationItem.titleView = twitterButton

        productsView.onRefreshStart = { [weak self] in
            guard let `self` = self else { return }
            self.refreshData(showSpinner: false)
        }

        productsView.onSegmentedTap = { [weak self] index in
            guard let `self` = self else { return }
            self.tableView.setContentOffset(.zero, animated: false)
            self.refreshData(showSpinner: true)
        }

        getPushNotificationSettings()
        
        delay(milliseconds: 2500, completion: { [weak self] in
            guard let `self` = self else { return }
            self.notifier.addObserver(self, selector: #selector(self.registerUser),
                                 name: NSNotification.Name(rawValue: "AppBecameActive"), object: nil)

        })
        registerUser()
        tryToAskForReview()
    }

    func goToHelp() {
        let helpVC = HelpVC()
        present(helpVC, animated: true, completion: nil)
    }

    func tryToAskForReview() {
        AskForReview.tryToExecute { didExecute in
            if didExecute {
                Answers.logCustomEvent(withName: "User asked review, by load", customAttributes: nil)
                SKStoreReviewController.requestReview()
            }
        }
    }

    func refreshPromotionsData(showSpinner: Bool) {
        if showSpinner { spinner.show(in: self) }

        productsApiClient.jsonRequest(.promotions)
        .map { jsonData -> [Product] in
            return Product.deserialize(json: jsonData as? [String: Any])
        }.subscribe { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case let .next(products):
                self.discountedProducts = products
                self.freeProducts = []
                self.standardPriceProducts = []
                self.tableView.reloadData()
            case .error:
                self.alert.show(in: self, title: "Error", message: Messages.productsFetchError)
            default:
                break
            }

            if showSpinner { self.spinner.hide() }
            self.productsView.endRefreshing()
        }.disposed(by: disposeBag)
    }

    func refreshProductsData(showSpinner: Bool) {
        guard let user = User.current() else {
            self.alert.show(in: self, title: "Error", message: Messages.productsFetchError)
            return
        }

        if showSpinner { spinner.show(in: self) }

        productsApiClient.jsonRequest(
            .index(
                authToken: user.authToken,
                deviceToken: user.deviceToken
            )
        ).map { jsonData -> [Product] in
            return Product.deserialize(json: jsonData as? [String: Any])
        }.subscribe { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case let .next(products):
                self.discountedProducts = products.filter { $0.isDiscounted }

                if !self.discountedProducts.isEmpty {
                    AskForReview.triggerEvent()
                }

                self.freeProducts = products.filter { $0.isFree }
                self.standardPriceProducts = products.filter { !$0.isDiscounted && !$0.isFree }
                self.tableView.reloadData()
            case .error:
                self.alert.show(in: self, title: "Error", message: Messages.productsFetchError)
            default:
                break
            }

            if showSpinner { self.spinner.hide() }
            self.productsView.endRefreshing()
        }.disposed(by: disposeBag)
    }

    func refreshData(showSpinner: Bool) {
        switch currentSegment {
        case .user:
            refreshProductsData(showSpinner: showSpinner)
        case .promotions:
            refreshPromotionsData(showSpinner: showSpinner)
        }
    }

    func registerUser() {
        if User.current() != nil {
            requestPushPermission()
            refreshData(showSpinner: true)
            return
        }

        let newUser = User()
        Answers.logCustomEvent(withName: "user.register", customAttributes: nil)
        userApiClient.register(user: newUser).subscribe { [weak self] event in
            switch event {
            case .next:
                _ = User.persist(user: newUser)
                self?.alert.show(in: self, title: "", message: Messages.userRegistered) { [weak self] in
                    self?.requestPushPermission()
                }
                self?.refreshProductsData(showSpinner: true)
            case .error:
                self?.alert.show(in: self, title: "Error", message: Messages.registrationError)
            default:
                break
            }
        }.disposed(by: disposeBag)
    }

    fileprivate func productWasSelected(product: Product) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        let storeAction = UIAlertAction(title: "Go to AppStore", style: .default) { [weak self] _ in
            self?.goToAppStore(identifier: product.storeId)
        }

        let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self] _ in
            self?.shareLink(product: product)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let user = User.current(), let `self` = self else {
                return
            }

            self.spinner.show(in: self)
            self.productsApiClient.jsonRequest(.destroy(
                authToken: user.authToken,
                deviceToken: user.deviceToken,
                storeId: product.storeId)
            ).subscribe { [weak self] event in
                guard let `self` = self else {
                    return
                }
                
                self.spinner.hide { [unowned self] in
                    switch event {
                    case .next:
                        self.alert.show(in: self, title: "", message: Messages.productRemoved)
                    case .error:
                        self.alert.show(in: self, title: "", message: Messages.productRemoveError)
                    default:
                        break
                    }

                    self.refreshProductsData(showSpinner: true)
                }

            }.disposed(by: self.disposeBag)
        }
        
        alert.addAction(storeAction)
        alert.addAction(shareAction)

        if currentSegment == .user {
            alert.addAction(removeAction)
        }

        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func shareLink(product: Product) {
        let link = URL(string: "https://itunes.apple.com/us/app/id\(product.storeId)?at=\(kAffiliateToken)")!
        Answers.logCustomEvent(withName: "Tap share discount", customAttributes: nil)
        
        let shareController = UIActivityViewController(activityItems: ["", link], applicationActivities: nil)
        self.present(shareController, animated: true, completion: {
            Answers.logCustomEvent(withName: "Did share discount", customAttributes: nil)
        })
    }

    func goToAppStore(identifier: String) {
        guard let intIdentifier = Int(identifier) else {
            return
        }
        let parsedIdentifier: NSNumber = NSNumber(value: intIdentifier)

        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        let parameters = [
            SKStoreProductParameterITunesItemIdentifier: parsedIdentifier,
            SKStoreProductParameterAffiliateToken: kAffiliateToken,
            SKStoreProductParameterCampaignToken: "wishlist"
        ] as [String : Any]
        storeViewController.loadProduct(withParameters: parameters, completionBlock: nil)
        self.present(storeViewController, animated: true, completion: nil)
    }

    fileprivate func productForIndexPath(indexPath: IndexPath) -> Product? {
        switch TableSections(rawValue: indexPath.section)! {
        case .discounted:
            return discountedProducts[safe: indexPath.row]
        case .free:
            return freeProducts[safe: indexPath.row]
        case .standardPrice:
            return standardPriceProducts[safe: indexPath.row]
        }
    }

    @objc private func displayAddHelp() {
        self.alert.show(in: self, title: "Use extension", message: Messages.useExtension)
    }

    @objc private func openTwitter() {
        Answers.logCustomEvent(withName: "User open twitter", customAttributes: nil)
        let url = URL(string: "https://twitter.com/apps_wishlist")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func requestPushPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            guard granted else { return }
            self?.getPushNotificationSettings()
        }
    }

    private func getPushNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            print("Notification settings: \(settings)")
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    deinit {
        notifier.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ProductsListVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let product = productForIndexPath(indexPath: indexPath) {
            productWasSelected(product: product)
        }
    }
}

extension ProductsListVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TableSections(rawValue: indexPath.section)! {
        case .discounted:
            guard let product = productForIndexPath(indexPath: indexPath) else {
                return NoProductsTableViewCell(section: .discounted)
            }

            guard let cell = tableView.dequeueReusableCell(withIdentifier: DiscountTableViewCell.reuseIdentifier,
                                                           for: indexPath) as? DiscountTableViewCell else {
                fatalError("Invalid table view cell cast")
            }

            cell.setup(product: product)
            return cell
        case .free:
            guard let product = productForIndexPath(indexPath: indexPath) else {
                return NoProductsTableViewCell(section: .free)
            }

            guard let cell = tableView.dequeueReusableCell(withIdentifier: FreeProductTableViewCell.reuseIdentifier,
                                                           for: indexPath) as? FreeProductTableViewCell else {
                                                            fatalError("Invalid table view cell cast")
            }

            cell.setup(product: product)
            return cell
        case .standardPrice:
            guard let product = productForIndexPath(indexPath: indexPath) else {
                return NoProductsTableViewCell(section: .standardPrice)
            }

            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoDiscountTableViewCell.reuseIdentifier,
                                                           for: indexPath) as? NoDiscountTableViewCell else {
                fatalError("Invalid table view cell cast")
            }
            
            cell.setup(product: product)
            return cell
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        switch currentSegment {
        case .user:
            return TableSections.count
        case .promotions:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ProductTableViewCell.height
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSections(rawValue: section)! {
        case .discounted:
            if discountedProducts.isEmpty {
                return 1
            } else {
                return discountedProducts.count
            }
        case .free:
            if freeProducts.isEmpty {
                return 1
            } else {
                return freeProducts.count
            }
        case .standardPrice:
            if standardPriceProducts.isEmpty {
                return 1
            } else {
                return standardPriceProducts.count
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TableSections(rawValue: section)!.headerTitle
    }
}

extension ProductsListVC: SKStoreProductViewControllerDelegate {
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
