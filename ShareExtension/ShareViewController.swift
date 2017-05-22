
//  ShareViewController.swift
//  PriceWatcherShareExtension
//
//  Created by Pawel Urbanek on 08/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import UIKit
import Social
import KeychainAccess
import MobileCoreServices

class ShareViewController: UIViewController {
    private let alertView = AlertPresenter()
    private let loadingView = LoadingViewPresenter()
    private var appStoreUrl: String?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingView.show(in: self)
        load()
    }

    @objc private func addToWishlist() {
        guard let newAppUrl = appStoreUrl else {
            self.loadingView.hide { [weak self] in
                self?.invalidContentAlert()
            }
            return
        }

        guard let user = User.current() else {
            self.loadingView.hide { [weak self] in
                self?.missingAccountAlert()
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let session = URLSession.shared
            let endpointString: String = apiUrl() + "/products"
            let endpointUrl = URL(string: endpointString)!
            var request = URLRequest(url: endpointUrl)
            request.httpMethod = "POST"
            let json: [String: Any] =
                [
                    "auth_token": user.authToken,
                    "device_token": user.deviceToken,
                    "app_url": newAppUrl,
                    "is_pro": user.isPro
                ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
                DispatchQueue.main.async { [weak self] in
                    self?.loadingView.hide { [weak self] in
                        self?.invalidContentAlert()
                    }
                }

                return 
            }

            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else {
                    fatalError("wtf response?")
                }

                DispatchQueue.main.async { [weak self] in
                    self?.loadingView.hide { [weak self] in
                        if httpResponse.statusCode == 201 {
                            self?.addedToWishlistAlert()
                        } else {
                            self?.addingErrorAlert()
                        }
                        return 
                    }
                }
            })

            task.resume()
        }
    }

    private func load() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            self.invalidContentAlert()
            return
        }

        guard let attachments = extensionItem.attachments as? [NSItemProvider] else {
            self.invalidContentAlert()
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            attachments.forEach { [weak self] attachment in
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
                    attachment.loadItem(forTypeIdentifier: (kUTTypeText as String), options: nil, completionHandler: { [weak self] itemString, error in
                        DispatchQueue.main.async { [weak self] in
                            guard error == nil else {
                                self?.invalidContentAlert()
                                return
                            }

                            guard let _ = itemString as? String else {
                                self?.invalidContentAlert()
                                return
                            }
                        }
                    })
                } else if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    attachment.loadItem(forTypeIdentifier: (kUTTypeImage as String), options: nil, completionHandler: { [weak self] itemData, error in
                        DispatchQueue.main.async { [weak self] in
                            guard error == nil else {
                                self?.invalidContentAlert()
                                return
                            }

                            guard let _ = itemData as? UIImage else {
                                self?.invalidContentAlert()
                                return
                            }
                        }
                    })
                } else if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    attachment.loadItem(forTypeIdentifier: (kUTTypeURL as String), options: nil, completionHandler: { [weak self] itemUrl, error in
                        DispatchQueue.main.async { [weak self] in
                            guard error == nil else {
                                self?.invalidContentAlert()
                                return
                            }

                            guard let appUrl = itemUrl as? URL else {
                                self?.invalidContentAlert()
                                return
                            }

                            self?.appStoreUrl = appUrl.absoluteString
                            self?.addToWishlist()
                        }
                    })
                }
            }
        }
    }

    private func invalidContentAlert() {
        alertView.show(in: self, title: "Error", message: Messages.invalidContent, buttonText: "Ok") { [weak self] in
            self?.closeExtension()
        }
    }

    private func addedToWishlistAlert() {
        alertView.show(in: self, title: "Success", message: Messages.appWasAdded, buttonText: "Great!") { [weak self] in
            self?.closeExtension()
        }
    }

    private func addingErrorAlert() {
        alertView.show(in: self, title: "Error", message: Messages.addingError, buttonText: "Ok") { [weak self] in
            self?.closeExtension()
        }
    }

    private func missingAccountAlert() {
        alertView.show(in: self, title: "Error", message: Messages.accountMissing, buttonText: "Ok") { [weak self] in
            self?.closeExtension()
        }
    }

    @objc private func closeExtension() {
       extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
}
