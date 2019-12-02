//
//  Item.swift
//  Todoey
//
//  Created by Farmlabs Agriculture Tech on 16.09.2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var hexCode: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    var parentCategory = LinkingObjects(fromType: ToDoCategory.self, property: "itemList")
}
