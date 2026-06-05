//
//  FoodItemRow.swift
//  Food Mart
//
//  Created by Jerry Shi on 2026-06-04.
//

import SwiftUI

struct FoodItemRow: View {
    let item: FoodItem
    let categoryName: String
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
            .frame(width: 64, height: 64)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text(categoryName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(item.price, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if quantity == 0 {
                    Button("Add", action: onIncrement)
                        .font(.subheadline)
                        .foregroundStyle(Color.accentColor)
                        .buttonStyle(.plain)
                } else {
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
            }
        }
        .padding(.vertical, 4)
    }
}
