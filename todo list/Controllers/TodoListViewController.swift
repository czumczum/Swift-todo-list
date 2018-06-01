//
//  ViewController.swift
//  todo list
//
//  Created by Ula Kuczynska on 5/30/18.
//  Copyright © 2018 Ula Kuczynska. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let defaults = UserDefaults.standard
    
    //MARK: - Outlets
    @IBOutlet var todoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load the items from UserData
        if let items = defaults.array(forKey: "todoListArray") as? [Item] { //protection from casting nil to [String]
            itemArray = items
        }
        print(defaults.array(forKey: "todoListArray"))
        
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
        if currentItem.isDone == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
        
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedItem = itemArray[indexPath.row]
        selectedItem.isDone = !selectedItem.isDone
        
        tableView.reloadData()
    }
    
    
    //MARK: - Add new item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new item allert", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add new item", style: .default) { (action) in
            if textField.text != "" {
                let newItem = Item()
                newItem.title = textField.text!
                
                self.itemArray.append(newItem) //add to data source array
                print(self.itemArray)
//                self.defaults.set(self.itemArray, forKey: "todoListArray") //save all data to UserDefaults
                self.todoTableView.reloadData()
            }
        }
    
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

