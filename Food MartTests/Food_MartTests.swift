//
//  Food_MartTests.swift
//  Food MartTests
//
//  Created by Jerry Shi on 2026-06-04.
//

import Testing
@testable import Food_Mart

// MARK: - Fixtures

private let produce = FoodCategory(uuid: "category-produce", name: "Produce")
private let meat    = FoodCategory(uuid: "category-meat",    name: "Meat")

private let apple  = FoodItem(uuid: "item-apple",  name: "Apple",  price: 0.99,  categoryUUID: "category-produce", imageURL: "")
private let banana = FoodItem(uuid: "item-banana", name: "Banana", price: 1.49,  categoryUUID: "category-produce", imageURL: "")
private let steak  = FoodItem(uuid: "item-steak",  name: "Steak",  price: 16.49, categoryUUID: "category-meat",    imageURL: "")

// MARK: - Mock

@MainActor
private struct MockNetworkService: FoodNetworkServiceProtocol {
    var itemsToReturn: [FoodItem] = []
    var categoriesToReturn: [FoodCategory] = []
    var errorToThrow: Error? = nil

    func fetchFoodItems() async throws -> [FoodItem] {
        if let error = errorToThrow { throw error }
        return itemsToReturn
    }

    func fetchCategories() async throws -> [FoodCategory] {
        if let error = errorToThrow { throw error }
        return categoriesToReturn
    }
}

// MARK: - Cart

@Suite("Cart") @MainActor
struct CartTests {
    let viewModel: FoodListViewModel

    init() {
        viewModel = FoodListViewModel(networkService: MockNetworkService())
        viewModel.foodItems = [apple, banana, steak]
        viewModel.categories = [produce, meat]
    }

    @Test func incrementAddsItem() {
        viewModel.increment(apple)
        #expect(viewModel.quantity(for: apple) == 1)
    }

    @Test func incrementAccumulates() {
        viewModel.increment(apple)
        viewModel.increment(apple)
        #expect(viewModel.quantity(for: apple) == 2)
    }

    @Test func decrementReducesCount() {
        viewModel.increment(apple)
        viewModel.increment(apple)
        viewModel.decrement(apple)
        #expect(viewModel.quantity(for: apple) == 1)
    }

    @Test func decrementToZeroRemovesItemFromCart() {
        viewModel.increment(apple)
        viewModel.decrement(apple)
        #expect(viewModel.quantity(for: apple) == 0)
        #expect(viewModel.cartItems.isEmpty)
    }

    @Test func decrementBelowZeroIsNoOp() {
        viewModel.decrement(apple)
        #expect(viewModel.quantity(for: apple) == 0)
        #expect(viewModel.cartItems.isEmpty)
    }

    @Test func quantityForItemNotInCartIsZero() {
        #expect(viewModel.quantity(for: steak) == 0)
    }

    @Test func totalCartCountSumsAllQuantities() {
        viewModel.increment(apple)
        viewModel.increment(apple)
        viewModel.increment(steak)
        #expect(viewModel.totalCartCount == 3)
    }

    @Test func cartTotalIsCorrect() {
        viewModel.increment(apple)   // 0.99
        viewModel.increment(banana)  // 1.49
        viewModel.increment(banana)  // 1.49  →  total 3.97
        #expect(abs(viewModel.cartTotal - 3.97) < 0.001)
    }

    @Test func cartItemsAreSortedByName() {
        viewModel.increment(steak)
        viewModel.increment(apple)
        viewModel.increment(banana)
        #expect(viewModel.cartItems.map(\.item.name) == ["Apple", "Banana", "Steak"])
    }

    @Test func cartItemsReflectsQuantities() {
        viewModel.increment(apple)
        viewModel.increment(apple)
        viewModel.increment(steak)
        let cart = viewModel.cartItems
        #expect(cart.first { $0.item.uuid == apple.uuid }?.quantity == 2)
        #expect(cart.first { $0.item.uuid == steak.uuid }?.quantity == 1)
    }
}

// MARK: - Filter & Sort

@Suite("Filter and Sort") @MainActor
struct FilterSortTests {
    let viewModel: FoodListViewModel

    init() {
        viewModel = FoodListViewModel(networkService: MockNetworkService())
        viewModel.foodItems = [apple, banana, steak]
        viewModel.categories = [produce, meat]
    }

    @Test func noFilterReturnsAllItems() {
        #expect(viewModel.filteredItems.count == 3)
    }

