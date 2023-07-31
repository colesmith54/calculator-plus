//
//  Item.swift
//  calculator-plus
//
//  Created by Cole Smith on 7/30/23.
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
