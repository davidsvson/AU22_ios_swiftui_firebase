//
//  Item.swift
//  Firebase-Shoppinglist
//
//  Created by David Svensson on 2023-01-03.
//

import Foundation
import FirebaseFirestoreSwift

struct Item : Codable, Identifiable {
    @DocumentID var id : String?
    var name : String
    var category : String = ""
    var done: Bool = false
}