    @Test func filterBySingleCategoryNarrowsResults() {
        viewModel.selectedCategoryIDs = ["category-produce"]
        let items = viewModel.filteredItems
        #expect(items.count == 2)
        #expect(items.allSatisfy { $0.categoryUUID == "category-produce" })
    }

    @Test func filterByAllCategoriesReturnsAll() {
        viewModel.selectedCategoryIDs = ["category-produce", "category-meat"]
        #expect(viewModel.filteredItems.count == 3)
    }

    @Test func filterWithNoMatchReturnsEmpty() {
        viewModel.selectedCategoryIDs = ["category-unknown"]
        #expect(viewModel.filteredItems.isEmpty)
    }

    @Test func sortAscendingIsLowToHigh() {
        viewModel.sortOrder = .ascending
        let prices = viewModel.filteredItems.map(\.price)
        #expect(prices == prices.sorted())
    }

    @Test func sortDescendingIsHighToLow() {
        viewModel.sortOrder = .descending
        let prices = viewModel.filteredItems.map(\.price)
        #expect(prices == prices.sorted(by: >))
    }

    @Test func sortNonePreservesOriginalOrder() {
        viewModel.sortOrder = .none
        #expect(viewModel.filteredItems.map(\.uuid) == viewModel.foodItems.map(\.uuid))
    }

    @Test func filterAndSortCombined() {
        viewModel.selectedCategoryIDs = ["category-produce"]
        viewModel.sortOrder = .descending
        let items = viewModel.filteredItems
        #expect(items.count == 2)
        #expect(items[0].price >= items[1].price)
    }
}

// MARK: - Toggle Category

@Suite("Toggle Category") @MainActor
struct ToggleCategoryTests {
    let viewModel: FoodListViewModel

    init() {
        viewModel = FoodListViewModel(networkService: MockNetworkService())
    }

    @Test func toggleSelectsCategory() {
        viewModel.toggleCategory("category-produce")
        #expect(viewModel.selectedCategoryIDs.contains("category-produce"))
    }

    @Test func toggleDeselecstAlreadySelectedCategory() {
        viewModel.toggleCategory("category-produce")
        viewModel.toggleCategory("category-produce")
        #expect(!viewModel.selectedCategoryIDs.contains("category-produce"))
    }

    @Test func toggleMultipleCategoriesAreIndependent() {
        viewModel.toggleCategory("category-produce")
        viewModel.toggleCategory("category-meat")
        #expect(viewModel.selectedCategoryIDs.count == 2)
    }
}

// MARK: - Network / loadData

@Suite("loadData") @MainActor
struct LoadDataTests {
    @Test func successPopulatesItemsAndCategories() async {
        let service = MockNetworkService(
            itemsToReturn: [apple, banana],
            categoriesToReturn: [produce, meat]
        )
        let viewModel = FoodListViewModel(networkService: service)
        await viewModel.loadData()
        #expect(viewModel.foodItems.count == 2)
        #expect(viewModel.categories.count == 2)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test func failureSetsErrorMessage() async {
        struct StubError: Error {}
        let service = MockNetworkService(errorToThrow: StubError())
        let viewModel = FoodListViewModel(networkService: service)
        await viewModel.loadData()
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.foodItems.isEmpty)
        #expect(viewModel.isLoading == false)
    }

    @Test func isLoadingIsFalseAfterCompletion() async {
        let service = MockNetworkService(itemsToReturn: [apple], categoriesToReturn: [produce])
        let viewModel = FoodListViewModel(networkService: service)
        await viewModel.loadData()
        #expect(viewModel.isLoading == false)
    }
}

// MARK: - categoryName

@Suite("categoryName") @MainActor
struct CategoryNameTests {
    let viewModel: FoodListViewModel

    init() {
        viewModel = FoodListViewModel(networkService: MockNetworkService())
        viewModel.foodItems = [apple, steak]
        viewModel.categories = [produce, meat]
    }

    @Test func returnsCorrectNameForKnownCategory() {
        #expect(viewModel.categoryName(for: apple) == "Produce")
        #expect(viewModel.categoryName(for: steak) == "Meat")
    }

    @Test func returnsEmptyStringForUnknownCategory() {
        let unknownCategory = FoodItem(uuid: "x", name: "X", price: 1.0, categoryUUID: "category-unknown", imageURL: "")
        #expect(viewModel.categoryName(for: unknownCategory) == "")
    }
}
