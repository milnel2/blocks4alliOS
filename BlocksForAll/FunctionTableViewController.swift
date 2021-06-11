//
//  FunctionTableViewController.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/19/19.
//  Copyright © 2019 Mariella Page. All rights reserved.
//

import UIKit

////keeps old function name when renamed so it can then be renamed in main workspace
//var oldKey = [String]()
//var newKey = [String]()

//help from Brian Voong
class FunctionTableViewController: UITableViewController {

    var oldKey = [String]()
    var newKey = [String]()
    
    //functions are all the names of the functions a user creates
    var functions: [String] = Array(functionsDict.keys)
    var functionWidth = 500
    var functionHeight = 150
    let functionSpacing = 0

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeMainWorkspace()
        
        self.tableView.register(FunctionTableViewCell.self, forCellReuseIdentifier: "FunctionTableViewCell")


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Functions Menu"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //adds a new row after plus button tapped, then alert allows you to name the function
    @IBAction func insertFunction(_ sender: Any) {
        let alert = UIAlertController(title: "Enter function name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Your file name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {action in
            let textField = alert.textFields![0] as UITextField
            self.functions.append(textField.text!)
            functionsDict.updateValue([], forKey: self.functions[self.functions.count - 1])
            let insertionIndexPath = NSIndexPath(row: self.functions.count-1, section: 0)
            self.tableView.insertRows(at: [insertionIndexPath as IndexPath], with: .automatic)
        }))

        self.present(alert, animated: true)
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return functions.count
    }


    //row has function name displayed
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FunctionTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FunctionTableViewCell else{
            fatalError("The dequeued cell is not an instance of FunctionTableViewCell.")
        }
        cell.nameButton.setTitle(functions[indexPath.row], for: .normal)
        cell.functionTableViewController = self
        
        cell.nameButton.superview?.bringSubview(toFront: cell.nameButton)
        cell.renameButton.superview?.bringSubview(toFront: cell.renameButton)
        cell.deleteButton.superview?.bringSubview(toFront: cell.deleteButton)
        
//        let function = functions[indexPath.row]
//        cell.function = function

        return cell
    }
    
    //prevents main workspace from being in the functions menu
    func removeMainWorkspace(){
        functions = functions.filter {$0 != "Main Workspace"}
    }
    
    //deletes a row from functions menu and gets rid of this function's values
    func deleteCell(cell: UITableViewCell) {
        if let deletionIndexPath = tableView.indexPath(for: cell) {
            functionsDict.removeValue(forKey: functions[deletionIndexPath.row])
            functions.remove(at: deletionIndexPath.row)
            tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
        }
    }
    
    //delete row with old function name and replace with new name. Value for both remains consistent.
    func renameCell(cell: UITableViewCell) {
        if let renameIndexPath = tableView.indexPath(for: cell) {
            oldKey.append(functions[renameIndexPath.row])
            let val = functionsDict[functions[renameIndexPath.row]]
//            functionsDict.removeValue(forKey: functions[renameIndexPath.row])
//            functions.remove(at: renameIndexPath.row)
//            tableView.deleteRows(at: [renameIndexPath], with: .automatic)
            
        let alert = UIAlertController(title: "Enter function name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Your file name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: {action in
            let textField = alert.textFields![0] as UITextField
            self.functions.append(textField.text!)
            self.newKey.append(self.functions[self.functions.count - 1])
            functionsDict.updateValue(val!, forKey: self.functions[self.functions.count - 1])
            let insertionIndexPath = NSIndexPath(row: self.functions.count-1, section: 0)
            self.tableView.insertRows(at: [insertionIndexPath as IndexPath], with: .automatic)
            //below updates all blocks in the app to show the right name after a rename, it literally goes through every block and every possible old name so this is really not efficent but hopefully this fixes the crashing from a long time
            for function in functionsDict.keys{
                for block in functionsDict[function]!{
                    for oldFunctionName in self.oldKey{
                        if block.name == oldFunctionName{
                            block.name = self.newKey[self.oldKey.firstIndex(of: oldFunctionName)!]
                        }
                    }
                }
            }
            functionsDict.removeValue(forKey: self.functions[renameIndexPath.row])
            self.functions.remove(at: renameIndexPath.row)
            self.tableView.deleteRows(at: [renameIndexPath], with: .automatic)
            functionsDict.updateValue(val!, forKey: self.functions[self.functions.count - 1])
        }))
        
        self.present(alert, animated: true)
        }
        
    }
    
    @objc func blockModifier(cell: UITableViewCell, sender: UIButton!) {
        let functionIndexPath = tableView.indexPath(for: cell)
        currentWorkspace = functions[(functionIndexPath?.row)!]
        performSegue(withIdentifier: "functionsToBlocks", sender: nil)
    }
    
    //leave function's menu and return to main workspace window when button pressed
    @IBAction func backToMainWorkspace(_ sender: Any) {
        currentWorkspace = "Main Workspace"
        performSegue(withIdentifier: "functionsToBlocks", sender: nil)
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
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        }

}


