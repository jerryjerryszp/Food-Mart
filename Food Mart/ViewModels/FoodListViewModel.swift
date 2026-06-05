//
//  FoodListViewModel.swift
//  Food Mart
//
//  Created by Jerry Shi on 2026-06-04.
//

import Foundation
import Observation

enum PriceSortOrder: String, CaseIterable {
    case none = "Default"
    case ascending = "Price: Low to High"
    case descending = "Price: High to Low"
}

@Observable
class FoodListViewModel {
    var foodItems: [FoodItem] = []
    var categories: [FoodCategory] = []
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Filter & Sort
    var sortOrder: PriceSortOrder = .none
    var selectedCategoryIDs: Set<String> = []

    var filteredItems: [FoodItem] {
        var items = foodItems

        if !selectedCategoryIDs.isEmpty {
            items = items.filter { selectedCategoryIDs.contains($0.categoryUUID) }
        }

        switch sortOrder {
        case .ascending: items.sort { $0.price < $1.price }
        case .descending: items.sort { $0.price > $1.price }
        case .none: break
        }

        return items
    }

    func toggleCategory(_ uuid: String) {
        if selectedCategoryIDs.contains(uuid) {
            selectedCategoryIDs.remove(uuid)
        } else {
            selectedCategoryIDs.insert(uuid)
        }
    }

    // MARK: - Cart
    private(set) var cartQuantities: [String: Int] = [:]

    var cartItems: [(item: FoodItem, quantity: Int)] {
        cartQuantities.compactMap { uuid, itemQuantity in
            guard let item = foodItems.first(where: { $0.uuid == uuid }) else { return nil }
            return (item, itemQuantity)
        }.sorted { $0.item.name < $1.item.name }
    }

    var totalCartCount: Int {
        cartQuantities.values.reduce(0, +)
    }

    var cartTotal: Double {
        cartItems.reduce(0) { $0 + $1.item.price * Double($1.quantity) }
    }

    func quantity(for item: FoodItem) -> Int {
        cartQuantities[item.uuid] ?? 0
    }

    func increment(_ item: FoodItem) {
        cartQuantities[item.uuid, default: 0] += 1
    }

    func decrement(_ item: FoodItem) {
        guard let qty = cartQuantities[item.uuid], qty > 0 else { return }
        if qty == 1 {
            cartQuantities.removeValue(forKey: item.uuid)
        } else {
            cartQuantities[item.uuid] = qty - 1
        }
    }

    // MARK: - Network
    private let networkService: FoodNetworkServiceProtocol

    init(networkService: FoodNetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let fetchedFoodItems = networkService.fetchFoodItems()
            async let fetchedCategories = networkService.fetchCategories()
            foodItems = try await fetchedFoodItems
            categories = try await fetchedCategories
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func categoryName(for item: FoodItem) -> String {
        categories.first { $0.uuid == item.categoryUUID }?.name ?? ""
    }
}
