//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Farmlabs Agriculture Tech on 6.09.2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryList: Results<ToDoCategory>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategoryList()
        tableView.rowHeight = 80
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor(hexString: "1D9BF6")
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - Layout Update
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Gradient katmanının çerçevesini güncelle
        if let gradientLayer = tableView.backgroundView?.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = tableView.bounds
        }
    }
    
    // MARK: - Gradient Uygulama Fonksiyonu
    func applyGradientToCell(cell: UITableViewCell, item: ToDoCategory) {
        // Eğer gradient katmanı varsa boyutunu güncelle
        if let primaryColor = UIColor(hexString: item.hexCode) {
            let gradientColors = primaryColor.darken(byPercentage: 0.3)
            cell.backgroundColor = gradientColors
        }
    }

    // MARK: - TableView data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        // Alt sınıfta ek özelleştirmeler yapabilirsiniz
        if let item = categoryList?[indexPath.row] {
            cell.textLabel?.text = item.name
            cell.backgroundColor = UIColor(hexString: item.hexCode)
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: item.hexCode)!, returnFlat: true)
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            applyGradientToCell(cell: cell, item: item)
        } else {
            cell.textLabel?.text = "No Category Added"
        }

        return cell
    }

    
    // MARK: - TableView data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at index \(indexPath.row)")
        performSegue(withIdentifier: "goToItemList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categoryList?[indexPath.row]
        }
    }
    
    
    // MARK: - TableView action
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField  = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            
            let newCategory = ToDoCategory()
            newCategory.name = textField.text!
            newCategory.hexCode = UIColor.randomFlat().hexValue()
            
            try! self.realm.write {
                self.realm.add(newCategory)
            }
            self.tableView.reloadData()
            self.saveCategory(category: newCategory)
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
            print("now")
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data manipulation methods
    func saveCategory(category: ToDoCategory) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch  {
            print("Saving failed")
        }
        
        self.tableView.reloadData()
    }
    func loadCategoryList() {
        categoryList = realm.objects(ToDoCategory.self)
        tableView.reloadData()
    }
    func performRealmWrite(_ block: () -> Void) {
        try! realm.write {
            block()
        }
    }
    func performRealmDelete(_ block: () -> Void) {
        do {
            try realm.write {
                block()
            }
        } catch {
            print("Realm delete transaction failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.categoryList?[indexPath.row] {
            self.performRealmDelete {
                self.realm.delete(item)
            }
        } else {
            print("Item not found")
        }
    }
}
