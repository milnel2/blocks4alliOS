//
//  I3BlockTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/8/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class I3BlockTableViewController: UITableViewController {

    //MARK: Properties
    var blocks = [Block]()
    var blockTypes = NSArray()
    var typeIndex: Int! = 0
    
    //update these as collection view changes
    private let blockWidth = 100
    private let blockSpacing = 10
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Toolbox"
        
        blockTypes = NSArray(contentsOfFile: Bundle.main.path(forResource: "BlocksMenu", ofType: "plist")!)!
        if let blockType = blockTypes.object(at: typeIndex) as? NSDictionary{
            self.title = blockType.object(forKey: "type") as? String
        }
        //self.accessibilityHint = "Double tap from menu to add block to workspace"
        
        print(blockTypes)
        createBlocksArray()
        // Load the sample data
        //loadSampleBlocks()
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
        return blocks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "BlockTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BlockTableViewCell else {
            fatalError("The dequeued cell is not an instance of BlockTableViewCell.")
        }
        
        let block = blocks[indexPath.row]
        
        cell.nameLabel.text = block.name
        cell.blockView.backgroundColor = block.color
        cell.block = block
        
        if(block.name == "Cancel" || block.name == "Choose Block from Workspace"){
            cell.blockView.frame = cell.bounds
            cell.nameLabel.frame = cell.bounds
        }
        
        cell.accessibilityLabel = block.name
        cell.accessibilityHint = "Double tap to add block to selected spot in workspace"
        //cell.blockView.
        //cell.blockView.backgroundColor = UIColor.brown
        // Configure the cell...
        // Drag drop with long press gesture
        //
        // Be careful with attaching gesture recognizers inside tableView:cellForRowAtIndexPath: as cells
        // get reused. Add a check to prevent multiple gesture recognizers from being added to the same cell.
        // The below check is crude but works; you may need something more specific or elegant.
       /* if (cell.gestureRecognizers == nil || cell.gestureRecognizers?.count == 0) {
            let manager = OBDragDropManager.shared()
            let recognizer = manager?.createDragDropGestureRecognizer(with: UIPanGestureRecognizer.classForCoder(), source: self)
            //let recognizer = manager?.createLongPressDragDropGestureRecognizer(with: self)
            cell.addGestureRecognizer(recognizer!)
            /*OBDragDropManager *dragDropManager = [OBDragDropManager sharedManager];
             UIGestureRecognizer *recognizer = [dragDropManager createLongPressDragDropGestureRecognizerWithSource:self];
             [cell addGestureRecognizer:recognizer];*/
        }*/
        
        
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
    

    
    //MARK: Private Methods
    
    //TODO: this is really convoluted, probably a better way of doing this
    private func createBlocksArray(){
        if let blockType = blockTypes.object(at: typeIndex) as? NSDictionary{
            if let blockArray = blockType.object(forKey: "Blocks") as? NSArray{
                for item in blockArray{
                    if let dictItem = item as? NSDictionary{
                        let name = dictItem.object(forKey: "name")
                        if let colorString = dictItem.object(forKey: "color") as? String{
                            let color = UIColor.colorFrom(hexString: colorString)
                            if let double = dictItem.object(forKey: "double") as? Bool{
                                guard let block = Block(name: name as! String, color: color, double: double) else {
                                    fatalError("Unable to instantiate block")
                                }
                                blocks += [block]
                            }
                        }
                    }
                }
            }
            
            //add Cancel and Choose from Workspace Blocks
            guard let workspaceblock = Block(name: "Choose Block from Workspace", color: UIColor.darkGray, double: false) else {
                fatalError("Unable to instantiate block")
            }
            blocks += [workspaceblock]
            
            guard let cancelBlock = Block(name: "Cancel", color: UIColor.red, double: false) else {
                fatalError("Unable to instantiate block")
            }
            blocks += [cancelBlock]
            
            /*cell.textLabel?.text = blockType.object(forKey: "type") as? String
             cell.textLabel?.textColor = UIColor.white
             if let colorString = blockType.object(forKey: "color") as? String{
             print(colorString)
             cell.backgroundColor = UIColor.colorFrom(hexString: colorString)
             }*/
        }
    }
    
    private func loadSampleBlocks(){
        guard let block1 = Block(name: "Drive Forward", color: UIColor.blue, double: false) else {
            fatalError("Unable to instantiate block1")
        }
        
        guard let block2 = Block(name: "Drive Backwards", color: UIColor.blue, double: false) else {
            fatalError("Unable to instantiate block2")
        }
        
        guard let block3 = Block(name: "Turn Left", color: UIColor.red, double: false) else {
            fatalError("Unable to instantiate block3")
        }
        
        guard let block4 = Block(name: "Turn Right", color: UIColor.red, double: false) else {
            fatalError("Unable to instantiate block4")
        }
        
        blocks += [block1, block2, block3, block4]
        
    }
    
}
