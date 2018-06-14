//
//  Created by Ula Kuczynska on 5/30/18.
//  Copyright © 2018 Ula Kuczynska. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    let realmMethods = RealmMethods()
    
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet{
            //Load the items from Realm after selected Category is set
            loadItems()
            
        }
    }
    
    //MARK: - Outlets
    @IBOutlet var todoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    //MARK: - Tableview Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let currentItem = todoItems?[indexPath.row] {
            cell.textLabel?.text = currentItem.title
            
            //Add checkmark or not
            cell.accessoryType = currentItem.isDone ? .checkmark : .none
        }
        
        if let categoryColor = selectedCategory?.backgroundColor {
            let percentage = (todoItems?.count)! > 0 ? CGFloat(indexPath.row)/CGFloat(20) : 0
            print(todoItems?.count, percentage)
            cell.backgroundColor = (UIColor(hexString: categoryColor)?.lighten(byPercentage: 0.5))?.darken(byPercentage: (CGFloat(percentage)))
        }
        
        return cell
        
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectedItem = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    selectedItem.isDone = !selectedItem.isDone
                }
            } catch {
                print("Error updatin an item \(error)")
            }
        }
        
        todoTableView.reloadData()
    }
    
    
    //MARK: - Add new item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new item alert", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add new item", style: .default) { (action) in
            if textField.text != "" {
                let newItem = Item()
                newItem.title = textField.text!
                
                //Save new Object via realm
                self.saveItems(with: newItem)
            }
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new item"
            textField = alertTextField
        }

        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Start/Stop timer
    
    
    //MARK: - Swipe-delete method
    override func updateModel(at indexPath: IndexPath) {
        if let deletedItem = todoItems?[indexPath.row] {
            realmMethods.deleteFromRealm(with: deletedItem)
        }
    }
    
    //MARK: - Data save & retreive methods via encoder
    func saveItems(with item: Item) {
        if let parentCategory = selectedCategory {
            do {
                try self.realm.write {
                    item.dateCreated = Date()
                    parentCategory.items.append(item)
                }
            } catch {
                print("Realm save error \(error)")
            }
        }
        self.todoTableView.reloadData()
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
}

//MARK: - SearchBar Delegate & methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text! ) //non-sensitive for cases and diacricts
        todoItems = todoItems?.filter(predicate).sorted(byKeyPath: "title", ascending: true)
        todoTableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

