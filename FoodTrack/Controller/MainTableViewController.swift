//
//  MainTableViewController.swift
//  FoodTrack
//
//  Created by Michał Rytych on 03/2/21.
//

import UIKit
import Firebase
import SwipeCellKit

class MainTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    var groups: [Group] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        title = Constant.appName
        tableView.dataSource = self
        tableView.rowHeight = 70.0
        readGroup()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Group", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Group", style: .default) { (action) in
            //Add New Group button pressed, save data here to FireStore
            if textField.text!.hasPrefix(" ") || textField.text!.isEmpty
            {
                self.alert(present: "Can not add group without name")
            } else {
                self.createGroup(name: textField)
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Group Name"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
// #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
// #warning Incomplete implementation, return the number of rows
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.Cell.group, for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = groups[indexPath.row].name
        cell.delegate = self
        return cell
    }
    
    //MARK: - CRUD Data Manipulation Methods
    
    func createGroup(name textField: UITextField) {
        let documentID = UUID().uuidString
        db.collection(Constant.FireStore.Collections.group)
            .document(documentID).setData([
                            Constant.FireStore.Collections.group: textField.text!,
                            Constant.FireStore.id: documentID,
                            Constant.FireStore.userID: Auth.auth().currentUser!.uid, /*if SIGBAT nil, force unwrap is here*/
                            Constant.FireStore.date: Date().timeIntervalSince1970]) { (error) in
                if let isError = error {
                    self.alert(present: isError)
                }
            }
    }
    
    func readGroup() {
        db.collection(Constant.FireStore.Collections.group)
            .whereField(Constant.FireStore.userID, isEqualTo: Auth.auth().currentUser!.uid)
            .order(by: Constant.FireStore.date)
            .addSnapshotListener { (querySnapshot, error) in
                self.groups = []
                if let isError = error {
                    self.alert(present: isError)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for document in snapshotDocuments {
                            let data = document.data()
                            if let groupName = data[Constant.FireStore.Collections.group] as? String,
                               let groupID = data[Constant.FireStore.id] as? String,
                               let groupUserID = data[Constant.FireStore.userID] as? String,
                               let groupDate = data[Constant.FireStore.date] as? Double {
                                let newGroup = Group(name: groupName, id: groupID, userID: groupUserID, date: groupDate)
                                self.groups.append(newGroup)
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
    
    func updateGroup(at indexPath: IndexPath, at textField: UITextField) {
        db.collection(Constant.FireStore.Collections.group)
            .document(groups[indexPath.row].id)
            .setData([Constant.FireStore.Collections.group: textField.text!], merge: true)
        readGroup()
    }
    
    func deleteGroup(at indexPath: IndexPath) {
        db.collection(Constant.FireStore.Collections.group).document(groups[indexPath.row].id).delete()
        groups.remove(at: indexPath.row)
        readGroup()
    }
    
    //MARK: - Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constant.Segue.group, sender: self)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ItemsTableViewController
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedGroup = groups[indexPath.row]
        }
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
}

//MARK: - Swipe Cell Delegate Methods

extension MainTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteGroup(at: indexPath)
        }
        let editAction = SwipeAction(style: .default, title: "Edit") { (action, indexPath) in
            var textField = UITextField()
            let alert = UIAlertController(title: "Edit Group Name", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Edit Group", style: .default) { (action) in
                //Add New Group button pressed, save data here to FireStore
                if textField.text!.hasPrefix(" ") || textField.text!.isEmpty
                {
                    self.alert(present: "Can not add group without name")
                } else {
                    self.updateGroup(at: indexPath, at: textField)
                    self.tableView.reloadData()
                }
            }
            
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "New Group Name"
                textField = alertTextField
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        deleteAction.image = UIImage(named: "ic_delete")
        editAction.image = UIImage(named: "ic_more")
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
}
