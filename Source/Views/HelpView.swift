//
//  HelpView.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 05/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import AVFoundation
import AVKit
import SnapKit
import UIKit

class HelpView: UIView {
    private let closeButton = UIButton(type: .system)
    private let emailButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private let scrollView  = UIScrollView(frame: .zero)

    private let setupTitleLabel = UILabel(frame: .zero)

    var onCloseButtonTap: (() -> Void)?
    var onShareButtonTap: (() -> Void)?
    var onEmailButtonTap: (() -> Void)?
    var videoPlayer: AVPlayer?

    init() {
        super.init(frame: .zero)

        setupSubviews()
        addSubviews()
        setupLayout()
    }

    func setupSubviews() {
        backgroundColor = .white
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(self.tintColor, for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 18)
        closeButton.titleLabel?.textAlignment = .center
        closeButton.addTarget(self, action: #selector(closeButtonTap), for: .touchUpInside)

        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(self.tintColor, for: .normal)
        shareButton.titleLabel?.font = .systemFont(ofSize: 18)
        shareButton.titleLabel?.textAlignment = .center
        shareButton.addTarget(self, action: #selector(shareButtonTap), for: .touchUpInside)

        emailButton.setTitle("Contact\nSupport", for: .normal)
        emailButton.setTitleColor(self.tintColor, for: .normal)
        emailButton.titleLabel?.font = .systemFont(ofSize: 18)
        emailButton.titleLabel?.numberOfLines = 2
        emailButton.titleLabel?.textAlignment = .center
        emailButton.addTarget(self, action: #selector(emailButtonTap), for: .touchUpInside)

        scrollView.backgroundColor = .white
        scrollView.isScrollEnabled = true

        setupTitleLabel.text = Messages.setupTitle
        setupTitleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        setupTitleLabel.textAlignment = .center
        setupTitleLabel.numberOfLines = 2
    }

    func addSubviews() {
        addSubview(closeButton)
        addSubview(shareButton)
        addSubview(emailButton)
        addSubview(scrollView)

        scrollView.addSubview(setupTitleLabel)
    }

    func setupScroll() {
        scrollView.contentSize = CGSize(width: frame.size.width, height: frame.size.height * 1.8)
    }

    @objc private func closeButtonTap() { onCloseButtonTap?() }
    @objc private func shareButtonTap() { onShareButtonTap?() }
    @objc private func emailButtonTap() { onEmailButtonTap?() }

    func setupLayout() {
        closeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(30)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }

        shareButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }

        emailButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(30)
            make.width.equalTo(80)
            make.height.equalTo(60)
        }

        scrollView.snp.makeConstraints { make in
            let offset: CGFloat = 90
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(offset)
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(-offset)
        }

        setupScrollViewLayout()
    }

    func setupScrollViewLayout() {
        let scrollViewOffsetV: CGFloat = 15
        let labelWidthOffset: CGFloat = 20
        let labelHeight: CGFloat = 60

        setupTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-labelWidthOffset)
            make.height.equalTo(labelHeight)
            make.top.equalToSuperview().offset(scrollViewOffsetV/2)
        }
    }
    
    func setupVideo() {
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.anchorPoint = CGPoint.zero
        playerLayer.frame = CGRect(
            x: -(frame.size.width * 0.25),
            y: frame.size.height/3.5,
            width: frame.size.width * 1.5,
            height: frame.size.height * 0.6
        )
        
        self.layer.addSublayer(playerLayer)
        videoPlayer?.play()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
