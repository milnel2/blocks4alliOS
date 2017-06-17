//
//  I3BlocksTypeTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 3/12/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class PlaceholderBlocksTypeTableViewController: BlocksTypeTableViewController {

    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO check this
        self.performSegue(withIdentifier: "blockTypeSegue", sender: self)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        if let myDestination = segue.destination as? PlaceholderBlockTableViewController{
            myDestination.typeIndex = tableView.indexPathForSelectedRow?.row
            myDestination.indexToAdd = self.indexToAdd
        }
        
        // Get the new view controller using segue.destinationViewController.
       /* if let myDestination = segue.destination as? PlaceholderViewController{
            if let blockCell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? BlockTableViewCell{
                myDestination.blocksToAdd = blockCell.block
            }
            // myDestination.blockToAdd = tableView.indexPathForSelectedRow?.row
        }*/
        
    }

    
}
