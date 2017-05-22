//
//  NoDiscountTableViewCell.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 04/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import SDWebImage
import UIKit

class NoDiscountTableViewCell: ProductTableViewCell {
    private let noDiscountLabel = UILabel(frame: .zero)

    override func setupSubviews() {
        noDiscountLabel.text = "Currently not discounted"
        super.setupSubviews()
    }

    override func addSubviews() {
        super.addSubviews()
        addSubview(noDiscountLabel)
    }

    override func setupLayout() {
        super.setupLayout()
    }

    override func setup(product: Product) {
        super.setup(product: product)
        basePriceLabel.text = "\(product.basePrice)"
    }

}
