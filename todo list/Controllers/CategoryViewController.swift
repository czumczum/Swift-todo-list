//
//  CategoryViewController.swift
//  todo list
//
//  Created by Ula Kuczynska on 6/6/18.
//  Copyright © 2018 Ula Kuczynska. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    let realmMethods = RealmMethods()
    
    var categories: Results<Category>?

    @IBOutlet var categoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
    }
    
    // MARK: - DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "There's nothing to display"
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].backgroundColor ?? "#ffffff")
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor!, isFlat: false)
        
        return cell
        
    }
    
    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Save, Load data
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
    }
    
    func saveCategory(with name: String) {
        let textField = name
        print(textField)
        if textField != "" {
            let newCategory = Category()
            newCategory.name = textField
            
            //Add some color
            newCategory.backgroundColor = RandomFlatColor().hexValue()
            
            self.realmMethods.saveToRealm(with: newCategory)
        }
        categoryTableView.reloadData()
    }
    
    //MARK: - Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.saveCategory(with: textField.text!)
            })
                
            alert.addAction(action)
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "New Category"
                textField = alertTextField
            }
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Swipe-delete & edit method
    override func updateModel(at indexPath: IndexPath, with action: String) {
        
        switch action {
        case "delete":
            if let deletedCategory = categories?[indexPath.row] {
                realmMethods.deleteFromRealm(with: deletedCategory)
            }
            categoryTableView.reloadData()
        case "edit":
            if let editedCategory = categories?[indexPath.row] {
                editButtonPressed(with: editedCategory)
            }
        default:
            print("error in swipe action")
        }
        
    }
    
    //MARK: - Edit categories
    
    func editButtonPressed(with category: Category) {
        // Create an action sheet with editing options
        let menu = UIAlertController(title: "Edit element", message: nil, preferredStyle: .actionSheet)
        
        // Name change
        let changeNameAction = UIAlertAction(title: "Change Name", style: .default) { (action) in
            
            // Alert-prompt to enter a new name
            let alert = UIAlertController(title: "Edit name", message: "", preferredStyle: .alert)
            var textField = UITextField()
            let action = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                
                // Updating Category with a new name
                if let newName = textField.text {
                    do {
                        try self.realm.write {
                            category.name = newName
                        }
                    } catch {
                        print("Error updatin an item \(error)")
                    }
                }
                self.categoryTableView.reloadData()
            })

            alert.addAction(action)
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "New name"
                textField = alertTextField
            }
            self.present(alert, animated: true, completion: nil)
            
        }
        let changeColorAction = UIAlertAction(title: "Change Color", style: .default) { (action) in
            
            // Updating Category with a new color
            do {
                try self.realm.write {
                    category.backgroundColor = RandomFlatColor().hexValue()
                }
            } catch {
                print("Error updatin an item \(error)")
            }
            self.categoryTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        
        menu.addAction(changeNameAction)
        menu.addAction(changeColorAction)
        menu.addAction(cancelAction)
        
        present(menu, animated: true)
        
    }
    
}
