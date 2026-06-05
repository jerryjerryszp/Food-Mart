//
//  FoodListView.swift
//  Food Mart
//
//  Created by Jerry Shi on 2026-06-04.
//

import SwiftUI

struct FoodListView: View {
    @State private var viewModel = FoodListViewModel()
    @State private var showingCart = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.foodItems.isEmpty {
                    ProgressView("Loading stuff ...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage, viewModel.foodItems.isEmpty {
                    ContentUnavailableView(
                        "Failed to Load :(",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else {
                    listView
                }
            }
            .navigationTitle("Food Mart")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    sortMenu
                    categoryMenu
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .sheet(isPresented: $showingCart) {
            CartView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationBackground(Color(.systemBackground))
        }
    }

    private var listView: some View {
        List {
            ForEach(viewModel.filteredItems) { item in
                FoodItemRow(
                    item: item,
                    categoryName: viewModel.categoryName(for: item),
                    quantity: viewModel.quantity(for: item),
                    onIncrement: { viewModel.increment(item) },
                    onDecrement: { viewModel.decrement(item) }
                )
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.filteredItems.isEmpty && !viewModel.foodItems.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "line.3.horizontal.decrease.circle",
                    description: Text("No items match the selected filters.")
                )
            }
        }
        .overlay(alignment: .bottomTrailing) {
            cartButton
                .padding()
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort by Price", selection: $viewModel.sortOrder) {
                ForEach(PriceSortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
        } label: {
            Image(systemName: sortIcon)
        }
    }

    private var categoryMenu: some View {
        Menu {
            ForEach(viewModel.categories) { category in
                Button {
                    viewModel.toggleCategory(category.uuid)
                } label: {
                    if viewModel.selectedCategoryIDs.contains(category.uuid) {
                        Label(category.name, systemImage: "checkmark")
                    } else {
                        Text(category.name)
                    }
                }
            }
        } label: {
            Image(systemName: viewModel.selectedCategoryIDs.isEmpty
                ? "line.3.horizontal.decrease.circle"
                : "line.3.horizontal.decrease.circle.fill")
        }
    }

    private var sortIcon: String {
        switch viewModel.sortOrder {
        case .none: return "arrow.up.arrow.down"
        case .ascending: return "arrow.up"
        case .descending: return "arrow.down"
        }
    }

    private var cartButton: some View {
        Button {
            showingCart = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "cart.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(radius: 4, y: 2)

                if viewModel.totalCartCount > 0 {
                    Text("\(viewModel.totalCartCount)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(5)
                        .background(.red)
                        .clipShape(Circle())
                        .offset(x: 4, y: -4)
                }
            }
        }
    }
}

#Preview {
    FoodListView()
}
