//
//  ViewController.swift
//  todo list
//
//  Created by Ula Kuczynska on 5/30/18.
//  Copyright © 2018 Ula Kuczynska. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    let itemArray = ["stop Thanos", "retreive all the Infinity Stones", "save the World"]
    
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
        
        cell.textLabel?.text = itemArray[indexPath.row]
        return cell
        
    }

    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.checkmark {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
        
        let selectedRow = indexPath.row
        print(itemArray[selectedRow])
    }
}

