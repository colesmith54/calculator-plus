//
//  calculator_plusApp.swift
//  calculator-plus
//
//  Created by Cole Smith on 7/30/23.
//

import SwiftUI
import SwiftData

@main
struct calculator_plusApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}
