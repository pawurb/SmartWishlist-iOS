//
//  productsView.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 04/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import SnapKit
import UIKit

enum AppsSegment: Int {
    case user = 0
    case promotions = 1
}

class ProductsView: UIView {
    let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    let segmentedControl: UISegmentedControl = UISegmentedControl(items: ["Wishlist", "Promotions"])
    private let refreshControl = UIRefreshControl()
    var onRefreshStart: (() -> Void)?
    var onSegmentedTap: (() -> Void)?
    private let segmentedHeight: CGFloat = 40.0
    private lazy var headerHeight: CGFloat = {
        var iphoneX = false
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow {
                if window.safeAreaInsets.top > 0.0 {
                    iphoneX = true
                }
            }
        }

        if iphoneX {
            return 88.0
        } else {
            return 64.0
        }
    }()

    var currentSegment: AppsSegment {
        return AppsSegment(rawValue: segmentedControl.selectedSegmentIndex) ?? .user
    }

    init() {
        super.init(frame: .zero)

        setupSubviews()
        addSubviews()
        setupLayout()
    }

    @objc private func refresh(_: Any) {
        refreshControl.beginRefreshing()
        onRefreshStart?()
    }

    func endRefreshing() {
        refreshControl.endRefreshing()
    }

    private func setupSubviews() {
        tableView.tableFooterView = UIView()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedTap), for: .valueChanged)
    }

    private func addSubviews() {
        addSubview(segmentedControl)
        addSubview(tableView)
        segmentedControl.selectedSegmentIndex = 0
        tableView.addSubview(refreshControl)
    }

    private func setupLayout() {
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self).offset(headerHeight)
            make.width.equalTo(self)
            make.height.equalTo(segmentedHeight)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(segmentedHeight + headerHeight + 1)
            make.width.equalTo(self)
            make.height.equalTo(self).offset(-segmentedHeight)
        }
    }

    @objc private func segmentedTap() { onSegmentedTap?() }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
