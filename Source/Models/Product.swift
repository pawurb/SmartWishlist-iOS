//
//  Product.swift
//  PriceWatcher
//
//  Created by Pawel Urbanek on 04/06/2017.
//  Copyright © 2017 Pawel Urbanek. All rights reserved.
//

import Foundation

struct Product {
    let storeId: String
    let name: String
    let description: String
    let basePrice: String
    let currentPrice: String
    let iconUrl: URL
    let isDiscounted: Bool
    let isFree: Bool
    let discountRatio: Int
    let averageUserRating: Float
    let averageUserRatingFormatted: String
    let userRatingCount: Int
    let userRatingCountFormatted: String
}

extension Product {
    static func deserialize(json perhapsJson: [String: Any]?) -> [Product] {
        guard let jsonData = perhapsJson else {
            return []
        }

        guard let productsData = jsonData["products"] as? [[String: Any]] else {
            return []
        }

        return productsData.flatMap { productData in
            return Product(jsonData: productData)
        }
    }

    init?(jsonData: [String: Any]) {
        guard let storeId = jsonData["store_id"] as? String else {
            return nil
        }

        guard let name = jsonData["name"] as? String else {
            return nil
        }

        guard let description = jsonData["description"] as? String else {
            return nil
        }
        
        guard let basePrice = jsonData["base_price_formatted"] as? String else {
            return nil
        }
        
        guard let currentPrice = jsonData["current_price_formatted"] as? String else {
            return nil
        }

        guard let iconUrlString = jsonData["icon_url"] as? String, let iconUrl = URL(string: iconUrlString) else {
            return nil
        }
        
        guard let isDiscounted = jsonData["is_discounted"] as? Bool else {
            return nil
        }

        guard let isFree = jsonData["is_free"] as? Bool else {
            return nil
        }

        guard let discountRatio = jsonData["discount_ratio"] as? Int else {
            return nil
        }

        guard let averageUserRating = jsonData["average_user_rating"] as? Float else {
            return nil
        }

        guard let averageUserRatingFormatted = jsonData["average_user_rating_formatted"] as? String else {
            return nil
        }

        guard let userRatingCount = jsonData["user_rating_count"] as? Int else {
            return nil
        }

        guard let userRatingCountFormatted = jsonData["user_rating_count_formatted"] as? String else {
            return nil
        }
        
        self.storeId = storeId
        self.name = name
        self.description = description
        self.basePrice = basePrice
        self.currentPrice = currentPrice
        self.iconUrl = iconUrl
        self.isDiscounted = isDiscounted
        self.isFree = isFree
        self.discountRatio = discountRatio
        self.averageUserRating = averageUserRating
        self.averageUserRatingFormatted = averageUserRatingFormatted
        self.userRatingCount = userRatingCount
        self.userRatingCountFormatted = userRatingCountFormatted
    }
}
