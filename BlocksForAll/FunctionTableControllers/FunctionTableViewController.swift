//
//  FunctionTableViewController.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/19/19.
//  Copyright © 2019 Mariella Page. All rights reserved.
//

import UIKit

// Help from Brian Voong
class FunctionTableViewController: UITableViewController {
    /* Holds the function cells in a table view */
    // Keeps old function name when renamed so it can then be renamed in main workspace
    var oldKey = [String]()
    var newKey: String = ""

    var functions: [String] = Array(functionsDict.keys) // All the names of the functions a user creates placed in an array instead of dictionary so has a set order
    
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
    
    /// Adds a new row after plus button tapped, then an alert allows you to name the function
    @IBAction func insertFunction(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Enter function name", comment: "Alert title for creating a new function"), message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Your file name", comment: "Text field placeholder for creating a new function")
        }
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done".localized, style: .default, handler: {action in
            let textField = alert.textFields![0] as UITextField
            if self.validateFunctionName(name: textField.text!, currentAlert: alert) {
                // name is valid, create new function
                self.functions.append(textField.text!)
                functionsDict.updateValue([], forKey: self.functions[self.functions.count - 1])
                let insertionIndexPath = NSIndexPath(row: self.functions.count-1, section: 0)
                self.tableView.insertRows(at: [insertionIndexPath as IndexPath], with: .automatic)
            }
            
        }))

        self.present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = NSLocalizedString("Functions Menu", comment: "Title label for list of custom functions")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return functions.count
    }

    /// Creates cells for tableView. Row has function name displayed
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FunctionTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FunctionTableViewCell else{
            fatalError("The dequeued cell is not an instance of FunctionTableViewCell.")
        }
        cell.nameButton.setTitle(functions[indexPath.row], for: .normal)
        let formattedString = NSLocalizedString("edit_function_access_label", comment: "Accessibility Label for a button to edit a custom function. '<functionName>. Double tap to edit function.'")
        cell.nameButton.accessibilityLabel = String.localizedStringWithFormat(formattedString, functions[indexPath.row])
        cell.functionTableViewController = self

        return cell
    }
    
    /// Cell auto-resizes based on accessibility font
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    /// Prevent main workspace from being in the functions menu
    func removeMainWorkspace(){
        functions = functions.filter {$0 != "Main Workspace"}
    }
    
    /// Deletes a row from functions menu and gets rid of this function's values
    func deleteCell(cell: UITableViewCell) {
        if let deletionIndexPath = tableView.indexPath(for: cell) {
            oldKey.append(functions[deletionIndexPath.row])

            // Declare Alert message
            let dialogMessage = UIAlertController(title: NSLocalizedString("Confirm", comment: "Confirm action"), message: NSLocalizedString("Are you sure you want to delete this?", comment: "Message for a confirm action"), preferredStyle: .alert)
            
            // Create Yes button with action handler
            let yes = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action) -> Void in
                functionsDict.removeValue(forKey: self.functions[deletionIndexPath.row])
                self.functions.remove(at: deletionIndexPath.row)
                self.tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
                
                // Remove deleted function blocks from main workspace
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
            let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) -> Void in
            }
            
            //Add OK and Cancel button to dialog message
            dialogMessage.addAction(yes)
            dialogMessage.addAction(cancel)
            
            // Present dialog message to user
            self.present(dialogMessage, animated: true, completion: nil)
        }
    }
    
    // Delete row with old function name and replace with new name. Value for both remains consistent.
    func renameCell(cell: UITableViewCell) {
        if let renameIndexPath = tableView.indexPath(for: cell) {
            oldKey.append(functions[renameIndexPath.row])
            let val = functionsDict[functions[renameIndexPath.row]]
        // Show alert
            let alert = UIAlertController(title: NSLocalizedString("Enter function name", comment: "Alert title to rename a custom function"), message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Your function name", comment: "Text field placeholder for custom function name")
        }
            alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title:"Done".localized, style: .default, handler: {action in
            let textField = alert.textFields![0] as UITextField
            
            if self.validateFunctionName(name: textField.text!, currentAlert: alert) {
                // new name is valid, rename the function
                self.functions.append(textField.text!)
                self.newKey = self.functions[self.functions.count - 1]
                functionsDict.updateValue(val!, forKey: self.functions[self.functions.count - 1])
                let insertionIndexPath = NSIndexPath(row: self.functions.count-1, section: 0)
                self.tableView.insertRows(at: [insertionIndexPath as IndexPath], with: .automatic)
                
                // Below updates all blocks in the app to show the right name after a rename, it literally goes through every block and every possible old name so this is really not efficent but hopefully this fixes the crashing from a long time
                let functionStartStr = NSLocalizedString("Function Start", comment: "Block name for the start of a custom function (ex. block called: <funcName> Function Start)")
                let functionEndStr = NSLocalizedString("Function End", comment: "Block name for the end of a custom function (ex. block called: <funcName> Function End)")
                for function in functionsDict.keys{
                    for block in functionsDict[function]!{
                        for oldFunctionName in self.oldKey{
                            if block.name == oldFunctionName{
                               
                                block.name = self.newKey
                            } else if block.name == "\(oldFunctionName) \(functionStartStr)" {
                                block.name = "\(self.newKey) \(functionStartStr)"
                            } else if block.name == "\(oldFunctionName) \(functionEndStr)" {
                                block.name = "\(self.newKey) \(functionEndStr)"
                            }
                        }
                    }
                }
                functionsDict.removeValue(forKey: self.functions[renameIndexPath.row])
                self.functions.remove(at: renameIndexPath.row)
                self.tableView.deleteRows(at: [renameIndexPath], with: .automatic)
                functionsDict.updateValue(val!, forKey: self.functions[self.functions.count - 1])
            }
        }))
        self.present(alert, animated: true)
        }
    }
    
    func validateFunctionName(name: String, currentAlert: UIAlertController) -> Bool{
        let dictionary = HelperFunctions.getPListDictionary(resourceName: "ModifierProperties")!
        if (dictionary[name] != nil) {
            // Name is protected, show an alert do not rename the function
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: NSLocalizedString("Name is protected", comment: "Title for an invalid name alert"), message: NSLocalizedString("Choose a different name", comment: "Message for an invalid name alert"), preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Okay action for an invalid name alert"), style: .default, handler: nil))
                self.present(invalidNameAlert, animated: true)
            }
            return false
        } else if (name == "") {
            // Name is empty string
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: NSLocalizedString("Name cannot be empty", comment: "Title for an invalid name alert"), message: NSLocalizedString("Choose a different name", comment: "Message for an invalid name alert"), preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Okay action for an invalid name alert"), style: .default, handler: nil))
                self.present(invalidNameAlert, animated: true)
            }
            return false
        } else if (self.functions.contains(name))  {
            // Duplicate custom function name
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: NSLocalizedString("Name already exists", comment: "Title for an invalid name alert"), message: NSLocalizedString("Choose a different name", comment: "Message for an invalid name alert"), preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Okay action for an invalid name alert"), style: .default, handler: nil))
                self.present(invalidNameAlert, animated: true)
            }
            return false
        } else if (self.oldKey.contains(name))  {
            // Function name was used previously but removed
            currentAlert.dismiss(animated: true) {
                let invalidNameAlert = UIAlertController(title: NSLocalizedString("Name cannot have been used before", comment: "Title for an invalid name alert"), message: NSLocalizedString("Choose a different name", comment: "Message for an invalid name alert"), preferredStyle: .alert)
                invalidNameAlert.addAction(UIAlertAction(title: NSLocalizedString("Okay", comment: "Okay action for an invalid name alert"), style: .default, handler: nil))
                self.present(invalidNameAlert, animated: true)
            }
            return false
        }
        return true
        
    }
    
    @objc func blockModifier(cell: UITableViewCell, sender: UIButton!) {
        let functionIndexPath = tableView.indexPath(for: cell)
       
        currentWorkspace = functions[(functionIndexPath?.row)!]
        performSegue(withIdentifier: "functionsToBlocks", sender: nil)
    }
    
    /// Leave function's menu and return to main workspace window when button pressed
    @IBAction func backToMainWorkspace(_ sender: Any) {
        currentWorkspace = "Main Workspace"
        performSegue(withIdentifier: "functionsToBlocks", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
       
    }
}


