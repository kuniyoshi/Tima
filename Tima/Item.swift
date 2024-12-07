//
//  Item.swift
//  Tima
//
//  Created by Koji Kuniyoshi on 2024-12-07.
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
