//
//  FoodCategory.swift
//  Food Mart
//
//  Created by Jerry Shi on 2026-06-04.
//

import Foundation

struct FoodCategory: Codable, Identifiable {
    let uuid: String
    let name: String

    var id: String { uuid }
}
