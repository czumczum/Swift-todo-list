//
//  Created by Ula Kuczynska on 5/30/18.
//  Copyright © 2018 Ula Kuczynska. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet{
            print(selectedCategory)
            //Load the items from CoreData after selected Category is set 
            loadItems()
            
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - Outlets
    @IBOutlet var todoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    //MARK: - Tableview Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let currentItem = itemArray[indexPath.row]
        cell.textLabel?.text = currentItem.title
        
        //Add checkmark or not
        cell.accessoryType = currentItem.isDone ? .checkmark : .none
        
        return cell
        
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = itemArray[indexPath.row]
        selectedItem.isDone = !selectedItem.isDone
        
        saveItems()
    }
    
    
    //MARK: - Add new item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new item allert", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add new item", style: .default) { (action) in
            if textField.text != "" {
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem) //add to data source array
                
                //Datasave via encoder
                self.saveItems()
                
            }
        }
    
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data save & retreive methods via encoder
    func saveItems() {

        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)!")
        }
         todoTableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        
        let predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        request.predicate = predicate
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        
     todoTableView.reloadData()
    }
} 

//MARK: - SearchBar Delegate & methods
extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text! ) //non-sensitive for cases and diacricts
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
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

