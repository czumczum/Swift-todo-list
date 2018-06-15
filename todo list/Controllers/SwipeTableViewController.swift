//
//  SwipeTableViewController.swift
//  todo list
//
//  Created by Ula Kuczynska on 6/13/18.
//  Copyright © 2018 Ula Kuczynska. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 70.0
        tableView.separatorStyle = .none
        
    }
    
    func visibleRect(for tableView: UITableView) -> CGRect? {
        return CGRect.init()
    }
    
    
    // MARK: - TableView DataSource methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.updateModel(at: indexPath, with: "delete")

        }
        
        let editAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            
            self.updateModel(at: indexPath, with: "edit")
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        editAction.backgroundColor = UIColor.flatSkyBlue
        editAction.image = UIImage(named: "edit")
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
    
        var options = SwipeTableOptions()
        options.expansionStyle = .none
        options.transitionStyle = .reveal
        return options
    }
    
    func updateModel(at indexPath: IndexPath, with action: String) {
        // Methods update data model
    }
}
