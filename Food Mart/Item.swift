//
//  Item.swift
//  Food Mart
//
//  Created by Jerry Shi on 2026-06-04.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
