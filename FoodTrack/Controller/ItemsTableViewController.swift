//
//  ItemsTableViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 05/2/21.
//

import UIKit
import Firebase
import SwipeCellKit

class ItemsTableViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    let db = Firestore.firestore()
    var items: [Item] = []
    
    var selectedGroup : Group? {
        didSet {
            readItem()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.rowHeight = 70.0
        readItem()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if let colorHex = selectedGroup?.backgroundColor {
        title = selectedGroup?.name
//        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //Add New Group button pressed, save data here to FireStore
            if textField.text!.hasPrefix(" ") || textField.text!.isEmpty
            {
                self.alert(present: "Can not add item without name")
            } else {
                self.createItem(name: textField)
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Item Name"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - CRUD Data Manipulation Methods
    
    func createItem(name textField: UITextField) {
        let documentID = UUID().uuidString
        db.collection(Constant.FireStore.Collections.item)
            .document(documentID).setData([
                            Constant.FireStore.Collections.item: textField.text!,
                            Constant.FireStore.done: Bool(),
                            Constant.FireStore.id: documentID,
                            Constant.FireStore.userID: Auth.auth().currentUser!.uid, /*if SIGBAT nil, force unwrap is here*/
                            Constant.FireStore.date: Date().timeIntervalSince1970]) { (error) in
                if let isError = error {
                    self.alert(present: isError)
                }
            }
    }
    
    func readItem() {
        db.collection(Constant.FireStore.Collections.item)
            .whereField(Constant.FireStore.userID, isEqualTo: Auth.auth().currentUser!.uid)
            .order(by: Constant.FireStore.date)
            .addSnapshotListener { (querySnapchot, error) in
            self.items = []
            if let isError = error {
                self.alert(present: isError)
            } else {
                if let snapshotDocuments = querySnapchot?.documents {
                    for document in snapshotDocuments {
                        let data = document.data()
                        if let itemName = data[Constant.FireStore.Collections.item] as? String,
                           let itemDone = data[Constant.FireStore.done] as? Bool,
                           let itemID = data[Constant.FireStore.id] as? String,
                           let itemUserID = data[Constant.FireStore.userID] as? String,
                           let itemDate = data[Constant.FireStore.date] as? Double {
                            let newItem = Item(name: itemName, done: itemDone, id: itemID, userID: itemUserID, date: itemDate)
                            self.items.append(newItem)

                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                } else {
                    self.alert(present: "Failed to retrive data")
                }
            }
        }
    }
    
    func updateItem(at indexPath: IndexPath, is done: Bool) {
            db.collection(Constant.FireStore.Collections.item)
                .document(items[indexPath.row].id)
                .setData([Constant.FireStore.done: done], merge: true)
        readItem()
    }
    
    func deleteItem(at indexPath: IndexPath) {
        db.collection(Constant.FireStore.Collections.item).document(items[indexPath.row].id)
        items.remove(at: indexPath.row)
        readItem()
    }
    
    // MARK: - TableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Cell.item, for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = items[indexPath.row].name
        cell.delegate = self
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//MARK: - Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].done = !items[indexPath.row].done
        let done = items[indexPath.row].done
        if done {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        updateItem(at: indexPath, is: done)
        
//        if items[indexPath.row].done == false {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//            items[indexPath.row].done = false
//        } else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//            items[indexPath.row].done = true
//        }
    }
}

extension ItemsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            readItem()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            // Filtering
            readItem()
        }
    }
}

//MARK: - Swipe Cell Delegate Methods

extension ItemsTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: nil) { action, indexPath in
        self.deleteItem(at: indexPath)
        }
        let editAction = SwipeAction(style: .default, title: "Edit") { (action, indexPath) in
            //self.updateItem(at: indexPath, name: <#T##UITextField?#>)
        }
        
        deleteAction.image = UIImage(named: "ic_delete")
        editAction.image = UIImage(named: "ic_more")
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        //        options.transitionStyle = .border
        return options
    }
}
