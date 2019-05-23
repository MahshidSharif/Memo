//
//  CategoryModel.swift
//  Memo
//
//  Created by Mahshid Sharif on 5/13/19.
//  Copyright © 2019 Mahshid Sharif. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    @objc dynamic var isSelected: Bool = false
    
    let categories = List<Task>()
}
