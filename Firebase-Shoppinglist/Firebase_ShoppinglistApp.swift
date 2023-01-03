//
//  Firebase_ShoppinglistApp.swift
//  Firebase-Shoppinglist
//
//  Created by David Svensson on 2023-01-03.
//

import SwiftUI
import Firebase


@main
struct Firebase_ShoppinglistApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
