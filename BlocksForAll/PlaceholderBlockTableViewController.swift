//
//  PlaceholderBlockTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/8/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class PlaceholderBlockTableViewController: BlockTableViewController {

    //MARK: Properties
    var indexToAdd = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.accessibilityHint = "Double tap from menu to add block to workspace"

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
        
        let myView = BlockView.init(frame: CGRect.init(x: (Int(cell.bounds.width)-blockWidth)/2, y: 0, width: blockWidth, height: blockWidth), block: [block])
        cell.addSubview(myView)
        
        cell.accessibilityLabel = block.name
        cell.accessibilityHint = "Double tap to add block to selected spot in workspace"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = tableView.bounds.height/CGFloat(blocks.count)
        return height
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let containerViewController = segue.destination as? UINavigationController{
            if let myDestination = containerViewController.topViewController as? PlaceholderViewController{
                if let blockCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? BlockTableViewCell{
                    if let block = blockCell.block?.copy(){
                        if block.double{
                            let endBlockName = "End " + block.name
                            let endBlock = Block(name: endBlockName, color: block.color, double: true, editable: false)
                            endBlock?.counterpart = block
                            block.counterpart = endBlock
                            myDestination.blocksToAdd = [block, endBlock!]
                        }else{
                            myDestination.blocksToAdd = [block]
                        }
                        myDestination.indexToAdd = indexToAdd
                    }
                }
            }
        }
        
        
        // Pass the selected object to the new view controller.
    }
    
}
