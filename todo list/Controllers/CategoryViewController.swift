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
    
    //MARK: - Swipe-delete method
    override func updateModel(at indexPath: IndexPath, with action: String) {
        
        switch action {
            case "delete":
                if let deletedCategory = categories?[indexPath.row] {
                    realmMethods.deleteFromRealm(with: deletedCategory)
                }
            case "edit":
                if let editedCategory = categories?[indexPath.row] {
                    editButtonPressed(with: editedCategory)
            }
        default:
            print("error in swipe action")
        }
        
    }
    
    // MARK: - Save, Load data & edit data
    
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
    
    func editCategoryName(with name: String) {
        
    }
    
    
    
    //MARK: - Add new categories & edit existed
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        var textField = UITextField()
        if textField.text != "" {
            switch message {
            case "Add New Category":
                let action = UIAlertAction(title: message, style: .default, handler: { (action) in
                    self.saveCategory(with: textField.text!)
                })
                
                alert.addAction(action)
            default:
                let action = UIAlertAction(title: message, style: .default, handler: { (action) in
                    self.saveCategory(with: textField.text!)
                })
                alert.addAction(action)
            }
            
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = message
                textField = alertTextField
            }
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func editButtonPressed(with category: Category) {
        let menu = UIAlertController(title: "Edit element", message: nil, preferredStyle: .actionSheet)
        let changeNameAction = UIAlertAction(title: "Change Name", style: .default) { (action) in
            self.promptTextAlert(with: "Edit Category Name")
        }
        let changeColorAction = UIAlertAction(title: "Change Color", style: .default) { (action) in
            print("Change color")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        
        menu.addAction(changeNameAction)
        menu.addAction(changeColorAction)
        menu.addAction(cancelAction)
        
        present(menu, animated: true)
        
    }
    
    func promptTextAlert(with message: String) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        var textField = UITextField()
        if textField.text != "" {
            switch message {
            case "Add New Category":
                let action = UIAlertAction(title: message, style: .default, handler: { (action) in
                    self.saveCategory(with: textField.text!)
                })
                
                alert.addAction(action)
            default:
                let action = UIAlertAction(title: message, style: .default, handler: { (action) in
                    self.saveCategory(with: textField.text!)
                })
                alert.addAction(action)
                }
            
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = message
                textField = alertTextField
                }
            present(alert, animated: true, completion: nil)
            }

    }
    
}
