//
//  NetworkService.swift
//  Food Mart
//
//  Created by Jerry Shi on 2026-06-04.
//

import Foundation

protocol FoodNetworkServiceProtocol {
    func fetchFoodItems() async throws -> [FoodItem]
    func fetchCategories() async throws -> [FoodCategory]
}

class NetworkService: FoodNetworkServiceProtocol {
    static let shared = NetworkService()

    private let foodItemsURL = URL(string: "https://7shifts.github.io/mobile-takehome/api/food_items.json")!
    private let categoriesURL = URL(string: "https://7shifts.github.io/mobile-takehome/api/food_item_categories.json")!

    func fetchFoodItems() async throws -> [FoodItem] {
        let (data, _) = try await URLSession.shared.data(from: foodItemsURL)
        return try JSONDecoder().decode([FoodItem].self, from: data)
    }

    func fetchCategories() async throws -> [FoodCategory] {
        let (data, _) = try await URLSession.shared.data(from: categoriesURL)
        return try JSONDecoder().decode([FoodCategory].self, from: data)
    }
}
