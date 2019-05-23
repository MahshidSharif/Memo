//
//  CategoryCollectionViewController.swift
//  Memo
//
//  Created by Mahshid Sharif on 5/13/19.
//  Copyright © 2019 Mahshid Sharif. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let realm = try! Realm()
    var categories : Results<Category>?
    var selectedItems = [IndexPath]()
    
    enum Mode {
        case view
        case select
    }
    
    var viewMode: Mode = .view {
        didSet {
            switch viewMode {
            case .view:
                collectionView.allowsMultipleSelection = false
                
            case .select:
                collectionView.allowsMultipleSelection = true
            }
            setupBarButtons()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBarButtons()
        loadCategories()
        collectionView.backgroundColor = UIColor(hexString: "ce93d8")
        
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "e1bee7")
        navigationController?.navigationBar.tintColor = UIColor(hexString: "7b1fa2")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "7b1fa2") ?? FlatBlack()]
        
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
    }
    
    private func setupBarButtons() {
        if viewMode == .view {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(selectButtonPressed(_:)))
        } else if viewMode == .select {
            navigationItem.rightBarButtonItem = .none
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
//         / Suggested Way
//         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
//         
//         / do all the work inside cell class
//         cell.config(category: Category, viewMode: CategoryCollectionViewController.Mode)
//         return cell
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCollectionViewCell
        if let category = categories?[indexPath.row] {
            cell.categoryLabel?.text = category.name
            cell.backgroundColor = UIColor(hexString:  category.color)
        }
        
        if viewMode == .view {
            cell.selectImageView.isHidden = true
        } else if viewMode == .select {
            cell.selectImageView.isHidden = false
        }
        cell.layer.cornerRadius = 5.0
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch viewMode {
        case .view:
            performSegue(withIdentifier: "goToTasks", sender: self)
        case .select:
            if let selectedIndex = collectionView.indexPathsForSelectedItems.self {
                selectedItems = selectedIndex
                setRealmObjFlag(category: categories![indexPath.row], isSelected: true)
            }
            
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if viewMode == .select {
            collectionView.deselectItem(at: indexPath, animated: true)
            selectedItems = collectionView.indexPathsForSelectedItems!//.remove(at: indexPath.row)
            setRealmObjFlag(category: categories![indexPath.row], isSelected: false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TaskListTableViewController
        
        if let index = collectionView.indexPathsForSelectedItems?.last {
            destinationVC.selectedCategory = categories?[index.row]
        }
    }
    
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 30.0, bottom: 50.0, right: 30.0)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 2
        let itemsPerColumn: CGFloat = 3
        
        let wPaddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - wPaddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        let hPaddingSpace = sectionInsets.top * (itemsPerColumn + 1)
        let availableHeight = view.frame.height - hPaddingSpace
        let heightPerItem = availableHeight / itemsPerColumn
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.bottom
    }
    
    //MARK: - Functions
    func saveCategory(category: Category) {
        do {
            try self.realm.write {
                self.realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        collectionView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        collectionView.reloadData()
    }
    
    func setRealmObjFlag(category: Category, isSelected: Bool) {
        try! self.realm.write {
            category.isSelected = isSelected
        }
    }
    
    @objc func deleteSelectedCategories() {
        //if let categoryForDeletion = self.categories?[indexPath.row] {
        let categoryForDeletion = realm.objects(Category.self).filter("isSelected == YES")
            do {
                try self.realm.write {
                    //self.realm.delete(categoryForDeletion)
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        //}
    }
    
    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if textField.text != "" {
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.color = "8e24aa"
                self.saveCategory(category: newCategory)
            }
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Category Name"
        }
        present(alert, animated: true, completion: nil)
    }
    
    @objc func selectButtonPressed(_ sender: UIBarButtonItem) {
        viewMode =  .select
        collectionView.reloadData()
    }
    
    @objc func doneButtonPressed(_ sender: UIBarButtonItem) {
        viewMode =  .view
        //for index in selectedItems {
            deleteSelectedCategories()
        //}
        collectionView.deleteItems(at: selectedItems)
        let cells = self.collectionView.visibleCells
        cells.forEach { (cell) in
            let cell = cell as? CategoryCollectionViewCell
            cell?.selectImageView.isHidden = true
        }
        collectionView.reloadData()
    }
    
}

