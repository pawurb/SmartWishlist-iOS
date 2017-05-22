//
//  HelpVC.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 05/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import AVFoundation
import AVKit
import Crashlytics
import MessageUI
import UIKit

class HelpVC: UIViewController {
    private let alert = AlertPresenter()

    var helpView: HelpView { return forceCast(view) }

    init() {
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restartVideo),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    @objc func restartVideo() {
        helpView.videoPlayer?.seek(to: kCMTimeZero)
        helpView.videoPlayer?.play()
    }
    
    override func loadView() {
        view = HelpView()
    }

    override func viewDidLoad() {
        helpView.onCloseButtonTap = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        helpView.onShareButtonTap = { [weak self] in
            self?.shareWishlist()
        }

        helpView.onEmailButtonTap = { [weak self] in
            self?.sendEmail()
        }
        
        let videoUrl = Bundle.main.url(forResource: "tutorial_video", withExtension: "mp4")!
        helpView.videoPlayer = AVPlayer(url: videoUrl)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        helpView.setupScroll()
        helpView.setupVideo()
    }

    func shareWishlist() {
        let text = "Check out this app for tracking #AppStore discounts:"
        let link = URL(string: "https://wishlist.apki.io")!
        Answers.logCustomEvent(withName: "Tap share button", customAttributes: nil)

        let shareController = UIActivityViewController(activityItems: [text, link], applicationActivities: nil)
        self.present(shareController, animated: true, completion: {
            Answers.logCustomEvent(withName: "Did share", customAttributes: nil)
        })
    }

    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setSubject("Smart Wishlist - App feedback")
            mailComposerVC.setToRecipients(["p.urbanek89@gmail.com"])
            present(mailComposerVC, animated: true, completion: nil)
        } else {
            showEmailError()
        }
    }

    func showEmailError() {
        self.alert.show(in: self, title: "Error", message: Messages.emailSendError)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension HelpVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
