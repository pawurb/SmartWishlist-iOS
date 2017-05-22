//
//  FreeProductTableViewCell.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 18/10/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Foundation

import SDWebImage
import UIKit

class FreeProductTableViewCell: ProductTableViewCell {
    override func setup(product: Product) {
        super.setup(product: product)
        basePriceLabel.text = "\(product.basePrice)"
    }
}
