//
//  FunctionTableViewController.swift
//  BlocksForAll
//
//  Created by Alison Garrett-Engele on 7/19/19.
//  Copyright © 2019 Mariella Page. All rights reserved.
//

import UIKit

//help from Brian Voong
class FunctionTableViewController: UITableViewController {

    

    var functions: [String] = Array(functionsDict.keys)
    var functionWidth = 500
    var functionHeight = 150
    let functionSpacing = 0

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func insertFunction(_ sender: Any) {
        functions.append("function \(functions.count + 1)")
        for function in functions{
            print(function)
        }
        
        let insertionIndexPath = NSIndexPath(row: functions.count - 1, section: 0)
        
        tableView.insertRows(at: [insertionIndexPath as IndexPath], with: .automatic)
        functionsDict[functions[functions.count - 1]] = []
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


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "FunctionTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FunctionTableViewCell else{
            fatalError("The dequeued cell is not an instance of FunctionTableViewCell.")
        }
        cell.nameButton.setTitle(functions[indexPath.row], for: .normal)
        cell.functionTableViewController = self
        
//        let function = functions[indexPath.row]
//        cell.function = function
//
//        //let functionString = functions[indexPath.row]
//        let myView = FunctionView.init(frame: CGRect.init(x: 0, y: 0, width: 150, height: 150), function: functions,  myFunctionWidth: functionWidth, myFunctionHeight: functionHeight)
//
//        cell.addSubview(myView)

        return cell
    }
    
    func deleteCell(cell: UITableViewCell) {
        if let deletionIndexPath = tableView.indexPath(for: cell) {
            functions.remove(at: deletionIndexPath.row)
            tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
            functionsDict.removeValue(forKey: functions[deletionIndexPath.row])
        }
    }
    
    @objc func blockModifier(cell: UITableViewCell, sender: UIButton!) {
        let functionIndexPath = tableView.indexPath(for: cell)
        currentWorkspace = functions[(functionIndexPath?.row)!]
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


