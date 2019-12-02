//
//  Category.swift
//  Todoey
//
//  Created by Farmlabs Agriculture Tech on 16.09.2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class ToDoCategory: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var hexCode: String = ""
    let itemList = List<Item>()
}
