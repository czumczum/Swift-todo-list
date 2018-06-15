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
    
    var defaultUISettings: [NSAttributedStringKey: Any] = [:]
    
    //MARK: - Outlets
    @IBOutlet var todoTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("No navbar or navigation controller!")
        }
        
        guard let backgroudColor = UIColor(hexString:(selectedCategory?.backgroundColor)!)  else {
            fatalError("No category selected!")
        }
        
        defaultUISettings = navBar.largeTitleTextAttributes!
        
        navBar.barTintColor = backgroudColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: backgroudColor, isFlat: false)]
        title = selectedCategory?.name
            
        searchBar.barTintColor = backgroudColor
        navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: backgroudColor, isFlat: false)
            
        searchBar.backgroundImage = UIImage()
        searchBar.isTranslucent = false
        navBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("No navbar or navigation controller!")
        }
        navBar.barTintColor = UIColor(hexString: "#FFD478")
        navBar.largeTitleTextAttributes = defaultUISettings
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
            cell.backgroundColor = (UIColor(hexString: categoryColor)?.lighten(byPercentage: 0.2))?.darken(byPercentage: (CGFloat(percentage)))
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor!, isFlat: false)
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
    
    //MARK: - Swipe-delete & edit method
    override func updateModel(at indexPath: IndexPath, with action: String) {
        
        switch action {
        case "delete":
            if let deletedItem = todoItems?[indexPath.row] {
                realmMethods.deleteFromRealm(with: deletedItem)
            }
            todoTableView.reloadData()
        case "edit":
            if let editedItem = todoItems?[indexPath.row] {
                editButtonPressed(with: editedItem)
            }
        default:
            print("error in swipe action")
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
    
    //MARK: - Edit categories
    
    func editButtonPressed(with item: Item) {
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
                            item.title = newName
                        }
                    } catch {
                        print("Error updatin an item \(error)")
                    }
                }
                self.todoTableView.reloadData()
            })
            
            alert.addAction(action)
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "New name"
                textField = alertTextField
            }
            self.present(alert, animated: true, completion: nil)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        }
        
        menu.addAction(changeNameAction)
        menu.addAction(cancelAction)
        
        present(menu, animated: true)
        
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

