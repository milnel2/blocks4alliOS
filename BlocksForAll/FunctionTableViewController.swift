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
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        removeMainWorkspace()
        
        self.tableView.register(FunctionTableViewCell.self, forCellReuseIdentifier: "FunctionTableViewCell")
        
        // preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

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
        
//        let function = functions[indexPath.row]
//        cell.function = function

        return cell
    }
    
    //Cell auto-resizes based on accessibility font
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    //prevents main workspace from being in the functions menu
    func removeMainWorkspace(){
        functions = functions.filter {$0 != "Main Workspace"}
    }
    
    //deletes a row from functions menu and gets rid of this function's values
    func deleteCell(cell: UITableViewCell) {
        if let deletionIndexPath = tableView.indexPath(for: cell) {
            oldKey.append(functions[deletionIndexPath.row])

            // Declare Alert message
            let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
            
            // Create Yes button with action handler
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                print("yes button tapped")
                functionsDict.removeValue(forKey: self.functions[deletionIndexPath.row])
                self.functions.remove(at: deletionIndexPath.row)
                self.tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
                
                //Removes deleted function blocks from main workspace
                for function in functionsDict.keys{
                    for block in functionsDict[function]!{
                        for oldFunctionName in self.oldKey{
                            if block.name == oldFunctionName{
                                functionsDict[function]!.remove(at: functionsDict[function]!.firstIndex{$0 === block}!)
                            }
                        }
                    }
                }
            })
            
            // Create Cancel button with action handlder
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel button tapped")
            }
            //Add OK and Cancel button to dialog message
            dialogMessage.addAction(yes)
            dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
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
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
}


