//
//  I3BlocksTypeTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/12/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class I3BlocksTypeTableViewController: UITableViewController {
    var blockDict = NSArray()
    var blockTypes = [Block]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Toolbox"
        self.accessibilityLabel = "Toolbox Menu"
        self.accessibilityHint = "Double tap from menu to select block type"
        
        blockDict = NSArray(contentsOfFile: Bundle.main.path(forResource: "BlocksMenu", ofType: "plist")!)!
        
        createBlocksArray()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return blockTypes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier
        
        let cellIdentifier = "BlockTypeTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        
        let blockType = blockTypes[indexPath.row]
        cell.textLabel?.text = blockType.name
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = blockType.color
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= blockDict.count{
            self.performSegue(withIdentifier: "cancelSegue", sender: self)
        }else{
            self.performSegue(withIdentifier: "blockTypeSegue", sender: self)
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
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        
        // Get the new view controller using segue.destinationViewController.
        if let myDestination = segue.destination as? BlockTableViewController{
            //if let blockCell = sender as?
            myDestination.typeIndex = tableView.indexPathForSelectedRow?.row
        }
        if let myDestination = segue.destination as? I3BlockTableViewController{
            //if let blockCell = sender as?
            myDestination.typeIndex = tableView.indexPathForSelectedRow?.row
        }
        
        // Get the new view controller using segue.destinationViewController.
        if let myDestination = segue.destination as? Interface3ViewController{
            //if let blockCell = sender as?
            if let blockCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? BlockTableViewCell{
                myDestination.blockToAdd = blockCell.block
            }
            // myDestination.blockToAdd = tableView.indexPathForSelectedRow?.row
        }
        
        // Get the new view controller using segue.destinationViewController.
        if let myDestination = segue.destination as? I4ViewController{
            //if let blockCell = sender as?
            if let blockCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? BlockTableViewCell{
                myDestination.blockToAdd = blockCell.block
            }
            // myDestination.blockToAdd = tableView.indexPathForSelectedRow?.row
        }
        // Pass the selected object to the new view controller.
    }
    
    //TODO: this is really convoluted, probably a better way of doing this
    private func createBlocksArray(){
        for item in blockDict{
            if let blockType = item as? NSDictionary{
                let name = blockType.object(forKey: "type") as? String
                var color = UIColor.green
                if let colorString = blockType.object(forKey: "color") as? String{
                    print(colorString)
                    color = UIColor.colorFrom(hexString: colorString)
                }
                guard let block = Block(name: name!, color: color, double: false) else {
                    fatalError("Unable to instantiate block")
                }
                blockTypes += [block]
            }
        }
        
        guard let workspaceblock = Block(name: "Choose Block from Workspace", color: UIColor.darkGray, double: false) else {
            fatalError("Unable to instantiate block")
        }
        blockTypes += [workspaceblock]
        
        guard let cancelBlock = Block(name: "Cancel", color: UIColor.red, double: false) else {
            fatalError("Unable to instantiate block")
        }
        
        blockTypes += [cancelBlock]
    }

    
}
