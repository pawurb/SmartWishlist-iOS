//
//  NoProductsCell.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 05/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import SnapKit
import UIKit

class NoProductsTableViewCell: UITableViewCell {
    private let customTextLabel = UILabel(frame: .zero)

    init(section: TableSections) {
        super.init(style: .default, reuseIdentifier: nil)
        contentView.addSubview(customTextLabel)
        switch section {
        case .discounted:
            customTextLabel.text = "No discounted apps yet"
        case .free:
            customTextLabel.text = "No free apps"
        case .standardPrice:
            customTextLabel.text = "No apps"
        }

        customTextLabel.textColor = .lightGray
        customTextLabel.font = .systemFont(ofSize: 16)
        
        customTextLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
