//
//  DiscountTableViewCell.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 04/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import SDWebImage
import UIKit

class DiscountTableViewCell: ProductTableViewCell {
    private let currentPriceLabel = UILabel(frame: .zero)
    private let discountRatioLabel = UILabel(frame: .zero)
    private let color = UIColor.hexStringToUIColor(hex: "#C0392B")

    override func setupSubviews() {
        super.setupSubviews()
        currentPriceLabel.font = UIFont.boldSystemFont(ofSize: 15)
        discountRatioLabel.font = UIFont.boldSystemFont(ofSize: 15)

        currentPriceLabel.textColor = color
        discountRatioLabel.textColor = color
    }

    override func addSubviews() {
        super.addSubviews()
        contentView.addSubview(currentPriceLabel)
        contentView.addSubview(discountRatioLabel)
    }

    override func setupLayout() {
        super.setupLayout()

        currentPriceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-7)
        }

        discountRatioLabel.snp.makeConstraints { make in
            make.left.equalTo(basePriceLabel.snp.right).offset(7)
            make.bottom.equalToSuperview().offset(-7)
        }
    }

    override func setup(product: Product) {
        super.setup(product: product)
        basePriceLabel.text = "Was \(product.basePrice)"
        currentPriceLabel.text = "Now \(product.currentPrice)"
        discountRatioLabel.text = "-\(product.discountRatio)%"
    }
}
