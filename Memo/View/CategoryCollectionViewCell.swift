//
//  CategoryCollectionViewCell.swift
//  Memo
//
//  Created by Mahshid Sharif on 5/13/19.
//  Copyright © 2019 Mahshid Sharif. All rights reserved.
//

import UIKit
class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var selectImageView: UIImageView!

    override var isSelected: Bool {
        didSet {
            self.selectImageView.image = isSelected ? UIImage(named: "selected") : UIImage(named: "deselect")
        }
    }
}
