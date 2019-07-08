//
//  BlockTableViewController.swift
//  BlocksForAll
//
//  Created by Lauren Milne on 2/28/17.
//  Copyright © 2017 Lauren Milne. All rights reserved.
//

import UIKit

class BlockTableViewController: UITableViewController {
    /*Toolbox menu that displays the blocks of a certain type*/
    
    //MARK: Properties
    var toolBoxBlockArray = [Block]()
    var blockTypes = NSArray()
    var typeIndex: Int! = 0
    
    //used to pass on delegate to selectedBlockViewController
    var delegate: BlockSelectionDelegate?
    
    //update these as collection view changes
    var blockWidth = 150
    let blockSpacing = 0
    
    //MARK: - viewDidLoad function
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = "Toolbox"
        
        blockTypes = NSArray(contentsOfFile: Bundle.main.path(forResource: "ReleaseBlocksMenu", ofType: "plist")!)!
        if let blockType = blockTypes.object(at: typeIndex) as? NSDictionary{
            self.title = blockType.object(forKey: "type") as? String
        }
        self.accessibilityHint = "Double tap from toolbox to add block to workspace"
        
        createBlocksArray()
        //self.navigationItem.backBarButtonItem?.accessibilityLabel = "Cancel"
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
        return toolBoxBlockArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "BlockTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BlockTableViewCell else {
            fatalError("The dequeued cell is not an instance of BlockTableViewCell.")
        }
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let block = toolBoxBlockArray[indexPath.row]
        
        //probably get rid of special blocktableviewcell and just add blockView to each cell
        cell.block = block
        //cell.nameLabel.text = block.name
        //cell.blockView.backgroundColor = block.color
        
        let myView = BlockView.init(frame: CGRect.init(x: 0, y: 0, width: blockWidth, height: blockWidth),  block: [block], myBlockWidth: blockWidth, myBlockHeight: blockWidth)
        cell.accessibilityLabel = block.name
        cell.accessibilityHint = "In Toolbox. Double tap to place block in workspace."
        
        cell.addSubview(myView)
        //cell.accessibilityHint = "In Toolbox. Double tap to place block in workspace."
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let height = tableView.bounds.height/CGFloat(blocks.count)
        return CGFloat(blockWidth + blockSpacing)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // Letting destination controller know which blocks type was picked
        if let myDestination = segue.destination as? SelectedBlockViewController{
            //copy to ensure that you get a new id for each block
            let b2 = tableView.cellForRow(at: tableView.indexPathForSelectedRow!)
            var block = toolBoxBlockArray[(tableView.indexPathForSelectedRow?.row)!].copy()
            for myView in (b2?.subviews)!{
                if let myBlockView = myView as? BlockView{
                    block = myBlockView.blocks[0].copy()
                }
            }
            
            //let block = blocks[(tableView.indexPathForSelectedRow?.row)!].copy()
            if block.double{
                let endBlockName = "End " + block.name
                let endBlock = Block(name: endBlockName, color: block.color, double: true)
                endBlock?.counterpart = block
                block.counterpart = endBlock
                myDestination.blocks = [block, endBlock!]
            }else{
                myDestination.blocks = [block]
            }
            myDestination.delegate = self.delegate
        }
    }
    
    
    //MARK: Private Methods
    
    //TODO: Clean this method it's a bit convoluted
    private func createBlocksArray(){
        /*Creating the toolbox by reading in from the .plist file */
        if let blockType = blockTypes.object(at: typeIndex) as? NSDictionary{
            // blockTypes is a nsArray object with the contents of the ReleaseBlocksMenu.plist file, type index is an Int Var starts at 0, so it takes the contents of ReleaseBlocksMenu.plist and sets it to blockType as an NSDictionary
            if let blockArray = blockType.object(forKey: "Blocks") as? NSArray{
                // creates array from the first object in blocksMenu.plist aka Animals, Controls, Drive, Sounds, etc.
                for item in blockArray{
                    // for block in category Animal, Control, etc.
                    if let dictItem = item as? NSDictionary{
                        // take the block and using it as a dictionary dictItem
                        // below takes the blocks and initalizes their properties
                        let name = dictItem.object(forKey: "name")
                        if let colorString = dictItem.object(forKey: "color") as? String{
                            let color2 = Color.init(uiColor:UIColor.colorFrom(hexString: colorString))
                            if let double = dictItem.object(forKey: "double") as? Bool{
                                guard let block = Block(name: name as! String, color: color2 , double: double) else {
                                    fatalError("Unable to instantiate block")
                                }
                                if let imageName = dictItem.object(forKey: "imageName") as? String{
                                    block.addImage(imageName)
                                }
                                if let type = dictItem.object(forKey: "type") as? String{
                                    block.type = type
                                }
                                if let acceptedTypes = dictItem.object(forKey: "acceptedTypes") as? [String]{
                                    block.acceptedTypes = acceptedTypes
                                }
                                toolBoxBlockArray += [block]
                                // adds block to the toolbox
                            }
                        }
                    }
                }
            }
        }
    }
    
}

