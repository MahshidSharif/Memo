//
//  TaskModel.swift
//  Memo
//
//  Created by Mahshid Sharif on 5/13/19.
//  Copyright © 2019 Mahshid Sharif. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "categories")
}
