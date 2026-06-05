//
//  FoodItem.swift
//  Food Mart
//
//  Created by Jerry Shi on 2026-06-04.
//

import Foundation

struct FoodItem: Codable, Identifiable {
    let uuid: String
    let name: String
    let price: Double
    let categoryUUID: String
    let imageURL: String

    var id: String { uuid }

    enum CodingKeys: String, CodingKey {
        case uuid, name, price
        case categoryUUID = "category_uuid"
        case imageURL = "image_url"
    }
}
