//
//  CartView.swift
//  Food Mart
//
//  Created by Jerry Shi on 2026-06-04.
//

import SwiftUI

struct CartView: View {
    let viewModel: FoodListViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.cartItems.isEmpty {
                    ContentUnavailableView(
                        "Your Cart is Empty",
                        systemImage: "cart",
                        description: Text("Add items from the list.")
                    )
                } else {
                    VStack(spacing: 0) {
                        List {
                            ForEach(viewModel.cartItems, id: \.item.id) { cartItem in
                                CartItemRow(
                                    item: cartItem.item,
                                    quantity: cartItem.quantity,
                                    onIncrement: { viewModel.increment(cartItem.item) },
                                    onDecrement: { viewModel.decrement(cartItem.item) }
                                )
                            }
                        }
                        .listStyle(.plain)

                        Divider()

                        VStack(spacing: 0) {
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text(viewModel.cartTotal, format: .currency(code: "USD"))
                                    .font(.headline)
                            }
                            .padding(.horizontal)
                            .padding(.top, 12)

                            Button {
                                // TODO: call purchase endpoint when backend is ready
                            } label: {
                                Text("Purchase")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding()
                        }
                        .background(Color(.systemBackground))
                    }
                }
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct CartItemRow: View {
    let item: FoodItem
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 48, height: 48)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(item.price, format: .currency(code: "USD"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 6) {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 8, weight: .semibold))
                        .frame(width: 16, height: 16)
                        .background(Color(.systemGray4))
                        .clipShape(Circle())
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)

                Text("\(quantity)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(minWidth: 20)
                    .multilineTextAlignment(.center)

                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(.system(size: 8, weight: .semibold))
                        .frame(width: 16, height: 16)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }
}
