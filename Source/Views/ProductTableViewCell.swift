//
//  ProductTableViewCell.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 04/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import SDWebImage
import UIKit

class ProductTableViewCell: UITableViewCell {
    static let height: CGFloat = 80.0
    internal let iconImageView = UIImageView(frame: .zero)
    internal let titleLabel = UILabel(frame: .zero)
    internal let basePriceLabel = UILabel(frame: .zero)

    static var reuseIdentifier: String {
        return String(describing: self)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        setupSubviews()
        addSubviews()
        setupLayout()
    }

    func setupSubviews() {
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .center
        basePriceLabel.font = .boldSystemFont(ofSize: 15)
        iconImageView.sd_setIndicatorStyle(.gray)
        iconImageView.sd_showActivityIndicatorView()
    }

    func addSubviews() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(basePriceLabel)
    }
    
    func setupLayout() {
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left)
            make.top.equalToSuperview().offset(1)
            make.height.equalTo(ProductTableViewCell.height-2)
            make.width.equalTo(ProductTableViewCell.height-2)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.top.equalToSuperview()
            make.height.equalTo(ProductTableViewCell.height/1.5)
            make.width.equalToSuperview().offset(-(ProductTableViewCell.height + 20))
        }

        basePriceLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-7)
            make.left.equalTo(iconImageView.snp.right).offset(10)
        }
    }

    func setup(product: Product) {
        titleLabel.text = "\(product.name) \n★\(product.averageUserRatingFormatted) (\(product.userRatingCountFormatted))"
        iconImageView.sd_setImage(with: product.iconUrl)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.sd_cancelCurrentImageLoad()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
